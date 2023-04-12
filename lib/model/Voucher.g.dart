// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Voucher.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Voucher _$VoucherFromJson(Map<String, dynamic> json) => Voucher(
      id: json['id'] as String,
      issuer: json['issuer'] as Map<String, dynamic>,
      amount: json['amount'] as int,
      message: json['message'] as String,
      date: json['date'] as String,
      expire: json['expire'] as String,
      exchanged: json['exchanged'] as bool,
      item: json['item'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$VoucherToJson(Voucher instance) => <String, dynamic>{
      'id': instance.id,
      'issuer': instance.issuer,
      'amount': instance.amount,
      'message': instance.message,
      'date': instance.date,
      'expire': instance.expire,
      'exchanged': instance.exchanged,
      'item': instance.item,
    };
