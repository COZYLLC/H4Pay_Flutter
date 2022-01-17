// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'UserValidResponse.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserValidResponse _$UserValidResponseFromJson(Map<String, dynamic> json) =>
    UserValidResponse(
      isValid: json['isValid'] as bool,
      users: (json['users'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
    );

Map<String, dynamic> _$UserValidResponseToJson(UserValidResponse instance) =>
    <String, dynamic>{
      'isValid': instance.isValid,
      'users': instance.users,
    };
