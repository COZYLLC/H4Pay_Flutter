import 'dart:async';

import 'package:h4pay/Notice.dart';
import 'package:h4pay/Setting.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Event extends Notice {
  final String id;
  final String title;
  final String start;
  final String end;
  final int qty;
  final int totalqty;
  final int price;
  final String content;
  final String img;

  Event(
      {required this.id,
      required this.title,
      required this.start,
      required this.end,
      required this.qty,
      required this.totalqty,
      required this.price,
      required this.content,
      required this.img})
      : super(
          id: id,
          title: title,
          content: content,
          date: start,
          img: img,
        );

  factory Event.fromList(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['name'],
      start: json['start'],
      end: json['end'],
      qty: json['qty'],
      totalqty: json['totalqty'],
      price: json['amount'],
      content: json['desc'],
      img: json['img'],
    );
  }
}

Future<List<Event>?> fetchEvent() async {
  try {
    final response = await http
        .get(
      Uri.parse('$API_URL/event'),
    )
        .timeout(Duration(seconds: 3), onTimeout: () {
      throw TimeoutException("timed out...");
    });
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['status']) {
        List events = jsonDecode(response.body)['result'];
        return events.map((e) => Event.fromList(e)).toList();
      } else {
        return null;
      }
    } else {
      throw Exception('Failed to fetch product.');
    }
  } catch (e) {
    return null;
  }
}

Future<List<Event>?> fetchMatchEvent(String uid) async {
  try {
    final response = await http
        .get(
      Uri.parse('$API_URL/event/$uid/match'),
    )
        .timeout(Duration(seconds: 3), onTimeout: () {
      throw TimeoutException("timed out...");
    });
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['status']) {
        List products = jsonDecode(response.body)['result'];
        return products.map((e) => Event.fromList(e)).toList();
      } else {
        return null;
      }
    } else {
      throw Exception('Failed to fetch product.');
    }
  } catch (e) {
    return null;
  }
}
