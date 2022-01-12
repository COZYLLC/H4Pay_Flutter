import 'package:flutter/material.dart';
import 'package:h4pay/Util/Dialog.dart';

class UserNotFoundException implements Exception {
  String message = "사용자 정보를 불러올 수 없습니다.";
  UserNotFoundException();
}

class NetworkException implements Exception {
  int statusCode;
  NetworkException(this.statusCode);
}

class InvalidTargetException implements Exception {
  List<String> users;
  InvalidTargetException({required this.users});
}

void showServerErrorSnackbar(BuildContext context, Exception e, {String? msg}) {
  showSnackbar(
    context,
    msg ?? "(${e.toString}) 서버 오류가 발생했습니다. 고객센터로 문의해주세요.",
    Colors.red,
    Duration(seconds: 3),
  );
}
