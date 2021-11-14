
import 'package:flutter/material.dart';
import 'package:myflutter/widgets/WaterRipplePage.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:provider/provider.dart';
import '../../models/bindDevice.dart';
import '../../models/deviceListItem.dart';
import '../../api/api.dart';
import '../../globalData.dart';
import '../../common/ui.dart';
List <DeviceListItem> globalDevice = <DeviceListItem>[];
UI ui = new UI();


var  ServiceUUID = '0000FFF0-0000-1000-8000-00805F9B34FB';//服务id
var WriteCharacteristicUUID = '0000FFF2-0000-1000-8000-00805F9B34FB';//写操作uuid
var NotifyCharactersticUUID = '0000FFF1-0000-1000-8000-00805F9B34FB';//状态uuid
var homecolor = Color(0xff8d4b0e);


class DeviceItem{
  late ScanResult result;
  late String deviceName ;
  late String deviceImg;
  late String devId;
  late int productId = 0 ;
  late String wapUrl;
  late String deviceType;
}



class AddDevices extends StatefulWidget {
  @override
  State<StatefulWidget> createState()=> AddDeviceState();
}

FlutterBlue flutterBlue = FlutterBlue.instance;

class AddDeviceState extends State<AddDevices> {
  int searchTime = 15;//搜索的时长
  List <DeviceItem> globalShowDevice = <DeviceItem> [];
  late BuildContext Gcontext;
  @override
  void initState() {
    super.initState();
    getDeviceList();
  }
  void getDeviceList()async{
    var response = await NetUtils.post(NetUtils.getProductList, {});
    try {
      globalDevice = [];
      for(var data in response['data']){
        DeviceListItem deviceListitem = DeviceListItem.fromJson(data);
        globalDevice.add(deviceListitem);
      }
      searchDevice();
    } catch (err) {
      return response['message'];
    }
  }

  void searchDevice(){
    print('开始搜索...');
    flutterBlue.startScan(timeout: Duration(seconds: searchTime),withServices:[Guid(ServiceUUID)]);
    // 监听扫描结果
    flutterBlue.scanResults.listen((results) {
      getSearchResult(results);
    });
  }
  void getSearchResult(results){

    List <DeviceItem> _globalShowDevice = <DeviceItem> [];

    for(ScanResult result in results){
      for(DeviceListItem deviceItem in globalDevice){
        if(result.device.name.length > 0 && result.device.name.toString().indexOf(deviceItem.name)>-1){
          DeviceItem device = new DeviceItem();
          device.result = result;
          device.deviceName = deviceItem.displayName;
          device.deviceImg = deviceItem.imageUrl;
          device.devId = deviceItem.id;
          device.productId = 0;
          device.wapUrl = deviceItem.wapUrl;
          device.deviceType = deviceItem.type;
          _globalShowDevice.add(device);
        }
      }
    }

    if(mounted){
      setState(() {
        globalShowDevice = _globalShowDevice;
      });
    }



  }

  void stopScan(){
    print('停止搜索...');
    flutterBlue.stopScan();
  }

  void connectDevice(DeviceItem device) async{
    stopScan();
    var params = {
      "deviceId":device.result.device.id.toString(),
      "devId":device.devId,
      "productId":'1',
      "userId": Provider.of<GlobalData>(Gcontext,listen: false).user.id,
      "devcieName":device.deviceName,
      "deviceAlias":device.result.device.name.toString(),
      "deviceLocalName":device.result.device.name.toString(),
      "bluetoothMacAddr":device.result.device.id.toString(),
      "wapUrl":device.wapUrl,
      "deviceType":device.deviceType,
      "imageUrl":device.deviceImg,
      "wifiMacAddr":'-',
      "wifiConfig":"{}",
    };
    print('params'+params.toString());
    var response = await NetUtils.post(NetUtils.bingeDevice, params);
    print('response'+response.toString());
    if(response['code'] == 200){
      //绑定成功 提示 并返回到首页
      List <BindDevice> binddevice = Provider.of<GlobalData>(Gcontext,listen: false).gloablBindDeviceList;
      binddevice.add(BindDevice.fromJson(response['data']));
      Provider.of<GlobalData>(Gcontext,listen: false).updateGlobalBindDevice(binddevice);
      Navigator.pop(Gcontext);

    } else if(response['code'] == 301){
      //已经绑定过设备 提示 并返回
      ui.alertDialogAndBack(Gcontext,'提示','已经绑定过该设备',()=>{
        Navigator.pop(Gcontext)
      });
    }else {
      //提示弹窗
      ui.alertDialogAndBack(Gcontext,'提示',response['message'],()=>{
        Navigator.pop(Gcontext)
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    flutterBlue.reinitialize();

    //取消订阅
  }

  List<Widget> _getData(data){
    List<Widget> list = new List.generate(data.length,(index){
      return ScanResultTile(device: data[index],connectDevice:connectDevice);
    });
    return list;
  }

  Widget build(BuildContext context) {
    var theme = Provider.of<GlobalData>(context,listen: false).globalTheme;
    Gcontext = context;
    return Scaffold(
      appBar: AppBar(
          title: Text("添加设备",style: TextStyle(color: theme.primaryColor),),
          backgroundColor:theme.accentColor,
          iconTheme: IconThemeData(color: theme.primaryColor,opacity: 30,size: 25)
      ),
      backgroundColor:theme.backgroundColor,
      body: Container(
        child: Column(
          children: [
            StreamBuilder<bool>(
              stream: flutterBlue.isScanning,
              initialData: false,
              builder: (c, snapshot) {
                if (snapshot.data!) {
                  return Column(
                      children: [
                        Center(
                          child:Container(height: 300, width: 300, child: WaterRipple(color: theme.primaryColor,)),
                        ),
                        Text('正在扫描',style: TextStyle(fontSize: 22),),
                        Text('请确保智能设备已连接电源，且位于手机附近',style: TextStyle(color: Color(0xff979797),fontSize: 14))
                      ],
                    );
                } else {
                  return
                    GestureDetector(
                      child:Center(
                        child: Container(
                          width: 100,
                          height: 40,
                          child: Center(child: Text('重新搜索',style: TextStyle(color: theme.backgroundColor))),
                          decoration: new BoxDecoration(
                            color: theme.primaryColor,
                            borderRadius: BorderRadius.all(Radius.circular(4.0)),
                          ),

                        ),
                      ),
                      onTap: () => { searchDevice()},
                    );
                }
              },
            ),
            Container(
                margin: EdgeInsets.only(top: 8,left: 20,right: 20),
                child: SingleChildScrollView(
                child: Column(
                  children:this._getData(globalShowDevice)
                ),

              ),
            ),

            Container()
//            Column(
//              children: [
//                Text('若添加蓝牙耳机，需先前往"系统设置" > "蓝牙" 连接耳机',style: TextStyle(color: Color(0xffa1a1a1),fontSize: 12)),
//                Container(
//                  child: Row(
//                    crossAxisAlignment:CrossAxisAlignment.start,
//                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                    children: [
//                      GestureDetector(
//                        child:Center(
//                          child: Container(
//                            width: 100,
//                            height: 40,
//                            child: Center(child: Text('手动添加',style: TextStyle(color: Color(0xff276ac0)))),
//                            decoration: new BoxDecoration(
//                              color: Color(0xfff2f2f2),
//                              borderRadius: BorderRadius.all(Radius.circular(4.0)),
//                            ),
//
//                          ),
//                        ),
//                        onTap: () => {
//                        Navigator.push( context,
//                        MaterialPageRoute(builder: (context) {
//                        return DevicesList();
//                        }))
//                        },
//                      ),
//                      GestureDetector(
//                        child:Center(
//                          child: Container(
//                            width: 100,
//                            height: 40,
//                            child: Center(child: Text('扫码添加',style: TextStyle(color: Color(0xff276ac0)))),
//                            decoration: new BoxDecoration(
//                              color: Color(0xfff2f2f2),
//                              borderRadius: BorderRadius.all(Radius.circular(4.0)),
//                            ),
//
//                          ),
//                        ),
//                        onTap: () => { },
//                      )
//                    ],
//                  ),
//                  margin: EdgeInsets.only(top: 8,left: 30,right: 30),
//                )
//              ],
//
//            )
          ],
          crossAxisAlignment:CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        ),
        margin: EdgeInsets.only(top: 10,bottom: 3),
      )
    );
  }
}

class ScanResultTile extends StatelessWidget {
   ScanResultTile({Key? key, required this.device,required this.connectDevice,})
      : super(key: key);
   final Function(DeviceItem) connectDevice;
   final DeviceItem device;


  @override
  Widget build(BuildContext context) {
    var theme = Provider.of<GlobalData>(context,listen: false).globalTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Row(
          children: <Widget>[
            Image.network(device.deviceImg,width:40,height:40),
            Text(
              device.deviceName+' '+device.result.device.name,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),

        GestureDetector(
          child:Center(
            child: Container(
              width: 60,
              height: 30,
              child: Center(child: Text('连接',style: TextStyle(color: theme.primaryColor),)),
              decoration: new BoxDecoration(
                color: Color(0xfff2f2f2),
                borderRadius: BorderRadius.all(Radius.circular(4.0)),
              ),
            ),
          ),
          onTap: () => {
            connectDevice(this.device)
          },
        )
      ],
    );
  }
}

class DeviceInfoItem extends StatelessWidget{
  final DeviceListItem deviceItem;
  DeviceInfoItem({Key ?key ,required this.deviceItem ,required this.onPressed}):super(key:key);
  final VoidCallback onPressed;
  @override Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      child: GestureDetector(
        child:Center(
          child: Container(
            width: 100,
            height: 100,
            margin: EdgeInsets.all(8),
            child: DeviceItemUI(context),
            decoration: new BoxDecoration(
              color: Color(0xffffffff),
              borderRadius: BorderRadius.all(Radius.circular(4.0)),
            ),

          ),
        ),
        onTap: () => { onPressed()},
      ),
    );
  }

  Widget DeviceItemUI(BuildContext context){
    return Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(2),
            child: Text(deviceItem.displayName,maxLines:1),
          ),
          Padding(
              padding:EdgeInsets.all(2),
              child:ClipRRect(
                  borderRadius:BorderRadius.circular(8),
                  child:Image.network(deviceItem.imageUrl,width:40,height:40)
              )
          )
        ],
        crossAxisAlignment:CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly
    );
  }
}



class DeviceListWidget extends StatelessWidget{
  final deviceList;
  DeviceListWidget({Key?key,required this.deviceList});
  List<Widget> _getData(){
    return this.deviceList.map<Widget>((item) => DeviceInfoItem(deviceItem: item,onPressed: ()=>{print('点击的是${item.id}')})).toList();
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top:12),
      alignment:Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text('设备',style: TextStyle(fontSize: 14,color: homecolor),),
          Container(
            margin: EdgeInsets.only(top:8),
            child: Container(
              margin: EdgeInsets.only(top: 8),
              height: 300,
              child: Wrap(
                spacing: 2, //主轴上子控件的间距
                runSpacing: 5, //交叉轴上子控件之间的间距
                children: this._getData(), //要显示的子控件集合
              ),
            ),
          )
        ],
      ),
    );
  }
}


class DevicesList extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text("设备列表",style: TextStyle(color: Color(0xff1c1c1c)),),
            backgroundColor:Color(0xfff2f2f2),
            iconTheme: IconThemeData(color: Color(0xff007dfe),opacity: 30,size: 25)
        ),
        backgroundColor:Colors.white,
        body: SingleChildScrollView(
          child:DeviceListWidget(deviceList:globalDevice),
          ),
        );

  }

}
