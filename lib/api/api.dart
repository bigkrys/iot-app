import 'dart:async';
import 'dart:io';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
Map<String, dynamic> optHeader = {
  'accept-language': 'zh-cn',
  'content-type': 'application/json'
};

var dio = new Dio(BaseOptions(connectTimeout: 30000, headers: optHeader));

class NetUtils {

//  static String Host = 'http://192.168.0.36:3001';
  static String Host = 'http://193.112.118.190:3001';
  static String getProductList = Host + '/v1/product/getProductList';
  static String Login = Host +'/v1/user/login';

  static String bingeDevice = Host + '/v1/equip/bindDevice';
  static String getBindDevice = Host + '/v1/equip/getBindProductList';

  static Future get(String url, Map<String, dynamic> params) async {
    var response;

    //PersistCookieJar是保存在文件里，退出appcookie还在；cookiejar是保存在内存里，退出app就不在了
    dio.interceptors.add(CookieManager(PersistCookieJar()));
    response = await dio.get(url, queryParameters: params);
    return response.data;
  }

  static Future post(String url, Map<String, dynamic> params) async {
    var dio = Dio();
    var cookieJar=CookieJar();
    dio.interceptors.add(CookieManager(cookieJar));
    var response = await dio.post(url, data: params);
    return response.data;
  }
}
