import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myflutter/models/index.dart';
import 'package:flutter/material.dart';

import './common/theme.dart';
class GlobalData with ChangeNotifier, DiagnosticableTreeMixin {

  //是否已经登录
  bool _hasLogin = false;

  //用户信息
  late User _user;

   List <DeviceListItem> _globalDeviceList = <DeviceListItem>[];

   List <BindDevice> _gloablBindDeviceList = <BindDevice>[];

   List <BluetoothDevice> _globalConnectedDevices = <BluetoothDevice> [];

  int _count = 0;

  int _themeMode = 0;//0是浅色模式，1是深色模式

  ThemeData _globalTheme = lightTheme;

  bool get hasLogin => _hasLogin;

  int get count => _count;

  User get user => _user;

  List <DeviceListItem> get globalDeviceList => _globalDeviceList;

  List <BindDevice> get gloablBindDeviceList => _gloablBindDeviceList;

  List <BluetoothDevice> get globalConnectedDevices => _globalConnectedDevices;

  int get themeMode => _themeMode;
  ThemeData get  globalTheme => _globalTheme;

  void UpdateUserInfo(User user){
    _user = user;
    _hasLogin = true;
    notifyListeners();
    this.setUserToLocal(user,true);
  }
  void Logout(){
    _hasLogin = false;
    this.setUserToLocal(this._user,false);
    notifyListeners();

  }

  void UpdateGlobalDeviceList(List <DeviceListItem> deviceList){
    _globalDeviceList = deviceList;
    String deviceS = json.encode(deviceList);
    this.setDataToLocal(0,'myflutter_globalDeviceList',deviceS);
    notifyListeners();

  }
  void updateGlobalBindDevice(List <BindDevice> bindDevice){
    _gloablBindDeviceList = bindDevice;
    String deviceS = json.encode(bindDevice);
    this.setDataToLocal(0,'myflutter_globalBindDevice',deviceS);
    notifyListeners();
  }

  void addDeviceToConnectedDevices(device){
    _globalConnectedDevices.add(device);
  }

  void increment() {
    _count++;
    notifyListeners();
  }

  void setUserToLocal(User user,isLogin){
    if(isLogin){
      String userS = json.encode(user);
      this.setDataToLocal(0,'myflutter_userInfo',userS);
      this.setDataToLocal(1,'myflutter_hasLogin',true);
    }else{
      this.setDataToLocal(1,'myflutter_hasLogin',false);

    }
  }

  void setDataToLocal(type,key,value)async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(type == 0){
      await prefs.setString(key, value);
    }else if(type == 1){
      await prefs.setBool(key, value);
    }
  }

  void changeThemeMode(){
    if(_themeMode == 1){
      _themeMode = 0;
      _globalTheme = lightTheme;
    }else{
      _themeMode = 1;
      _globalTheme = darkTheme;
    }
    notifyListeners();
  }

  /// Makes `Counter` readable inside the devtools by listing all of its properties
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('count', count));

  }
}