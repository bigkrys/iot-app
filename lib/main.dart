import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'routes/home/home.dart';
import 'routes/mine/minehome.dart';
import 'globalData.dart';
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
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(title: 'Flutter Demo Home Page'),
      )
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

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

