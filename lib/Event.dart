import 'package:async/async.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Event {
  final String id;
  final String name;
  final String start;
  final String end;
  final int qty;
  final int totalqty;
  final int price;
  final String desc;

  Event(
      {required this.id,
      required this.name,
      required this.start,
      required this.end,
      required this.qty,
      required this.totalqty,
      required this.price,
      required this.desc});

  factory Event.fromList(Map<String, dynamic> json) {
    //print(json);
    return Event(
        id: json['id'],
        name: json['name'],
        start: json['start'],
        end: json['end'],
        qty: json['qty'],
        totalqty: json['totalqty'],
        price: json['price'],
        desc: json['desc']);
  }
}

Future<List<Event>?> fetchEvent() async {
  final response = await http.get(
    Uri.parse('${dotenv.env['API_URL']}/event'),
  );
  if (response.statusCode == 200) {
    print("request go");
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
}

Future<List<Event>?> fetchMatchEvent(String uid) async {
  final response = await http.get(
    Uri.parse('${dotenv.env['API_URL']}/event/$uid/match'),
  );
  if (response.statusCode == 200) {
    print("request go");
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
}
