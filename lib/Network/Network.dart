import 'dart:async';
import 'dart:convert';
import 'package:h4pay/model/User.dart';
import 'package:h4pay/exception.dart';
import 'package:http/http.dart' as http;

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
  print(networkResponse.body);
  return networkResponse;
}
