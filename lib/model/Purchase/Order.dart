import 'dart:async';
import 'package:h4pay/model/Purchase/Purchase.dart';
import 'package:h4pay/Setting.dart';
import 'package:h4pay/Network/Network.dart';
import 'package:h4pay/exception.dart';

class Order extends Purchase {
  final String uid;
  Order(
      {required this.uid,
      required orderId,
      required paymentKey,
      required date,
      required item,
      required expire,
      required amount,
      required exchanged})
      : super(
            uid: uid,
            orderId: orderId,
            paymentKey: paymentKey,
            date: date,
            item: item,
            expire: expire,
            amount: amount,
            exchanged: exchanged);

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      uid: json['uid'],
      orderId: json['orderId'],
      paymentKey: json['paymentKey'],
      date: json['date'],
      item: json['item'],
      expire: json['expire'],
      amount: json['amount'],
      exchanged: json['exchanged'],
    );
  }

  Map toJson(Order instance) => <String, dynamic>{
        'uid': instance.uid,
        'orderId': instance.orderId,
        'paymentKey': instance.paymentKey,
        'date': instance.date,
        'item': instance.item,
        'expire': instance.expire,
        'amount': instance.amount,
        'exchanged': instance.exchanged,
      };

  Future<Order> create() async {
    final response = await post(
      Uri.parse("$API_URL/orders/create"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: toJson(this),
    );
    if (response.statusCode == 200) {
      return this;
    } else {
      throw NetworkException(response.statusCode);
    }
  }
}
