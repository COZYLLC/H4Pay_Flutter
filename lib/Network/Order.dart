import 'dart:convert';

import 'package:h4pay/model/Purchase/Order.dart';
import 'package:h4pay/Setting.dart';
import 'package:h4pay/Network/Network.dart';
import 'package:h4pay/exception.dart';

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

Future<List<Order>> fetchOrder(_uid) async {
  final response = await get(
    Uri.parse('$API_URL/orders/fromuid/$_uid'),
  );
  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    List orders = jsonResponse['result'];
    return orders.map((e) => Order.fromJson(e)).toList();
  } else {
    throw NetworkException(response.statusCode);
  }
}

Future<bool> cancelOrder(String orderId) async {
  final response = await get(
    Uri.parse('$API_URL/orders/cancel/$orderId'),
  );
  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    return jsonResponse['status'];
  } else {
    throw NetworkException(response.statusCode);
  }
}
