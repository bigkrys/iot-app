import 'package:flutter/material.dart';
import 'package:myflutter/routes/home/home.dart';
import 'package:provider/provider.dart';
import 'package:myflutter/globalData.dart';
import '../login.dart';
var homecolor = Color(0xff8d4b0e);

class MineHome extends StatelessWidget {
  const MineHome({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xfffff5f5f5),
      child: Column(
        children: [
          context
              .watch<GlobalData>()
              .hasLogin ? LoginWidget() : UnLoginWidget(),
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
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.network(context.watch<GlobalData>().user.image,width: 60,height: 60,),
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
                color: Colors.white,
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
    Navigator.push( context,
        MaterialPageRoute(builder: (context) {
          return Login();
        }
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width:MediaQuery.of(context).size.width,
      height: 200,
      padding: EdgeInsets.only(left: 20,right: 20,),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset('assets/icon/people.png', width: 60, height: 60,),
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
                color: Colors.white,
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










