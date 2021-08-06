import 'package:flutter/material.dart';
import 'package:myflutter/common/eventBus.dart';

import 'package:flutter_blue/flutter_blue.dart';

import 'dart:async';
var  ServiceUUID = '0000FFF0-0000-1000-8000-00805F9B34FB';//服务id
var WriteCharacteristicUUID = '0000FFF2-0000-1000-8000-00805F9B34FB';//写操作uuid
var NotifyCharactersticUUID = '0000FFF1-0000-1000-8000-00805F9B34FB';//状态uuid

FlutterBlue flutterBlue = FlutterBlue.instance;
//引入封装的e vent_bus.dart 文件

// 调用 eventBus.fir 发送事件信息

class SEARCHBLUETOOTH extends Notification{
  int searchTime = 7;//搜索的时长
  late StreamSubscription _subscription;
  var phoneState = FlutterBlue.instance.state;//手机蓝牙的开关


  void startBluetoothDevicesDiscovery(){
    print('startBluetoothDevicesDiscovery');
    flutterBlue.startScan(timeout: Duration(seconds: searchTime),withServices:[Guid(ServiceUUID)]);
    onBluetoothDeviceFound();
  }

  void stopBluetoothDevicesDiscovery(){
    flutterBlue.stopScan();

  }
  void onBluetoothDeviceFound(){
    _subscription = flutterBlue.scanResults.listen((results) {
      // do something with scan results
      for (ScanResult r in results) {
        if(r.device.name.indexOf('FS')>-1){
          eventBus.fire(EventFn(r));
        }
        print('${r.device.name} found! rssi: ${r.rssi}');
      }
    });
  }

}
