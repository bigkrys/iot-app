import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myflutter/routes/deviceslist/addDevices.dart';
import '../login.dart';
import '../../api/api.dart';
import '../../models/bindDevice.dart';
import '../../models/user.dart';
import '../../globalData.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../common/defineDevice.dart';

var homecolor = Color(0xff8d4b0e);

class DeviceInfoItem extends StatelessWidget{
  final BindDevice deviceItem;
  DeviceInfoItem({Key ?key ,required this.deviceItem }):super(key:key);
  void onPressed(context){
    Navigator.push( context, MaterialPageRoute(builder: (context) {
      return GetDeviceType(deviceItem.deviceType,deviceItem.bluetoothMacAddr,deviceItem.deviceLocalName);
    }));
  }

  @override Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 150,
      child: GestureDetector(
        child:Center(
          child: Container(
            width: 150,
            height: 150,
            margin: EdgeInsets.all(8),
            child: DeviceItemUI(context),
            decoration: new BoxDecoration(
              color: Color(0xffffffff),
              borderRadius: BorderRadius.all(Radius.circular(4.0)),
            ),

          ),
        ),
        onTap: () => {onPressed(context)},
      ),
    );
  }

  Widget DeviceItemUI(BuildContext context){
    return Column(
        children: <Widget>[
          Text(deviceItem.devcieName),
          Text(deviceItem.deviceLocalName),
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



class UserHeader extends StatelessWidget{
  final User userInfo;
  final VoidCallback onPressed;
  UserHeader({Key ?key ,required this.userInfo ,required this.onPressed}):super(key:key);
  @override
  Widget build(BuildContext context) {

    return Row(
      children: <Widget>[
        Column(
          children: [
            userHome(context),
//            userScene(context)
          ],
          crossAxisAlignment:CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        ),
        IconButton(onPressed: ()=>{
          Navigator.push( context,
            MaterialPageRoute(builder: (context) {
            return AddDevices();
            }))
        }, icon: Icon(Icons.add,color :homecolor))
      ],
      crossAxisAlignment:CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
    );

  }

  Widget userHome(BuildContext context){
    return GestureDetector(
      child: Row(
        children: <Widget>[
          Text(userInfo.nickname+'的家',style: TextStyle(
            color: homecolor,
            fontSize: 18.0,
          ),),
          Container(
            child: Icon(Icons.arrow_forward_ios,color: homecolor,size: 16,),
            margin: EdgeInsets.only(left:10),
          )
        ],
      ),
      onTap: () => { onPressed()},


    );
  }


}



class Home extends StatefulWidget{
  @override
  State<StatefulWidget> createState()=> HomeWidget();
}


class HomeWidget extends  State<Home> with AutomaticKeepAliveClientMixin{

  @override
  bool get wantKeepAlive => true;

  @override
  void initState(){

    print('initState');

    super.initState();
    InitLocalData();
  }

  List <BindDevice> binddevice = <BindDevice> [];
  late BuildContext Gcontext;
  void getBindDevice() async{
    var response = await NetUtils.post(NetUtils.getBindDevice, {
      "userId":Provider.of<GlobalData>(Gcontext,listen: false).user.id,
    });
    print('response'+response.toString());

    if(response['code'] == 200){
      binddevice = [];
      for(var data in response['data']){
        BindDevice device = BindDevice.fromJson(data);
        binddevice.add(device);
      }
      print('binddevice'+binddevice.toString());
      Provider.of<GlobalData>(Gcontext,listen: false).updateGlobalBindDevice(binddevice);
    }else{

    }
  }
  void InitLocalData()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasLogin = prefs.getBool('myflutter_hasLogin')!;
    if(hasLogin){
      String UserInfo = prefs.getString('myflutter_userInfo')!;
      print('userinfo'+UserInfo.toString());
      Provider.of<GlobalData>(Gcontext,listen: false).UpdateUserInfo(User.fromJson(json.decode(UserInfo)));
      getBindDevice();

    }

  }


  List<Widget> _getData(context,devices){
    return devices.map<Widget>((item) => DeviceInfoItem(deviceItem: item)).toList();
  }


  @override
  Widget build(BuildContext context) {
    Gcontext = context;
    return context.watch<GlobalData>().hasLogin?Container(
      margin: EdgeInsets.fromLTRB(8, 80, 8, 0),
      child:Column(
          children: [
            UserHeader(userInfo:context.watch<GlobalData>().user,onPressed:()=>{}),
            Container(
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
                      height: 500,
                      child:GridView.count(
                          //水平子Widget之间间距
                          crossAxisSpacing: 5.0,
                          //垂直子Widget之间间距
                          mainAxisSpacing: 30.0,
                          //GridView内边距
                          padding: EdgeInsets.all(10.0),
                          //一行的Widget数量
                          crossAxisCount: 2,
                          //子Widget宽高比例
//                          childAspectRatio: 2.0,
                          //子Widget列表
                          children: this._getData(context,context.watch<GlobalData>().gloablBindDeviceList),
                        ),

                    ),
                  )
                ],
              ),
            )
          ],
        ),
    ):Scaffold(
      backgroundColor:Color(0xfffffcfcfc),

      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('我的家',style: TextStyle(fontSize: 34,color: homecolor),),
            Container(
              width: 280,
              height: 120,
              margin: EdgeInsets.only(top: 100,bottom: 100),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('添加设备',style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold,color: homecolor),),
                  Container(
                      margin: EdgeInsets.only(top: 10),
                      child: Text('打造全景体验',style: TextStyle(color: homecolor),)
                  )
                ],
              ),
              decoration: new BoxDecoration(
                color: Colors.white,
                border: Border.all(color: homecolor),
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
            ),

            GestureDetector(
              child: Container(
                width: 180,
                height: 60,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('登录',style: TextStyle(color: homecolor,fontSize: 16),),
                  ],
                ),
                decoration: new BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: homecolor),
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
              ),
              onTap: () => {
                Navigator.push( context,
                    MaterialPageRoute(builder: (context) {
                      return Login();
                    }))
              },

            )
          ],
        ),
      ),
    );
  }
}

