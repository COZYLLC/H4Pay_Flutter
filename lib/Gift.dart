import 'package:h4pay_flutter/Purchase.dart';
import 'package:h4pay_flutter/Result.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

  Future<H4PayResult> create() async {
    final jsonBody = json.encode(
      toJson(this),
    );
    print("[API] ${jsonBody} Creating");
    final response = await http.post(
      Uri.parse("${dotenv.env['API_URL']}/gift/create"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonBody,
    );
    print("done");
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      print("[API] $response");
      return H4PayResult(
          success: jsonResponse['status'], data: jsonResponse['message']);
    } else {
      return H4PayResult(success: false, data: "서버 오류입니다.");
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

  Future<H4PayResult> extend() async {
    final response = await http.post(
      Uri.parse('${dotenv.env['API_URL']}/gift/${this.orderId}/extend'),
    );
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return H4PayResult(
          success: jsonResponse['status'], data: jsonResponse['message']);
    } else {
      return H4PayResult(success: false, data: "서버 오류입니다.");
    }
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
      return gifts.map((e) => Gift.fromJson(e)).toList();
    } else {
      return null;
    }
  } else {
    throw Exception('Failed to fetch gift.');
  }
}

Future<List<Gift>?> fetchSentGift(_uid) async {
  final response = await http.post(
      Uri.parse('${dotenv.env['API_URL']}/gift/findbysenderuid'),
      body: {"uid": _uid});
  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    if (jsonResponse['status']) {
      List gifts = jsonDecode(response.body)['result'];
      return gifts.map((e) => Gift.fromJson(e)).toList();
    } else {
      return null;
    }
  } else {
    throw Exception('Failed to fetch sentgift.');
  }
}

Future<H4PayResult> checkUserValid(String studentId) async {
  final List<Map> studentList = [
    {'studentid': studentId}
  ];
  print("[API] {'users': ${jsonEncode(studentList)}");
  final validResponse = await http.post(
    Uri.parse('${dotenv.env['API_URL']}/gift/uservalid'),
    body: {'users': jsonEncode(studentList)},
  );
  if (validResponse.statusCode == 200) {
    final jsonResponse = jsonDecode(validResponse.body);
    if (jsonResponse['status']) {
      final nameResponse = await http.post(
        Uri.parse('${dotenv.env['API_URL']}/gift/namefromstid'),
        body: {"users": jsonEncode(studentList)},
      );
      if (nameResponse.statusCode == 200) {
        final jsonResponse = jsonDecode(nameResponse.body);
        return H4PayResult(
          success: jsonResponse['status'],
          data: jsonResponse['users'][0],
        );
      } else {
        return H4PayResult(
          success: jsonResponse['status'],
          data: jsonResponse['message'],
        );
      }
    } else {
      return H4PayResult(
        success: jsonResponse['status'],
        data: jsonResponse['message'],
      );
    }
  } else {
    return H4PayResult(
      success: false,
      data: '서버 오류입니다.',
    );
  }
}

class SentGift {}
