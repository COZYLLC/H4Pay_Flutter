import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Order {
  final String uid;
  final String orderid;
  final String paymentkey;
  final String date;
  final List item;
  final String expire;
  final int amount;
  final bool exchanged;

  Order(
      {required this.uid,
      required this.orderid,
      required this.paymentkey,
      required this.date,
      required this.item,
      required this.expire,
      required this.amount,
      required this.exchanged});

  factory Order.fromList(Map<String, dynamic> json) {
    return Order(
      uid: json['uid'],
      orderid: json['orderid'],
      paymentkey: json['paymentkey'],
      date: json['date'],
      item: json['item'],
      expire: json['expire'],
      amount: json['amount'],
      exchanged: json['exchanged'],
    );
  }
}

Future<List<Order>?> fetchOrder(_uid) async {
  print(dotenv.env['API_URL']);
  final response = await http.get(
    Uri.parse('${dotenv.env['API_URL']}/orders/fromuid/$_uid'),
  );
  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    if (jsonResponse['status']) {
      List orders = jsonDecode(response.body)['order'];
      return orders.map((e) => Order.fromList(e)).toList();
    } else {
      return null;
    }
  } else {
    throw Exception('Failed to fetch order.');
  }
}
