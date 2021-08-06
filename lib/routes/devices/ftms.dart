
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:async';
import 'dart:convert';
import 'package:event_bus/event_bus.dart';
import 'package:myflutter/common/voice.dart';
import 'package:myflutter/common/music.dart';
import 'package:flutter_picker/flutter_picker.dart';


class FTMS extends StatefulWidget {
  FTMS({Key? key, required this.deviceId, required this.deviceLocalName}) : super(key: key);
  late BluetoothDevice device;
  String deviceId = '';
  String deviceLocalName = '';
  @override
  State<StatefulWidget> createState()=> FTMSWidget();
}
class FTMSWidget extends State<FTMS>{

  @override
  void dispose() {
    super.dispose();
    //断连
  }


  @override
  Widget build(BuildContext context){
    return Scaffold(
        appBar: AppBar(
            title: Text("ftms",style: TextStyle(color: Color(0xff1c1c1c)),),
            backgroundColor:Color(0xfff8f8f8),
            iconTheme: IconThemeData(color: Color(0xff007dfe),opacity: 30,size: 25)
        ),
        backgroundColor:Color(0xfff8f8f8),
        body:Container(
          margin: EdgeInsets.only(top: 8,left: 20,right: 20),
          child: Column(
            children: [
              Center(
                child:Image.asset('assets/devices/6.png',width:200,height:200),
              ),
              Container(
                height: 80,
                padding: EdgeInsets.only(left: 20,right: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                child:Text('ftms'),

              ),
           ]
          ),
        )
    );
  }


}
