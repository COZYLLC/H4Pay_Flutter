import 'dart:async';
import 'dart:convert';

import 'package:h4pay/Network/Network.dart';
import 'package:h4pay/exception.dart';
import 'package:h4pay/model/Notice.dart';
import 'package:h4pay/Setting.dart';

Future<List<Notice>?> fetchNotice() async {
  final response = await get(
    Uri.parse('$API_URL/notice'),
  );
  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    List notice = jsonResponse['result'];
    return notice.map((e) => Notice.fromList(e)).toList();
  } else {
    throw NetworkException(response.statusCode);
  }
}
