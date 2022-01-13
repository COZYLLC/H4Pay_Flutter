// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Gift.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Gift _$GiftFromJson(Map<String, dynamic> json) => Gift(
      uidfrom: json['uidfrom'] as String,
      uidto: json['uidto'] as String,
      orderId: json['orderId'],
      date: json['date'],
      item: json['item'],
      expire: json['expire'],
      amount: json['amount'],
      exchanged: json['exchanged'],
      paymentKey: json['paymentKey'],
      extended: json['extended'] as bool,
    );

Map<String, dynamic> _$GiftToJson(Gift instance) => <String, dynamic>{
      'orderId': instance.orderId,
      'date': instance.date,
      'item': instance.item,
      'expire': instance.expire,
      'amount': instance.amount,
      'exchanged': instance.exchanged,
      'paymentKey': instance.paymentKey,
      'uidfrom': instance.uidfrom,
      'uidto': instance.uidto,
      'extended': instance.extended,
    };
