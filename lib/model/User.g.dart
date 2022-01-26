// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'User.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

H4PayUser _$H4PayUserFromJson(Map<String, dynamic> json) => H4PayUser(
      uid: json['uid'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      role: json['role'] as String?,
      tel: json['tel'] as String?,
      token: json['token'] as String?,
    )..schoolId = json['schoolId'] as String?;

Map<String, dynamic> _$H4PayUserToJson(H4PayUser instance) => <String, dynamic>{
      'uid': instance.uid,
      'name': instance.name,
      'email': instance.email,
      'role': instance.role,
      'tel': instance.tel,
      'token': instance.token,
      'schoolId': instance.schoolId,
    };
