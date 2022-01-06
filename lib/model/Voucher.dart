import 'dart:convert';
import 'package:h4pay/Setting.dart';
import 'package:http/http.dart' as http;

class Voucher {
  final String id;
  final Map issuer;
  final int amount;
  final String message;
  final String date;
  final String expire;
  final bool exchanged;
  final Map? item;

  Voucher({
    required this.id,
    required this.issuer,
    required this.amount,
    required this.message,
    required this.date,
    required this.expire,
    required this.exchanged,
    this.item,
  });

  factory Voucher.fromJson(json) {
    return Voucher(
        id: json['id'],
        issuer: json['issuer'],
        amount: json['amount'],
        message: json['message'],
        date: json['date'],
        expire: json['expire'],
        exchanged: json['exchanged'],
        item: json['item']);
  }
}
