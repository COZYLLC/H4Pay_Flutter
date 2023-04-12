import 'package:h4pay/model/Purchase/Gift.dart';
import 'package:h4pay/model/Purchase/Order.dart';
import 'package:h4pay/model/Purchase/Purchase.dart';
import 'package:h4pay/model/User.dart';
import 'package:json_annotation/json_annotation.dart';

part 'TempPurchase.g.dart';

@JsonSerializable()
class TempPurchase extends Purchase {
  final String? uid;
  final String? uidfrom;
  final String? uidto;
  final String orderId;
  final Map item;
  final int amount;
  String paymentKey;
  final String orderName;
  final String cashReceiptType;
  final String customerName;

  TempPurchase({
    this.uid,
    this.uidfrom,
    this.uidto,
    required this.orderId,
    required this.item,
    required this.amount,
    this.paymentKey = "",
    required this.orderName,
    required this.cashReceiptType,
    required this.customerName,
  }) : super(
          uid: uid,
          uidfrom: uidfrom,
          uidto: uidto,
          amount: amount,
          item: item,
          orderId: orderId,
          paymentKey: paymentKey,
          date: DateTime.now().toIso8601String(),
          expire: DateTime.now().toIso8601String(),
          exchanged: false,
          extended: false,
        );

  factory TempPurchase.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$TempPurchaseFromJson(
        json,
      );

  Map<String, dynamic> toJson() => _$TempPurchaseToJson(this);
}

@JsonSerializable()
class TempOrder extends Order implements TempPurchase {
  final String uid;
  final String orderId;
  final Map item;
  final int amount;
  String paymentKey;
  final String orderName;
  final String cashReceiptType;
  final String customerName;

  TempOrder({
    required this.uid,
    required this.orderId,
    required this.item,
    required this.amount,
    this.paymentKey = "",
    required this.orderName,
    required this.cashReceiptType,
    required this.customerName,
  }) : super(
          uid: uid,
          amount: amount,
          item: item,
          orderId: orderId,
          paymentKey: paymentKey,
          date: DateTime.now().toIso8601String(),
          expire: DateTime.now().toIso8601String(),
          exchanged: false,
        );

  factory TempOrder.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$TempOrderFromJson(
        json,
      );

  Map<String, dynamic> toJson() => _$TempOrderToJson(this);
}

@JsonSerializable()
class TempGift extends Gift implements TempPurchase {
  String? receiverName;
  final String reason;
  final String uidto;
  final String uidfrom;
  final String orderId;
  final Map item;
  final int amount;
  String paymentKey;
  final String orderName;
  final String cashReceiptType;
  final String customerName;

  TempGift({
    this.receiverName,
    required this.reason,
    required this.uidto,
    required this.uidfrom,
    required this.orderId,
    required this.item,
    required this.amount,
    this.paymentKey = "",
    required this.orderName,
    required this.cashReceiptType,
    required this.customerName,
  }) : super(
          uidfrom: uidfrom,
          uidto: uidto,
          orderId: orderId,
          date: DateTime.now().toIso8601String(),
          expire: DateTime.now().toIso8601String(),
          item: item,
          amount: amount,
          paymentKey: paymentKey,
          exchanged: false,
          extended: false,
        );

  factory TempGift.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$TempGiftFromJson(
        json,
      );

  Map<String, dynamic> toJson() => _$TempGiftToJson(this);
}
