import 'package:json_annotation/json_annotation.dart';

abstract class Purchase {
  String? uid;
  final String? uidfrom;
  final String? uidto;
  final String orderId;
  final String date;
  final Map item;
  final String expire;
  final int amount;
  final bool exchanged;
  String paymentKey;
  final bool? extended;

  Purchase({
    this.uid,
    this.uidfrom,
    this.uidto,
    required this.orderId,
    required this.date,
    required this.item,
    required this.expire,
    required this.amount,
    required this.exchanged,
    required this.paymentKey,
    this.extended,
  });
}
