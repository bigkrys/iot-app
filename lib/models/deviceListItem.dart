import 'package:flutter/foundation.dart';


@immutable
class DeviceListItem {

  const DeviceListItem({
    required this.id,
    required this.name,
    required this.displayName,
    required this.type,
    required this.imageUrl,
    required this.connectMode,
    required this.viewType,
    required this.available,
    required this.wapUrl,
    required this.category,
    required this.categoryLv2,
    required this.config,
    required this.bindConfig,
    required this.wifiConfig,
    required this.bleConfig,
    required this.vender,
    required this.venderConfig,
    required this.shareable,
    required this.smartOptions,
    required this.updateDate,
    required this.creatDate,
    required this.v,
  });

  final String id;
  final String name;
  final String displayName;
  final String type;
  final String imageUrl;
  final int connectMode;
  final int viewType;
  final bool available;
  final String wapUrl;
  final int category;
  final int categoryLv2;
  final String config;
  final String bindConfig;
  final String wifiConfig;
  final String bleConfig;
  final int vender;
  final String venderConfig;
  final bool shareable;
  final String smartOptions;
  final String updateDate;
  final String creatDate;
  final int v;

  factory DeviceListItem.fromJson(Map<String,dynamic> json) => DeviceListItem(
    id: json['_id'] as String,
    name: json['name'] as String,
    displayName: json['displayName'] as String,
    type: json['type'] as String,
    imageUrl: json['imageUrl'] as String,
    connectMode: json['connectMode'] as int,
    viewType: json['viewType'] as int,
    available: json['available'] as bool,
    wapUrl: json['wapUrl'] as String,
    category: json['category'] as int,
    categoryLv2: json['categoryLv2'] as int,
    config: json['config'] as String,
    bindConfig: json['bindConfig'] as String,
    wifiConfig: json['wifiConfig'] as String,
    bleConfig: json['bleConfig'] as String,
    vender: json['vender'] as int,
    venderConfig: json['venderConfig'] as String,
    shareable: json['shareable'] as bool,
    smartOptions: json['smartOptions'] as String,
    updateDate: json['update_date'] as String,
    creatDate: json['creat_date'] as String,
    v: json['__v'] as int
  );
  
  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'displayName': displayName,
    'type': type,
    'imageUrl': imageUrl,
    'connectMode': connectMode,
    'viewType': viewType,
    'available': available,
    'wapUrl': wapUrl,
    'category': category,
    'categoryLv2': categoryLv2,
    'config': config,
    'bindConfig': bindConfig,
    'wifiConfig': wifiConfig,
    'bleConfig': bleConfig,
    'vender': vender,
    'venderConfig': venderConfig,
    'shareable': shareable,
    'smartOptions': smartOptions,
    'update_date': updateDate,
    'creat_date': creatDate,
    '__v': v
  };

  DeviceListItem clone() => DeviceListItem(
    id: id,
    name: name,
    displayName: displayName,
    type: type,
    imageUrl: imageUrl,
    connectMode: connectMode,
    viewType: viewType,
    available: available,
    wapUrl: wapUrl,
    category: category,
    categoryLv2: categoryLv2,
    config: config,
    bindConfig: bindConfig,
    wifiConfig: wifiConfig,
    bleConfig: bleConfig,
    vender: vender,
    venderConfig: venderConfig,
    shareable: shareable,
    smartOptions: smartOptions,
    updateDate: updateDate,
    creatDate: creatDate,
    v: v
  );


  DeviceListItem copyWith({
    String? id,
    String? name,
    String? displayName,
    String? type,
    String? imageUrl,
    int? connectMode,
    int? viewType,
    bool? available,
    String? wapUrl,
    int? category,
    int? categoryLv2,
    String? config,
    String? bindConfig,
    String? wifiConfig,
    String? bleConfig,
    int? vender,
    String? venderConfig,
    bool? shareable,
    String? smartOptions,
    String? updateDate,
    String? creatDate,
    int? v
  }) => DeviceListItem(
    id: id ?? this.id,
    name: name ?? this.name,
    displayName: displayName ?? this.displayName,
    type: type ?? this.type,
    imageUrl: imageUrl ?? this.imageUrl,
    connectMode: connectMode ?? this.connectMode,
    viewType: viewType ?? this.viewType,
    available: available ?? this.available,
    wapUrl: wapUrl ?? this.wapUrl,
    category: category ?? this.category,
    categoryLv2: categoryLv2 ?? this.categoryLv2,
    config: config ?? this.config,
    bindConfig: bindConfig ?? this.bindConfig,
    wifiConfig: wifiConfig ?? this.wifiConfig,
    bleConfig: bleConfig ?? this.bleConfig,
    vender: vender ?? this.vender,
    venderConfig: venderConfig ?? this.venderConfig,
    shareable: shareable ?? this.shareable,
    smartOptions: smartOptions ?? this.smartOptions,
    updateDate: updateDate ?? this.updateDate,
    creatDate: creatDate ?? this.creatDate,
    v: v ?? this.v,
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is DeviceListItem && id == other.id && name == other.name && displayName == other.displayName && type == other.type && imageUrl == other.imageUrl && connectMode == other.connectMode && viewType == other.viewType && available == other.available && wapUrl == other.wapUrl && category == other.category && categoryLv2 == other.categoryLv2 && config == other.config && bindConfig == other.bindConfig && wifiConfig == other.wifiConfig && bleConfig == other.bleConfig && vender == other.vender && venderConfig == other.venderConfig && shareable == other.shareable && smartOptions == other.smartOptions && updateDate == other.updateDate && creatDate == other.creatDate && v == other.v;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ displayName.hashCode ^ type.hashCode ^ imageUrl.hashCode ^ connectMode.hashCode ^ viewType.hashCode ^ available.hashCode ^ wapUrl.hashCode ^ category.hashCode ^ categoryLv2.hashCode ^ config.hashCode ^ bindConfig.hashCode ^ wifiConfig.hashCode ^ bleConfig.hashCode ^ vender.hashCode ^ venderConfig.hashCode ^ shareable.hashCode ^ smartOptions.hashCode ^ updateDate.hashCode ^ creatDate.hashCode ^ v.hashCode;
}
