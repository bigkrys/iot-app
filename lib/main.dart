import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'routes/home/home.dart';
import 'routes/mine/minehome.dart';
import 'globalData.dart';

import 'routes/deviceslist/addDevices.dart';
import 'routes/login.dart';

import 'routes/webview/webview.dart';

void main() {
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GlobalData()),
      ],
      child: Consumer<GlobalData>(
      builder: (context, darkModeProvider, _) {
        return MaterialApp(
            title: 'krysiot',
            theme: Provider.of<GlobalData>(context,listen: false).globalTheme,
            home: MyHomePage(),
            routes:{
              "Home":(context)=>Home(),
              "Mine":(context)=>MineHome(),
              "AddDevices":(context)=>AddDevices(),
              "Login":(context)=>Login(),
              "Webview":(context)=>WebViewExample(),

            }

        );
      },


    ));
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: TabBarView(
          children: [
            Home(),
            MineHome(),
          ],
        ),
        bottomNavigationBar: TabBar(
          tabs: [
            Tab(icon: Icon(Icons.home),text: "家居",),
            Tab(icon: Icon(Icons.perm_identity),text: "我的",)
          ],
          unselectedLabelColor: Colors.blueGrey,
          labelColor:Color(0xff8d4b0e),
          indicatorSize: TabBarIndicatorSize.label,
//          indicatorColor: Colors.red,
        ),
      ),
    );
  }
}

