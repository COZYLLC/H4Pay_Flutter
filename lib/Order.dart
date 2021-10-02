import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:h4pay_flutter/Purchase.dart';
import 'package:h4pay_flutter/Result.dart';
import 'package:h4pay_flutter/Setting.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  Future<H4PayResult> create() async {
    final jsonBody = json.encode(
      toJson(this),
    );
    print("[API] ${jsonBody}");
    final response = await http.post(
      Uri.parse("$API_URL/orders/create"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonBody,
    );
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return H4PayResult(
        success: jsonResponse['status'],
        data: jsonResponse['message'],
      );
    } else {
      return H4PayResult(
        success: false,
        data: "서버 오류입니다.",
      );
    }
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
}

String genOrderId() {
  final today = new DateTime.now();
  final year = today.year;
  final month = today.month;
  final date = today.day;
  final time = today.millisecondsSinceEpoch;
  String orderId = year.toString();

  if (month < 10) {
    orderId += "0";
  }
  orderId += month.toString();
  if (date < 10) {
    orderId += "0";
  }
  orderId += date.toString() + time.toString();
  return orderId;
}

Future<List<Order>?> fetchOrder(_uid) async {
  print(API_URL);
  final response = await http.get(
    Uri.parse('$API_URL/orders/fromuid/$_uid'),
  );
  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    if (jsonResponse['status']) {
      List orders = jsonDecode(response.body)['order'];
      return orders.map((e) => Order.fromJson(e)).toList();
    } else {
      return null;
    }
  } else {
    throw Exception('Failed to fetch order.');
  }
}

Future<bool> cancelOrder(String orderId) async {
  print(API_URL);
  final response = await http.get(
    Uri.parse('$API_URL/orders/cancel/${orderId}'),
  );
  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    return jsonResponse['status'];
  } else {
    throw Exception('Failed to fetch order.');
  }
}
