import 'package:flutter/material.dart';
import 'package:myflutter/routes/devices/rope.dart';
import 'package:myflutter/routes/devices/ftms.dart';
dynamic  GetDeviceType(type,deviceId,deviceLocalName){
  if(type == '6'){
    return new Rope(deviceId: deviceId,deviceLocalName: deviceLocalName,);
  }else{
//    return new Rope(deviceId: deviceId,deviceLocalName: deviceLocalName,);

    return new FTMS(deviceId: deviceId,deviceLocalName: deviceLocalName,);
  }
}