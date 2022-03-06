// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'TempPurchase.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TempPurchase _$TempPurchaseFromJson(Map<String, dynamic> json) => TempPurchase(
      uid: json['uid'] as String?,
      uidfrom: json['uidfrom'] as String?,
      uidto: json['uidto'] as String?,
      orderId: json['orderId'] as String,
      item: json['item'] as Map<String, dynamic>,
      amount: json['amount'] as int,
      paymentKey: json['paymentKey'] as String? ?? "",
      orderName: json['orderName'] as String,
      cashReceiptType: json['cashReceiptType'] as String,
      customerName: json['customerName'] as String,
    );

Map<String, dynamic> _$TempPurchaseToJson(TempPurchase instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'uidfrom': instance.uidfrom,
      'uidto': instance.uidto,
      'orderId': instance.orderId,
      'item': instance.item,
      'amount': instance.amount,
      'paymentKey': instance.paymentKey,
      'orderName': instance.orderName,
      'cashReceiptType': instance.cashReceiptType,
      'customerName': instance.customerName,
    };

TempOrder _$TempOrderFromJson(Map<String, dynamic> json) => TempOrder(
      uid: json['uid'] as String,
      orderId: json['orderId'] as String,
      item: json['item'] as Map<String, dynamic>,
      amount: json['amount'] as int,
      paymentKey: json['paymentKey'] as String? ?? "",
      orderName: json['orderName'] as String,
      cashReceiptType: json['cashReceiptType'] as String,
      customerName: json['customerName'] as String,
    );

Map<String, dynamic> _$TempOrderToJson(TempOrder instance) => <String, dynamic>{
      'uid': instance.uid,
      'orderId': instance.orderId,
      'item': instance.item,
      'amount': instance.amount,
      'paymentKey': instance.paymentKey,
      'orderName': instance.orderName,
      'cashReceiptType': instance.cashReceiptType,
      'customerName': instance.customerName,
    };

TempGift _$TempGiftFromJson(Map<String, dynamic> json) => TempGift(
      receiverName: json['receiverName'] as String?,
      reason: json['reason'] as String,
      uidto: json['uidto'] as String,
      uidfrom: json['uidfrom'] as String,
      orderId: json['orderId'] as String,
      item: json['item'] as Map<String, dynamic>,
      amount: json['amount'] as int,
      paymentKey: json['paymentKey'] as String? ?? "",
      orderName: json['orderName'] as String,
      cashReceiptType: json['cashReceiptType'] as String,
      customerName: json['customerName'] as String,
    )..uid = json['uid'] as String?;

Map<String, dynamic> _$TempGiftToJson(TempGift instance) => <String, dynamic>{
      'uid': instance.uid,
      'receiverName': instance.receiverName,
      'reason': instance.reason,
      'uidto': instance.uidto,
      'uidfrom': instance.uidfrom,
      'orderId': instance.orderId,
      'item': instance.item,
      'amount': instance.amount,
      'paymentKey': instance.paymentKey,
      'orderName': instance.orderName,
      'cashReceiptType': instance.cashReceiptType,
      'customerName': instance.customerName,
    };
