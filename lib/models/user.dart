import 'package:flutter/foundation.dart';


@immutable
class User {

  const User({
    required this.username,
    required this.nickname,
    required this.sex,
    required this.birthday,
    required this.image,
    required this.id,
  });

  final String username;
  final String nickname;
  final int sex;
  final String birthday;
  final String image;
  final String id;

  factory User.fromJson(Map<String,dynamic> json) => User(
    username: json['username'] as String,
    nickname: json['nickname'] as String,
    sex: json['sex'] as int,
    birthday: json['birthday'] as String,
    image: json['image'] as String,
    id: json['_id'] as String
  );
  
  Map<String, dynamic> toJson() => {
    'username': username,
    'nickname': nickname,
    'sex': sex,
    'birthday': birthday,
    'image': image,
    '_id': id
  };

  User clone() => User(
    username: username,
    nickname: nickname,
    sex: sex,
    birthday: birthday,
    image: image,
    id: id
  );


  User copyWith({
    String? username,
    String? nickname,
    int? sex,
    String? birthday,
    String? image,
    String? id
  }) => User(
    username: username ?? this.username,
    nickname: nickname ?? this.nickname,
    sex: sex ?? this.sex,
    birthday: birthday ?? this.birthday,
    image: image ?? this.image,
    id: id ?? this.id,
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is User && username == other.username && nickname == other.nickname && sex == other.sex && birthday == other.birthday && image == other.image && id == other.id;

  @override
  int get hashCode => username.hashCode ^ nickname.hashCode ^ sex.hashCode ^ birthday.hashCode ^ image.hashCode ^ id.hashCode;
}
