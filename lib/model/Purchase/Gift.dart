import 'dart:async';
import 'package:h4pay/model/Purchase/Purchase.dart';
import 'package:h4pay/Setting.dart';
import 'package:h4pay/Network/Network.dart';
import 'dart:convert';

import 'package:h4pay/exception.dart';

class Gift extends Purchase {
  final String uidfrom;
  final String uidto;
  final bool extended;

  Gift(
      {required this.uidfrom,
      required this.uidto,
      required orderId,
      required date,
      required item,
      required expire,
      required amount,
      required exchanged,
      required paymentKey,
      required this.extended})
      : super(
          uidfrom: uidfrom,
          uidto: uidto,
          item: item,
          orderId: orderId,
          date: date,
          expire: expire,
          exchanged: exchanged,
          paymentKey: paymentKey,
          amount: amount,
        );

  factory Gift.fromJson(Map<String, dynamic> json) {
    return Gift(
        uidfrom: json['uidfrom'],
        uidto: json['uidto'],
        orderId: json['orderId'],
        date: json['date'],
        item: json['item'],
        expire: json['expire'],
        amount: json['amount'],
        exchanged: json['exchanged'],
        paymentKey: json['paymentKey'],
        extended: json['extended']);
  }

  Future<Gift> create() async {
    final response = await post(
      Uri.parse("$API_URL/gift/create"),
      body: toJson(this),
    );
    if (response.statusCode == 200) {
      return this;
    } else {
      throw NetworkException(response.statusCode);
    }
  }

  Map toJson(Gift instance) => <String, dynamic>{
        'uidfrom': instance.uidfrom,
        'uidto': instance.uidto,
        'orderId': instance.orderId,
        'paymentKey': instance.paymentKey,
        'date': instance.date,
        'item': instance.item,
        'expire': instance.expire,
        'amount': instance.amount,
        'exchanged': instance.exchanged,
        'extended': instance.extended
      };

  Future<bool> extend() async {
    final response = await post(
      Uri.parse('$API_URL/gift/${this.orderId}/extend'),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse['status'];
    } else {
      throw NetworkException(response.statusCode);
    }
  }
}

class SentGift {}
