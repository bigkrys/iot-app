import 'package:flutter/foundation.dart';


@immutable
class BindDevice {

  const BindDevice({
    required this.deviceId,
    required this.devId,
    required this.productId,
    required this.userId,
    required this.devcieName,
    required this.deviceAlias,
    required this.deviceLocalName,
    required this.bluetoothMacAddr,
    required this.wapUrl,
    required this.imageUrl,
    required this.deviceType,
  });

  final String deviceId;
  final String devId;
  final String productId;
  final String userId;
  final String devcieName;
  final String deviceAlias;
  final String deviceLocalName;
  final String bluetoothMacAddr;
  final String wapUrl;
  final String imageUrl;
  final String deviceType;

  factory BindDevice.fromJson(Map<String,dynamic> json) => BindDevice(
    deviceId: json['deviceId'] as String,
    devId: json['devId'] as String,
    productId: json['productId'] as String,
    userId: json['userId'] as String,
    devcieName: json['devcieName'] as String,
    deviceAlias: json['deviceAlias'] as String,
    deviceLocalName: json['deviceLocalName'] as String,
    bluetoothMacAddr: json['bluetoothMacAddr'] as String,
    wapUrl: json['wapUrl'] as String,
    imageUrl: json['imageUrl'] as String,
    deviceType: json['deviceType'] as String
  );
  
  Map<String, dynamic> toJson() => {
    'deviceId': deviceId,
    'devId': devId,
    'productId': productId,
    'userId': userId,
    'devcieName': devcieName,
    'deviceAlias': deviceAlias,
    'deviceLocalName': deviceLocalName,
    'bluetoothMacAddr': bluetoothMacAddr,
    'wapUrl': wapUrl,
    'imageUrl': imageUrl,
    'deviceType': deviceType
  };

  BindDevice clone() => BindDevice(
    deviceId: deviceId,
    devId: devId,
    productId: productId,
    userId: userId,
    devcieName: devcieName,
    deviceAlias: deviceAlias,
    deviceLocalName: deviceLocalName,
    bluetoothMacAddr: bluetoothMacAddr,
    wapUrl: wapUrl,
    imageUrl: imageUrl,
    deviceType: deviceType
  );


  BindDevice copyWith({
    String? deviceId,
    String? devId,
    String? productId,
    String? userId,
    String? devcieName,
    String? deviceAlias,
    String? deviceLocalName,
    String? bluetoothMacAddr,
    String? wapUrl,
    String? imageUrl,
    String? deviceType
  }) => BindDevice(
    deviceId: deviceId ?? this.deviceId,
    devId: devId ?? this.devId,
    productId: productId ?? this.productId,
    userId: userId ?? this.userId,
    devcieName: devcieName ?? this.devcieName,
    deviceAlias: deviceAlias ?? this.deviceAlias,
    deviceLocalName: deviceLocalName ?? this.deviceLocalName,
    bluetoothMacAddr: bluetoothMacAddr ?? this.bluetoothMacAddr,
    wapUrl: wapUrl ?? this.wapUrl,
    imageUrl: imageUrl ?? this.imageUrl,
    deviceType: deviceType ?? this.deviceType,
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is BindDevice && deviceId == other.deviceId && devId == other.devId && productId == other.productId && userId == other.userId && devcieName == other.devcieName && deviceAlias == other.deviceAlias && deviceLocalName == other.deviceLocalName && bluetoothMacAddr == other.bluetoothMacAddr && wapUrl == other.wapUrl && imageUrl == other.imageUrl && deviceType == other.deviceType;

  @override
  int get hashCode => deviceId.hashCode ^ devId.hashCode ^ productId.hashCode ^ userId.hashCode ^ devcieName.hashCode ^ deviceAlias.hashCode ^ deviceLocalName.hashCode ^ bluetoothMacAddr.hashCode ^ wapUrl.hashCode ^ imageUrl.hashCode ^ deviceType.hashCode;
}
