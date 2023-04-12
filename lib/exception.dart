import 'dart:async';

import 'package:flutter/material.dart';
import 'package:h4pay/Util/Dialog.dart';

abstract class H4PayException implements Exception {
  final String message;
  final FutureOr Function()? onClick;
  H4PayException({this.message = "알 수 없는 오류가 발생했습니다.", this.onClick});
}

class UserNotFoundException extends H4PayException {
  String message;
  final FutureOr Function()? onClick;
  UserNotFoundException({this.message = "사용자 정보를 불러올 수 없습니다.", this.onClick});
}

class NetworkException extends H4PayException {
  int statusCode;
  final String message;
  final FutureOr Function()? onClick;
  NetworkException(this.statusCode,
      {this.message = "네트워크 오류가 발생했습니다.", this.onClick});
}

class InvalidTargetException extends H4PayException {
  List<String> users;
  final String message;
  final FutureOr Function()? onClick;
  InvalidTargetException(
      {required this.users, this.message = "올바르지 않은 사용자입니다.", this.onClick});
}

class UserDuplicatedException extends H4PayException {
  String message;
  final FutureOr Function()? onClick;
  UserDuplicatedException({this.message = "이미 존재하는 사용자입니다.", this.onClick});
}

void showServerErrorSnackbar(BuildContext context, Exception e, {String? msg}) {
  showSnackbar(
    context,
    msg ?? "(${e.toString}) 서버 오류가 발생했습니다. 고객센터로 문의해주세요.",
    Colors.red,
    Duration(seconds: 3),
  );
}
