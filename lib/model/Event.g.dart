// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Event _$EventFromJson(Map<String, dynamic> json) => Event(
      id: json['id'] as String,
      name: json['name'] as String,
      start: json['start'] as String,
      end: json['end'] as String,
      qty: json['qty'] as int,
      totalqty: json['totalqty'] as int,
      amount: json['amount'] as int,
      desc: json['desc'] as String,
      img: json['img'] as String,
    );

Map<String, dynamic> _$EventToJson(Event instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'start': instance.start,
      'end': instance.end,
      'qty': instance.qty,
      'totalqty': instance.totalqty,
      'amount': instance.amount,
      'desc': instance.desc,
      'img': instance.img,
    };
