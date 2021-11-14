
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:async';
import 'dart:convert';
import 'package:event_bus/event_bus.dart';
import 'package:myflutter/common/voice.dart';
import 'package:myflutter/common/music.dart';
import 'package:flutter_picker/flutter_picker.dart';
import '../../globalData.dart';
import 'package:provider/provider.dart';


var  ServiceUUID = '0000FFF0-0000-1000-8000-00805F9B34FB';//服务id
var WriteCharacteristicUUID = '0000FFF2-0000-1000-8000-00805F9B34FB';//写操作uuid
var NotifyCharactersticUUID = '0000FFF1-0000-1000-8000-00805F9B34FB';//状态uuid

Voice voice = new Voice();
Music music = new Music();
class RopeData {
  String mrfs = '-' ;//厂商名
  String deviceModel = '-';//模块型号
  String hardwareVersion = '-';//硬件版本号
  String softwareVersion = '-';//软件版本号
  String serial = '-';//序列号
  num times = 0;//运动时间
  num calories = 0;//卡路里
  num speed = 0;//实时速度
  num interruptTime = 0;//绊绳次数
  num continueCount = 0;//连跳数
  num count = 0;//总跳数
  num status = 0;//状态，0待机 1运行中
  num battery = 0;//电量
  bool isAlreadyStop = false;//是否已经停止

}

EventBus eventBus = new EventBus();
class RopeRealData {
  late RopeData ropeRealData;
  RopeRealData( this.ropeRealData);
}
class Rope extends StatefulWidget {
  Rope({Key? key, required this.deviceId, required this.deviceLocalName}) : super(key: key);
  String deviceId = '';
  String deviceLocalName = '';
  FlutterBlue flutterBlue = FlutterBlue.instance;

  @override
  State<StatefulWidget> createState()=> RopeWidget();
}
class RopeWidget extends State<Rope>{
  late BluetoothDevice device;
  late BluetoothCharacteristic writeC;
  late BluetoothCharacteristic notifyC;
  late Timer statusTimer;
  int sendTimeout = 2000;
  bool isConnected = false;
  List cmdQuene =  [];
  var deviceData = new RopeData();
  List currentCmd = [];
  bool isCantGetServices = true;
  bool isTryConnect = false;

  bool isGetServices = false;
  void initData(){
    RopeData newdata = deviceData;
    deviceData.times = 0;//运动时间
    deviceData.calories = 0;//卡路里
    deviceData.speed = 0;//实时速度
    deviceData.interruptTime = 0;//绊绳次数
    deviceData.continueCount = 0;//连跳数
    deviceData.count = 0;//总跳数
    deviceData.status = 0;//状态，0待机 1运行中
    deviceData.isAlreadyStop = false;//是否已经停止
    deviceData = newdata;
  }

  @override
  void initState() {
    super.initState();
//    widget.flutterBlue.reinitialize();
    ifHaveSpeacialDevice(widget.deviceLocalName,widget.deviceId);



  }
  @override
  void dispose() {
    super.dispose();
    widget.flutterBlue.stopScan();
    //断连
    if(!isCantGetServices){
      disConnectDevice();
    }
  }

  //连接的过程改成和网易的交互一样
  /*
   * 1.首先获取当前连接的设备，查看这个设备是否有我们特定的服务特征值（或者说deiviceid也可以）
   * 2。如果是 就断开连接
   * 3、搜索设备 查看是否有这台设备的名字、deviceid
   * 4、然后进入到连接这个环节
   *
   */

  ifHaveSpeacialDevice(deviceName,deviceId) async{


     List <BluetoothDevice> connectedDevices = await widget.flutterBlue.connectedDevices;
    for(BluetoothDevice d in connectedDevices){
      if(d.id.toString() == deviceId){
        d.disconnect();
        break;
      }
    }
    widget.flutterBlue.startScan(timeout: Duration(seconds: 4),withServices:[Guid(ServiceUUID)],scanMode: ScanMode.balanced);
    widget.flutterBlue.scanResults.listen((results) {
      if(mounted){
        if(widget.flutterBlue.state == BluetoothDeviceState.connected){
        }else{
          for (ScanResult result in results) {
            if (result.device.name.length > 0 && result.device.id.toString() == deviceId && result.device.name.toString() == deviceName && !isTryConnect) {
              //停止搜索
              device = result.device;
              print('resulets:'+results.toString());
              print('device:'+device.toString());
              isTryConnect = true;
              connectDevice();
              widget.flutterBlue.stopScan();

            }
          }

        }
      }


    });
  }

  /*
  * 1、建立连接
  * 2、监听连接状态
  * 3、获取设备服务
  * 4、获取蓝牙设备某个服务中所有特征值
  * 5、判断是否有读和写两个特征值
  * 6、监听特征值变化
  * 7、发送心跳包
  * 8、获取设备返回的特征值
  * */
  void connectDevice(){
    isTryConnect = true;
    device.connect();
    device.state.listen((state){
      onBLEConnectionStateChange(state);
    });
  }
  void disConnectDevice(){
    isCantGetServices = true;
    device.disconnect();
    widget.flutterBlue.reinitialize();
    clearStatusTimer();

  }
  void onBLEConnectionStateChange( state){
    if(state == BluetoothDeviceState.connected && !this.isGetServices && mounted){
      this.isGetServices = true;
      print('设备已连接,$this.isGetServices');
      isConnected = true;
      isCantGetServices = false;
      getBLEDeviceServices();
    }else if(state == BluetoothDeviceState.disconnected){
      print('设备断开连接');
      isConnected = false;
    }
  }

  void  getBLEDeviceServices() async{
    List<BluetoothService> services = await device.discoverServices();
    services.forEach((service) {
      // do something with service
      if(service.uuid.toString().toUpperCase().indexOf(ServiceUUID)>-1){
        getBLEDeviceCharacteristics(service.characteristics);
      }
    });

  }
  void getBLEDeviceCharacteristics(characteristics)async{
    bool hasWrite = false;
    for(BluetoothCharacteristic c in characteristics) {
      if(c.toString().toUpperCase().indexOf(WriteCharacteristicUUID)>-1){
        hasWrite = true;
        writeC = c;
      }
      if(c.toString().toUpperCase().indexOf(NotifyCharactersticUUID)>-1 && hasWrite){
        notifyC = c;
        c.setNotifyValue(true);//notifyBLECharacteristicValueChange
        c.value.listen((value) {
          if(mounted){
            getDeviceCharacteristics(value);
          }
        });
        commandControlCenter();

      }

    }
  }

  void sendData(cmd)async{
//    print('发送指令'+cmd.toString());
    await writeC.write(new List.from(cmd));
  }
  void commandControlCenter(){

    sendData([0x02,0x00]);//获取电量
    sendData([0x04,0x00]);//获取设备信息
    statusTimer = new Timer.periodic(Duration(milliseconds: sendTimeout), (timer) {
//      print('isConnected'+isConnected.toString());
      if(isConnected && mounted){
        if(deviceData.status == 0) {
          sendData([0x02, 0x00]);
        }
      }else{
        statusTimer.cancel();
        clearStatusTimer();
      }
    });

  }

  void clearStatusTimer(){
    if(writeC == WriteCharacteristicUUID){
      statusTimer.cancel();

    }

  }
  void getDeviceBattery(){
    //读取设备电量
    List <int>  cmd = [ 0x02,0x00];
    cmdQuene.add(cmd);
    sendData(cmd);
  }
  //  发送指令,判断上一条指令是否完成了，否则就等待
  void sendQueneFront(){

  }
  //小字节在前
  num getTwoByte(data1,data2){
    return data1 + (data2 << 8);
  }
  void getDeviceCharacteristics(data){
    var length = data.length;
    var deviceData1 = deviceData;
    if(length<2){return;}
    switch(data[0]){
      case 2:{
        //电量
        deviceData1.battery = data[1];
        if (mounted) {
          setState(() {
            deviceData = deviceData1;
          });
        }
      }
      break;
      case 4:{
        //实时数据
        var realData = data.sublist(1,length);
        var status = realData[0];
        var times = getTwoByte(realData[1],realData[2]);
        var count =  getTwoByte(realData[3],realData[4]);
        var speed = getTwoByte(realData[5],realData[6]);
        var interruptTime = getTwoByte(realData[7],realData[8]);
        var calories = getTwoByte(realData[11],realData[12]);
        if(deviceData.status == 1 && status == 0 && deviceData.isAlreadyStop == false){
          deviceData1.isAlreadyStop = true;
        }
        deviceData1.status = status;//0结束，1运动中
        deviceData1.times = times;
        deviceData1.calories = calories;//卡路里
        deviceData1.speed = speed;//实时速度
        deviceData1.interruptTime = interruptTime;//绊绳次数
        if(status == 1){
          //还在运动中
          deviceData1.continueCount = getTwoByte(realData[9],realData[10]);
          deviceData1.count = count;//总跳数
        }
      }
      break;
      case 5:{
        //多个历史数据
      }
      break;
      case 6:{
        //厂商名字
        var mfsdata = data.sublist(1,length);
        var string = AsciiDecoder().convert(mfsdata);
        deviceData1.mrfs = string;
        if (mounted) {
          setState(() {
            deviceData = deviceData1;
          });
        }
      }
      break;
      case 7:{
        //设备序列号
        var sdata = data.sublist(1,length);
        var string = AsciiDecoder().convert(sdata);
        deviceData1.serial = string;
        if (mounted) {
          setState(() {
            deviceData = deviceData1;
          });
        }
      }
      break;
      case 8:{
        //设备型号
        var sdata = data.sublist(1,length);
        var string = AsciiDecoder().convert(sdata);
        deviceData1.deviceModel = string;
        if (mounted) {
          setState(() {
            deviceData = deviceData1;
          });
        }
      }
      break;
      case 9:{
        //软件版本
        var sdata = data.sublist(1,length);
        var string = AsciiDecoder().convert(sdata);
        deviceData1.softwareVersion = string;
        if (mounted) {
          setState(() {
            deviceData = deviceData1;
          });
        }
      }
      break;
      case 10:{
        //硬件版本
        var sdata = data.sublist(1,length);
        var string = AsciiDecoder().convert(sdata);
        deviceData1.hardwareVersion = string;
        if (mounted) {
          setState(() {
            deviceData = deviceData1;
          });
        }
      }
      break;
    }

    deviceData = deviceData1;
    eventBus.fire(RopeRealData(deviceData));
  }
  void startDevice(type,gold){
    if(type == 1){
      startDeviceFree();
    }else if(type == 2){
      startDeviceCount(gold);
    }else {
      startDeviceTime(gold*60);
    }
  }
  //  启动自由跳绳
  void startDeviceFree(){
    List <int> cmd = [3,1,0,0];//启动跳绳
    cmdQuene.add(cmd);
    sendData(cmd);

  }
  //  将十进制的数转换成2个字节的16进制数
  List decimalToHexString(number)
  {
    num num1 = (number & 0xff00 ) >> 8;
    num num2 = number & 0x00ff;
    return [num2,num1];
  }

  //  启动定时计数模式
  startDeviceCount(count){
    List <int> cmd = [];
    List num = decimalToHexString(count+1);
    cmd = [3,3,num[0],num[1]];//启动计次跳绳
    sendData(cmd);
    cmdQuene.add(cmd);
  }
  //  启动定时计时模式
  startDeviceTime(second){
    List <int>  cmd = [];
    List num = decimalToHexString(second);
    cmd = [3,2,num[0],num[1]];//启动计时跳绳
    sendData(cmd);
    cmdQuene.add(cmd);
  }
  terminateDevice(){
    // console.log('bluetooth.js terminateDevice')
    List <int>  cmd = [3,6, 0,0];
    sendData(cmd);
    cmdQuene.add(cmd);
    initData();
  }
  haltDevice(){
    List <int>  cmd = [ 3,4,0,0];
    sendData(cmd);
    cmdQuene.add(cmd);
  }
  restoreDevice(){
    List <int>  cmd = [3,5,0,0];
    sendData(cmd);
    cmdQuene.add(cmd);
  }

  @override
  Widget build(BuildContext context){
    var theme = Provider.of<GlobalData>(context,listen: false).globalTheme;

    return Scaffold(
      appBar: AppBar(
          title: Text("智能跳绳",style: TextStyle(color: theme.primaryColor),),
          backgroundColor:theme.accentColor,
          iconTheme: IconThemeData(color: theme.primaryColor,opacity: 30,size: 25)
      ),
        backgroundColor:theme.accentColor,
        body:Container(
          margin: EdgeInsets.only(top: 8,left: 20,right: 20),
          child: Column(
            children: [
              Center(
                child:Image.asset('assets/devices/6.png',width:200,height:200),
              ),
              isTryConnect?
              Container(
                height: 80,
                padding: EdgeInsets.only(left: 20,right: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: theme.dividerColor,
                ),
                child:StreamBuilder<BluetoothDeviceState>(
                  stream: device.state,
                  initialData: BluetoothDeviceState.connecting,
                  builder: (c, snapshot) {
                    switch (snapshot.data) {
                      case BluetoothDeviceState.connected:
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('已连接',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold)),
                            Row(
                              children: [
                                Icon(Icons.battery_std_sharp),
                                Text(deviceData.battery.toString()+'%')
                              ],
                            )
                          ],
                        );
                      case BluetoothDeviceState.connecting:
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('正在连接',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold)),
                            SizedBox(
                              child: CircularProgressIndicator(),
                              height: 20,
                              width: 20,
                            ),
                          ],
                        );

                      default:
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('未连接',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold)),
                            Icon(Icons.bluetooth_disabled)
                          ],
                        );
                    }
                  },
                ),

              ):Container(

              ),
              Container(
                height: 120,
                padding: EdgeInsets.only(left: 20,right: 20),
                margin: EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: theme.dividerColor,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.access_alarm_sharp),
                          Container(
                            child: Text('自由跳绳'),
                            margin: EdgeInsets.only(top: 10),
                          )
                        ],

                      ),
                      onTap: ()=>{
                        Navigator.push( context, MaterialPageRoute(builder: (context) {
                          return RopeSelectModel(type: 1,start: startDevice,shutdown: terminateDevice,halt: haltDevice,restore: restoreDevice,);
                        }))
                      },
                    ),

                    GestureDetector(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.access_alarm_sharp),
                          Container(
                            child: Text('定数计时'),
                            margin: EdgeInsets.only(top: 10),
                          )
                        ],

                      ),
                      onTap: ()=>{
                        Navigator.push( context, MaterialPageRoute(builder: (context) {
                          return RopeSelectModel(type: 2,start: startDevice,shutdown: terminateDevice,halt: haltDevice,restore: restoreDevice,);
                        }))
                      },
                    ),

                    GestureDetector(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.access_alarm_sharp),
                          Container(
                            child: Text('定时计数'),
                            margin: EdgeInsets.only(top: 10),
                          )
                        ],

                      ),
                      onTap: ()=>{
                        Navigator.push( context, MaterialPageRoute(builder: (context) {
                          return RopeSelectModel(type: 3,start: startDevice,shutdown: terminateDevice,halt: haltDevice,restore: restoreDevice,);
                        }))
                      },
                    )
                  ],
                ),

              ),
              Container(
                  height: 180,
                  padding: EdgeInsets.only(left: 20,right: 20),
                  margin: EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: theme.dividerColor,
                  ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      child:Text('设备信息',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18 ),),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('厂家名称',style: TextStyle(fontSize: 16),),
                          Text(deviceData.mrfs,style: TextStyle(color: Color(0xff999999),fontSize: 12),)
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('设备型号',style: TextStyle(fontSize: 16),),
                          Text(deviceData.serial,style: TextStyle(color: Color(0xff999999),fontSize: 12),)
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('软件版本号',style: TextStyle(fontSize: 16),),
                          Text(deviceData.softwareVersion,style: TextStyle(color: Color(0xff999999),fontSize: 12),)
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('硬件版本号',style: TextStyle(fontSize: 16),),
                          Text(deviceData.hardwareVersion,style: TextStyle(color: Color(0xff999999),fontSize: 12),)
                        ],
                      ),
                    )
                  ],
                )
              )
            ],
          ),
        )
    );
  }


}

class RopeSelectModel extends StatefulWidget{

  int type = 1;
  final Function(int,int)  start;
  final VoidCallback shutdown;
  final VoidCallback halt;
  final VoidCallback restore;

  RopeSelectModel({Key ?key ,required this.type,required this.start,required this.shutdown,required this.halt,required this.restore}):super(key:key);
  State<StatefulWidget> createState()=> RopeSelectModelWidget();

}
class RopeSelectModelWidget extends State<RopeSelectModel>{

  int count = 5;
  List <int> countArr = [50,100,300,500,800,1000,1500,2000];
  List <int> timeArr = [1,5,10,20,30,40];

  @override

  showPickerModal(BuildContext context,pickerdata,onPress) {
    new Picker(
        adapter: PickerDataAdapter<String>(pickerdata: pickerdata),
        changeToFirst: true,
        hideHeader: false,
        onConfirm: (Picker picker, List value) {

          onPress(pickerdata[value[0]]);
        }
    ).showModal(context); //_scaffoldKey.currentState);
  }

  void changeCount(value){
    setState(() {
      count = value;
    });

  }

  void gotoSport(type){
    Navigator.pushReplacement( context, MaterialPageRoute(builder: (context) {
      return RopeSport(start: widget.start,shutdown: widget.shutdown,halt: widget.halt,restore: widget.restore,sportType:type,sportGold:count);
    }));
  }

  @override
  Widget build(BuildContext context) {
    if(widget.type == 1){
      return freeSportWidget(context);
    }else if(widget.type == 2){
      return targetCountWidget(context);
    }else if(widget.type == 3){
      return targetTimeWidget(context);
    }
    else{return Container();}
  }

  Widget freeSportWidget(BuildContext context){
    return  Scaffold(
        appBar: AppBar(
            title: Text("自由跳绳",style: TextStyle(color: Color(0xff1c1c1c)),),
            backgroundColor:Color(0xfff2f2f2),
            iconTheme: IconThemeData(color: Color(0xff007dfe),opacity: 30,size: 25)
        ),
        backgroundColor:Colors.white,
        body: Container(
          margin: EdgeInsets.only(top: 10,bottom: 30),
          child: Column(
            children: [
              Column(
                children: [
                  Center(
                    child:Image.asset('assets/devices/ropefree.png',width:180,height:180),
                  ),
                  Center(
                    child:Text('不限制时间和个数，实时记录跳绳数据',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                  ),
                ],
              ),
              Center(
                child: FlatButton(
                  color: Colors.blue,
                  highlightColor: Colors.blue[700],
                  colorBrightness: Brightness.dark,
                  splashColor: Colors.grey,
                  child: Text("开始跳绳"),
                  minWidth: 300,
                  height: 40,
                  shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                  onPressed: () {gotoSport(1);},
                ),
              )


            ],
            crossAxisAlignment:CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
          ),
        )
    );
  }
  Widget targetCountWidget(BuildContext context){
    return  Scaffold(
        appBar: AppBar(
            title: Text("定数计时",style: TextStyle(color: Color(0xff1c1c1c)),),
            backgroundColor:Color(0xfff2f2f2),
            iconTheme: IconThemeData(color: Color(0xff007dfe),opacity: 30,size: 25)
        ),
        backgroundColor:Colors.white,
        body: Container(
          margin: EdgeInsets.only(top: 10,bottom: 30),
          padding: EdgeInsets.only(left: 20,right: 20),
          child: Column(
            children: [
              Column(
                children: [
                  Center(
                    child:Image.asset('assets/devices/ropecount.png',width:180,height:180),
                  ),
                  Center(
                    child:Text('记录限制个数内跳绳的时长，完成个数后自动结束运动',style: TextStyle(fontSize: 16),),
                  ),
                  Row(
                    children: [
                      Text('设置跳绳数量'),
                      FlatButton.icon(
                        label: Text(count.toString()),
                        icon: Icon(Icons.add),
                        onPressed: (){
                          showPickerModal(context,countArr,(value)=>{
                            changeCount(value)
                          });

                        },
                      ),
                    ],
                    crossAxisAlignment:CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  )
                ],
              ),
              Center(
                child: FlatButton(
                  color: Colors.blue,
                  highlightColor: Colors.blue[700],
                  colorBrightness: Brightness.dark,
                  splashColor: Colors.grey,
                  child: Text("开始跳绳"),
                  minWidth: 300,
                  height: 40,
                  shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                  onPressed: () {
                    gotoSport(2);
                  },
                ),
              )


            ],
            crossAxisAlignment:CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
          ),
        )
    );
  }

  Widget targetTimeWidget(BuildContext context){
    return  Scaffold(
        appBar: AppBar(
            title: Text("定数计时",style: TextStyle(color: Color(0xff1c1c1c)),),
            backgroundColor:Color(0xfff2f2f2),
            iconTheme: IconThemeData(color: Color(0xff007dfe),opacity: 30,size: 25)
        ),
        backgroundColor:Colors.white,
        body: Container(
          margin: EdgeInsets.only(top: 10,bottom: 30),
          padding: EdgeInsets.only(left: 20,right: 20),
          child: Column(
            children: [
              Column(
                children: [
                  Center(
                    child:Image.asset('assets/devices/ropetime.png',width:180,height:180),
                  ),
                  Center(
                    child:Text('记录限制时长内跳绳对个数，达到时长后自动结束运动',style: TextStyle(fontSize: 16),),
                  ),
                  Row(
                    children: [
                      Text('设置跳绳时长,单位分钟'),
                      FlatButton.icon(
                        label: Text(count.toString()),
                        icon: Icon(Icons.add),
                        onPressed: (){
                          showPickerModal(context,timeArr,(value)=>{
                            changeCount(value)
                          });

                        },
                      ),
                    ],
                    crossAxisAlignment:CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  )
                ],
              ),
              Center(
                child: FlatButton(
                  color: Colors.blue,
                  highlightColor: Colors.blue[700],
                  colorBrightness: Brightness.dark,
                  splashColor: Colors.grey,
                  child: Text("开始跳绳"),
                  minWidth: 300,
                  height: 40,
                  shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                  onPressed: () {
                    gotoSport(3);
                  },
                ),
              )


            ],
            crossAxisAlignment:CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
          ),
        )
    );
  }
}

class RopeSport extends StatefulWidget{
  final Function(int,int)  start;
  final VoidCallback shutdown;
  final VoidCallback halt;
  final VoidCallback restore;
  final int sportType;
  final int sportGold;
  RopeSport({Key ?key ,required this.start,required this.shutdown,required this.halt,required this.restore,required this.sportType,required this.sportGold}):super(key:key);
  @override
  State<StatefulWidget> createState()=> RopeSportWidget();
}
class RopeSportWidget extends State<RopeSport>{

  int countdownNumber = 5;
  bool isShowCoutndown = true;
  bool isPause = false;
  TextStyle uniStyle = TextStyle(fontSize: 16,color: Colors.white);
  TextStyle dataItemStyle = TextStyle(color: Colors.white,fontSize: 26,fontFamily: 'DINCond-Bold');
  late StreamSubscription subscription;
  late RopeData ropeRealData ;
  late BuildContext Rcontext;
  bool isActiveStop = false;
  late Timer countdownTimeout;
  late Timer countdownTimer;
  @override
  void initState() {
    ropeRealData = new RopeData();
    super.initState();
    subscription = eventBus.on<RopeRealData>().listen((event) {
      if(event.ropeRealData.isAlreadyStop && !isActiveStop){
        shutdownDevice();
      }
      setState((){
        ropeRealData = event.ropeRealData;
      });


    });
    showCountDown();

  }
  @override
  void dispose() {
    subscription.cancel();//State销毁时，清理注册
    super.dispose();
  }
  void clearTimer(){
    countdownTimer.cancel();
    countdownTimeout.cancel();
  }
  void showCountDown(){
    voice.Speak('5');
    const timeout = const Duration(seconds: 1);
    countdownTimer  = new Timer.periodic(timeout, (timer) { //callback function
      int number = countdownNumber -1;
      voice.Speak(number.toString());
      setState(() {
        countdownNumber = number;
      });

    });

    const timeout2 = const Duration(seconds: 5);
    countdownTimeout = new Timer(timeout2, () {
      countdownTimer.cancel();
      widget.start(widget.sportType,widget.sportGold);
      setState(() {
        isShowCoutndown = false;
      });
      music.playMusic('https://api.fitshow.com/api/video/leisurely.mp3');
    });
  }
  haltDevice(){
    voice.Speak('运动已暂停');
    setState(() {
      isPause = true;
    });
    widget.halt();
    music.pauseMusic();
  }
  restoreDevice(){
    voice.Speak('运动已恢复');

    setState(() {
      isPause = false;
    });
    widget.restore();
    music.replayMusic();
  }
  shutdownDevice(){
    isActiveStop = true;
    voice.Speak('运动已结束');
    Navigator.pop(Rcontext);
    widget.shutdown();
    music.stopPlayMusic();
  }

  @override
  Widget build(BuildContext context){
    Rcontext = context;
    if(isShowCoutndown){
      return Countdown(context);
    }else{
      return SportBody(context);
    }
  }

  Widget Countdown(BuildContext context){
    return Material(
      child: Container(
        color: Color.fromRGBO(244, 64, 4, 1),
        width: MediaQuery.of(context).size.width,
        child: Center(
        child: Text(countdownNumber.toString(),style: TextStyle(color: Colors.white,fontSize: 188),),
        ),
      )
    );

  }

  String formateTime(times){
    int secondTime = times;// 秒
    int minuteTime = 0;// 分
    int hourTime = 0;// 小时
    String ss ='',ms = '',hs = '';
    if(secondTime > 60) {//如果秒数大于60，将秒数转换成整数
      //获取分钟，除以60取整数，得到整数分钟
      minuteTime = secondTime  ~/ 60;
      //获取秒数，秒数取佘，得到整数秒数
      secondTime = secondTime % 60;
      //如果分钟大于60，将分钟转换成小时
      if(minuteTime > 60) {
        hourTime = minuteTime  ~/ 60;
        if(hourTime<10){
          hs = '0'+hourTime.toString();

        }
        minuteTime = minuteTime % 60;
        if(minuteTime<10){
          ms = '0' + minuteTime.toString();
        }

      }else{
        hs = '00';
        if(minuteTime<10){
          ms = '0'+minuteTime.toString();
        }

      }
    }else{
      hs = '00';
      ms = '00';
      ss = secondTime.toString();
    }
    if(secondTime<10){
      ss = '0'+secondTime.toString();
    }
    String result = hs + ':' + ms + ':' + ss;
    return result;
  }
  Widget SportBody(BuildContext context){
    return Material(
        child: Container(
          color: Colors.black,
          padding: EdgeInsets.only(top: 150),
          child: Column(
            children: [
              Row(
                crossAxisAlignment:CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(ropeRealData.count.toString(),style: TextStyle(color: Colors.white,fontSize: 56,fontFamily: 'DINCond-Bold'),),
                  Container(
                    child:Text('个',style: uniStyle,),
                    margin: EdgeInsets.only(left: 10,top: 10),
                  )
                ],
              ),
              Container(
                margin: EdgeInsets.only(top:50),
                padding: EdgeInsets.only(left: 20,right: 20),
                child: Row(
                  crossAxisAlignment:CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('运动时间',style: TextStyle(color: Colors.white,fontSize: 16,),),
                        Container(
                          child: Text(formateTime(ropeRealData.times),style: dataItemStyle),
                          margin: EdgeInsets.only(top:10),
                        )
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('热量',style: TextStyle(color: Colors.white,fontSize: 16,),),
                        Container(
                          margin: EdgeInsets.only(top:10),
                          child: Row(
                            children: [
                              Text(ropeRealData.calories.toString(),style: dataItemStyle),
                              Text('千卡',style: uniStyle,),
                            ],
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),

              Container(
                margin: EdgeInsets.only(top:20),
                padding: EdgeInsets.only(left: 20,right: 40),
                child: Row(
                  crossAxisAlignment:CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('速度',style: TextStyle(color: Colors.white,fontSize: 16,),),
                        Container(
                          child: Row(
                            children: [
                              Text(ropeRealData.speed.toString(),style: dataItemStyle),
                              Text('个/分钟',style: uniStyle,),
                            ],
                          ),
                          margin: EdgeInsets.only(top:10),
                        )
                      ],
                    ),
                    Column(
                      children: [
                        Text('绊绳',style: TextStyle(color: Colors.white,fontSize: 16,),),
                        Container(
                          margin: EdgeInsets.only(top:10),
                          child: Row(
                            children: [
                              Text(ropeRealData.interruptTime.toString(),style: dataItemStyle),
                              Text('次',style: uniStyle,),
                            ],
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top:20),
                padding: EdgeInsets.only(left: 20,right: 20),
                child: Row(
                  crossAxisAlignment:CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('当前连跳',style: TextStyle(color: Colors.white,fontSize: 16,),),
                        Container(
                          child: Row(
                            children: [
                              Text(ropeRealData.continueCount.toString(),style: dataItemStyle),
                              Text('个',style: uniStyle,),
                            ],
                          ),
                          margin: EdgeInsets.only(top:10),
                        )
                      ],
                    ),
                    Container()

                  ],
                ),
              ),

              SportBottom(context),

            ],
          )
        )
    );

  }

  Widget SportBottom(BuildContext context){
    if(isPause){
      return ScaleAnimationRoute(leftPress:shutdownDevice,rightPress:restoreDevice);
    }else{
      return  Container(
        margin: EdgeInsets.only(top: 80),
        child: FlatButton(
          color: Colors.red[700],
          highlightColor: Colors.redAccent,
          colorBrightness: Brightness.dark,
          child: Icon(Icons.pause),
          minWidth: 80,
          height: 80,
          shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(80)),
          onPressed: () {
            haltDevice();
          },
        ),
      );
    }
  }
}



class ScaleAnimationRoute extends StatefulWidget {
  final VoidCallback leftPress;
  final VoidCallback rightPress;
  ScaleAnimationRoute({Key ?key ,required this.leftPress,required this.rightPress}):super(key:key);


  @override
  _ScaleAnimationRouteState createState() => new _ScaleAnimationRouteState();
}

//需要继承TickerProvider，如果有多个AnimationController，则应该使用TickerProviderStateMixin。
class _ScaleAnimationRouteState extends State<ScaleAnimationRoute>  with TickerProviderStateMixin{

  late Animation<double> animation;
  late AnimationController controller;

  initState() {
    super.initState();
    controller = new AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    //图片宽高从0变到300
    animation = new Tween(begin: 0.0, end: 120.0).animate(controller)
      ..addListener(() {
        setState(()=>{});
      });
    //启动动画(正向执行)
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 80),
      child: Row(
        crossAxisAlignment:CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              child: FlatButton(
                color: Colors.red[700],
                highlightColor: Colors.redAccent,
                colorBrightness: Brightness.dark,
                child: Icon(Icons.stop_rounded,size: 38,),
                minWidth: 80,
                height: 80,
                shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(80)),
                onPressed: () {
                  widget.leftPress();
                },
              )
          ),
          Container(
              margin: EdgeInsets.only(left:animation.value),
              child: FlatButton(
                color: Colors.green[700],
                highlightColor: Colors.greenAccent,
                colorBrightness: Brightness.dark,
                child: Icon(Icons.play_arrow_rounded,size: 38,),
                minWidth: 80,
                height: 80,
                shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(80)),
                onPressed: () {
                  widget.rightPress();

                },
              )
          ),

        ],
      ),
    );
  }

  dispose() {
    //路由销毁时需要释放动画资源
    controller.dispose();
    super.dispose();
  }
}
