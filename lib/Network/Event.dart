import 'dart:async';
import 'dart:convert';

import 'package:h4pay/Network/Network.dart';
import 'package:h4pay/exception.dart';
import 'package:h4pay/model/Event.dart';
import 'package:h4pay/Setting.dart';

Future<List<Event>?> fetchEvent() async {
  final response = await get(
    Uri.parse('$API_URL/event'),
  );
  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    List events = jsonResponse['result'];
    return events.map((e) => Event.fromList(e)).toList();
  } else {
    throw NetworkException(response.statusCode);
  }
}

Future<List<Event>?> fetchMatchEvent(String uid) async {
  final response = await get(
    Uri.parse('$API_URL/event/$uid/match'),
  );
  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    List products = jsonResponse['result'];
    return products.map((e) => Event.fromList(e)).toList();
  } else {
    throw NetworkException(response.statusCode);
  }
}
