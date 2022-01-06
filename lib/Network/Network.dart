import 'dart:async';
import 'dart:convert';
import 'package:h4pay/model/User.dart';
import 'package:h4pay/exception.dart';
import 'package:http/http.dart' as http;

class H4PayResponse {
  bool status;
  String? message;
  dynamic result;
  H4PayResponse({
    required this.status,
    this.message,
    this.result,
  });
  factory H4PayResponse.fromJson(Map json) {
    H4PayResponse response = H4PayResponse(status: json['status']);
    response.message = json['message'];
    response.result = json['result'];
    return response;
  }
}

Future<http.Response> get(Uri uri, {Map? headers}) async {
  final H4PayUser? user = await userFromStorage();
  if (user == null) {
    throw UserNotFoundException();
  }
  final networkResponse = await http.get(
    uri,
    headers: {
      "X-Access-Token": user.token,
      'Content-Type': 'application/json; charset=UTF-8',
      ...(headers ?? {}),
    },
  ).timeout(Duration(seconds: 5), onTimeout: () {
    throw TimeoutException("서버 응답 시간이 만료되었습니다.");
  });
  return networkResponse;
}

Future<http.Response> post(Uri uri, {Map? body, Map? headers}) async {
  final H4PayUser? user = await userFromStorage();
  if (user == null) {
    throw UserNotFoundException();
  }
  final networkResponse = await http
      .post(
    uri,
    headers: {
      "X-Access-Token": user.token,
      'Content-Type': 'application/json; charset=UTF-8',
      ...(headers ?? {}),
    },
    body: json.encode(body),
  )
      .timeout(Duration(seconds: 5), onTimeout: () {
    throw TimeoutException("서버 응답 시간이 만료되었습니다.");
  });
  return networkResponse;
}
