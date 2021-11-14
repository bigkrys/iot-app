import 'package:flutter/material.dart';

// 浅色主题
final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,//亮色主题
    accentColor: Colors.white,//(按钮)Widget前景色
    primaryColor: Color(0xff8d4b0e),//主题色
    iconTheme:IconThemeData(color: Colors.grey),//icon主题
    backgroundColor:Color(0xffffffff),
    dividerColor: Color(0xfff8f8f8),
    textTheme: TextTheme(subtitle1  : TextStyle(color: Colors.black))//文本主题
);

// 深色主题
final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,//深色主题
    accentColor: Color(0xff39393d),//(按钮)Widget前景色
    primaryColor: Color(0xff8d4b0e),//主题色
    backgroundColor:Color(0xff434343),
    dividerColor: Color(0xff3c3c3c),
    iconTheme:IconThemeData(color: Color(0xff8d4b0e)),//icon主题色
    textTheme: TextTheme(bodyText2 : TextStyle(color: Colors.white))//文本主题色
);
