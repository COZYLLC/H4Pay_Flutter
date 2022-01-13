// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Event _$EventFromJson(Map<String, dynamic> json) => Event(
      id: json['id'] as String,
      title: json['title'] as String,
      start: json['start'] as String,
      end: json['end'] as String,
      qty: json['qty'] as int,
      totalqty: json['totalqty'] as int,
      price: json['price'] as int,
      content: json['content'] as String,
      img: json['img'] as String,
    );

Map<String, dynamic> _$EventToJson(Event instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'start': instance.start,
      'end': instance.end,
      'qty': instance.qty,
      'totalqty': instance.totalqty,
      'price': instance.price,
      'content': instance.content,
      'img': instance.img,
    };
