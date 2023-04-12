// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
      uid: json['uid'] as String,
      orderId: json['orderId'],
      paymentKey: json['paymentKey'],
      date: json['date'],
      item: json['item'],
      expire: json['expire'],
      amount: json['amount'],
      exchanged: json['exchanged'],
    );

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
      'orderId': instance.orderId,
      'date': instance.date,
      'item': instance.item,
      'expire': instance.expire,
      'amount': instance.amount,
      'exchanged': instance.exchanged,
      'paymentKey': instance.paymentKey,
      'uid': instance.uid,
    };
