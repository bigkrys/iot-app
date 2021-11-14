import 'package:flutter/material.dart';
import 'package:myflutter/routes/home/home.dart';
import 'package:provider/provider.dart';
import 'package:myflutter/globalData.dart';
import '../login.dart';
var homecolor = Color(0xff8d4b0e);

class MineHome extends StatelessWidget {
  const MineHome({Key? key}) : super(key: key);
  void changeTheme(context){
    Provider.of<GlobalData>(context,listen: false).changeThemeMode();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
//      color: Color(0xfffff5f5f5),
      child: Column(
        children: [
          context
              .watch<GlobalData>()
              .hasLogin ? LoginWidget() : UnLoginWidget(),
          RaisedButton(onPressed: ()=>changeTheme(context), child: Text('切换主题'))
        ],
      )
    );
  }
}

class LoginWidget extends StatelessWidget{

  void logout(context){
    Provider.of<GlobalData>(context,listen: false).Logout();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      width:MediaQuery.of(context).size.width,
      height: 200,
      padding: EdgeInsets.only(left: 20,right: 20,),
//      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              UserLogo(),
              Container(
                  margin: EdgeInsets.only(left: 20),
                  child:Text(context.watch<GlobalData>().user.nickname)
              )
            ],
          ),
          GestureDetector(
            child: Container(
              width: 80,
              height: 30,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('退出',style: TextStyle(color: homecolor,fontSize: 16),),
                ],
              ),
              decoration: new BoxDecoration(
//                color: Colors.white,
                border: Border.all(color: homecolor),
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
            ),
            onTap: () => {
              logout(context)
            },

          ),
        ],
      ),
    );

  }
}
class UnLoginWidget extends StatelessWidget {
  void LoginMethod(context){
    Navigator.of(context).pushNamed("Login");

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width:MediaQuery.of(context).size.width,
      height: 200,
      padding: EdgeInsets.only(left: 20,right: 20,),
//      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.person,size: 60,),
              Container(
                margin: EdgeInsets.only(left: 20),
                child:Text('未登录'),
              )
            ],
          ),
          GestureDetector(
            child: Container(
              width: 80,
              height: 30,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('登录',style: TextStyle(color: homecolor,fontSize: 16),),
                ],
              ),
              decoration: new BoxDecoration(
//                color: Colors.white,
                border: Border.all(color: homecolor),
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
            ),
            onTap: () => {
              LoginMethod(context)
            },

          ),
        ],
      ),
    );
  }
}


class UserLogo extends StatefulWidget {
  @override
  State<StatefulWidget> createState()=>UserLogoWidget();
}

class UserLogoWidget extends State<UserLogo> with SingleTickerProviderStateMixin{
  late AnimationController controller;
  late Animation<double> animation;

  void initState() {
    super.initState();
    // 创建动画周期为1秒的AnimationController对象
    controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000));

    final CurvedAnimation curve = CurvedAnimation(
        parent: controller, curve: Curves.elasticOut);

    // 创建从50到200线性变化的Animation对象
    // 普通动画需要手动监听动画状态，刷新UI
    animation = Tween(begin: 0.0, end: 30.0).animate(curve)
      ..addListener(()=>setState((){}))
      ..addStatusListener((status){
        if(status == AnimationStatus.completed){
          controller.reset();
          controller.forward();
        }
      });

// 启动动画
    controller.forward();
//    controller.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      //设置动画的旋转中心
      alignment: Alignment.center,
      //动画控制器
      turns: controller,
      //将要执行动画的子view
      child: Image.network(context.watch<GlobalData>().user.image,width: 60,height: 60,),
    );
  }

  @override
  void dispose() {
    // 释放资源
    controller.dispose();
    super.dispose();
  }
}








