import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:flutter/cupertino.dart';
class UI{
  showCustomWidgetToast(icon,text) {
    var w = Center(
      child: Container(
        padding: EdgeInsets.all(40),
        color: Color(0xff4c4c4c),
        child: Column(
          children: <Widget>[
            icon,
            Text(
              text,
              style: TextStyle(fontSize: 18.0,color: Colors.white,decoration: TextDecoration.none),

            ),
          ],
          mainAxisSize: MainAxisSize.min,
        ),
      ),
    );
    showToastWidget(w);
  }

  showSuccessfulToast(text){
    this.showCustomWidgetToast(Icon(Icons.done,color: Colors.white,size: 24,),text);
  }

  showFailedToast(text){
    this.showCustomWidgetToast(Icon(Icons.clear,color: Colors.red,size: 24,),text);

  }

  get bottomBuilder => (BuildContext context) {
    return Container(
      child: Column(
        children: [
          ListTile(
            title: Text("标题"),
            subtitle: Text("内容1"),
            onTap: () {
              Navigator.pop(context, "点击了内容1");
            },
          ),
          ListTile(
            title: Text("标题"),
            subtitle: Text("内容2"),
            onTap: () {
              Navigator.pop(context, "点击了内容2");
            },
          ),
          ListTile(
            title: Text("标题"),
            subtitle: Text("内容3"),
            onTap: () {
              Navigator.pop(context, "点击了内容3");
            },
          ),
        ],
      ),
    );
  };

  //弹出AlertDialog
  alertDialogAndBack(context,title,content,confirm) async {
    await showDialog(context: context, builder: (context) {
      return CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          CupertinoDialogAction(
            child: Text('确认'),
            onPressed: () {
              confirm();
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    });
  }

  //弹出底部弹框
  showBottomDialog(context) async {
    var result =
    await showModalBottomSheet(context: context, builder: bottomBuilder);
    print("弹框的返回值: $result");
  }
}

