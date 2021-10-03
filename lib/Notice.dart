import 'dart:async';

import 'package:h4pay/Setting.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Notice {
  final String id;
  final String title;
  final String content;
  final String img;
  final String date;

  Notice(
      {required this.id,
      required this.title,
      required this.content,
      required this.img,
      required this.date});

  factory Notice.fromList(Map<String, dynamic> json) {
    //print(json);
    return Notice(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      img: json['img'],
      date: json['date'],
    );
  }
}

Future<List<Notice>?> fetchNotice() async {
  try {
    final response = await http
        .get(
      Uri.parse('$API_URL/notice'),
    )
        .timeout(Duration(seconds: 3), onTimeout: () {
      throw TimeoutException("timed out...");
    });
    if (response.statusCode == 200) {
      print("request go");
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['status']) {
        List notice = jsonDecode(response.body)['result'];
        return notice.map((e) => Notice.fromList(e)).toList();
      } else {
        return null;
      }
    } else {
      throw Exception('Failed to fetch notice.');
    }
  } catch (e) {
    return null;
  }
}
