import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Gift {
  final String uidfrom;
  final String uidto;
  final String orderid;
  final String date;
  final List item;
  final String expire;
  final int amount;
  final bool exchanged;

  Gift(
      {required this.uidfrom,
      required this.uidto,
      required this.orderid,
      required this.date,
      required this.item,
      required this.expire,
      required this.amount,
      required this.exchanged});

  factory Gift.fromList(Map<String, dynamic> json) {
    return Gift(
      uidfrom: json['uidfrom'],
      uidto: json['uidto'],
      orderid: json['orderid'],
      date: json['date'],
      item: json['item'],
      expire: json['expire'],
      amount: json['amount'],
      exchanged: json['exchanged'],
    );
  }
}

Future<List<Gift>?> fetchGift(_uid) async {
  final response = await http.post(
      Uri.parse('${dotenv.env['API_URL']}/gift/recipientlist'),
      body: {"uid": _uid});
  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    if (jsonResponse['status']) {
      List gifts = jsonDecode(response.body)['result'];
      return gifts.map((e) => Gift.fromList(e)).toList();
    } else {
      return null;
    }
  } else {
    throw Exception('Failed to fetch order.');
  }
}
