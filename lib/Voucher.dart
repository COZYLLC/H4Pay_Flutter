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

Future<List<Voucher>?> fetchVouchers(String tel) async {
  final response =
      await http.get(Uri.parse("$API_URL/voucher/filter?tel=$tel"));
  if (response.statusCode == 200) {
    final Map jsonBody = jsonDecode(response.body);
    if (jsonBody['status']) {
      final List vouchersJson = jsonBody['result'];
      return vouchersJson.map((e) => Voucher.fromJson(e)).toList();
    } else {
      return null;
    }
  } else {
    return null;
  }
}

Future<Voucher?> fetchVoucherDetail(String id) async {
  final response = await http.get(Uri.parse("$API_URL/voucher/filter?id=$id"));
  if (response.statusCode == 200) {
    final Map jsonBody = jsonDecode(response.body);
    if (jsonBody['status']) {
      return Voucher.fromJson(jsonBody['result'][0]);
    } else {
      return null;
    }
  } else {
    return null;
  }
}
