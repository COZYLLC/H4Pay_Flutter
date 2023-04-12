// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Notice.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Notice _$NoticeFromJson(Map<String, dynamic> json) => Notice(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      img: json['img'] as String,
      date: json['date'] as String,
    );

Map<String, dynamic> _$NoticeToJson(Notice instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'img': instance.img,
      'date': instance.date,
    };
