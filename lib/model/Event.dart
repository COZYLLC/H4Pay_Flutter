import 'dart:async';

import 'package:h4pay/model/Notice.dart';
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
