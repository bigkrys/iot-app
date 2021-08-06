import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myflutter/globalData.dart';
import 'package:oktoast/oktoast.dart';
import 'package:crypt/crypt.dart';
import '../common/ui.dart';
import '../../api/api.dart';
import '../models/user.dart';

UI ui = new UI();
class Login extends StatelessWidget{

  String username = '';
  String password = '';

  void back(context){
    Navigator.pop(context);
  }
  onUsernameInput(value){
    print('手机号码输入的是$value');
    username = value;
  }

  onPasswordInput(value){
    password = value;
    print('密码输入的是$value');
  }
  void check(context){
    if(username.length != 11 ){
      ui.showFailedToast('请输入正确的手机号码');
    }
    if(username.length == 11  && password.length<6){
      ui.showFailedToast('请输入至少六位密码');

    }
    if(username.length==11 && password.length>=6){
      //密码要加密
      final c1 = Crypt.sha256('p@password', salt: 'liangwanlingiot');
      LoginMethod(username,c1,context);

    }
  }

  void LoginMethod(username,pwd,context)async{
    var response = await NetUtils.post(NetUtils.Login, {
      "username":username,
      "password":pwd.toString(),
    });
    if(response['code'] == 200){
      //登录成功
      //更新全局用户信息，登录信息
      User user = User.fromJson(response['data']);
      print('user is $user');

      Provider.of<GlobalData>(context,listen: false).UpdateUserInfo(user);
      //顺便进入首页

      Navigator.pop( context);
    }else{
      ui.showFailedToast(response['message']);

    }
    try {
      print('response is $response');

    } catch (err) {
      ui.showFailedToast(response['message']);
    }
  }



  @override
  Widget build(BuildContext context) {

    return OKToast(child: new MaterialApp(
      title: '登录',
      home: new Scaffold(
        appBar: new AppBar(
          elevation: 0,
          leading:IconButton(
            icon: Icon(Icons.clear,color: Colors.black,),
            onPressed: () {
              back(context);
            },
          ),
          backgroundColor:Colors.white,
          title: new Text('登录',style: TextStyle(color: Colors.black),),

        ),
        body: new Center(
            child: Container(
              padding: EdgeInsets.only(left: 20,right: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextField(
                    autofocus: true,
                    onChanged: (v) {
                      onUsernameInput(v);
                    },
                    keyboardType:TextInputType.number,
                    decoration: InputDecoration(
                        labelText: "用户名",
                        hintText: "手机号",
                        prefixIcon: Icon(Icons.person)
                    ),
                  ),
                  TextField(
                    decoration: InputDecoration(
                        labelText: "密码",
                        hintText: "您的登录密码",
                        prefixIcon: Icon(Icons.lock)
                    ),
                    obscureText: true,
                    onChanged: (v) {
                      onPasswordInput(v);
                    },
                  ),
                  Container(
                    child: FlatButton(
                      color: Colors.blue,
                      highlightColor: Colors.blue[700],
                      colorBrightness: Brightness.dark,
                      splashColor: Colors.grey,
                      child: Container(
                        child: Center(child: Text("登录"),),
                        width: 100,
                        height: 50,
                      ),
                      shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                      onPressed: () {check(context);},
                    ),
                    margin: EdgeInsets.only(top: 20),
                  )


                ],
              ),
            )
        ),
      ),
    ));

  }
}