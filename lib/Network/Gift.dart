import 'dart:convert';

import 'package:h4pay/model/Purchase/Gift.dart';
import 'package:h4pay/Setting.dart';
import 'package:h4pay/Network/Network.dart';
import 'package:h4pay/exception.dart';

Future<List<Gift>> fetchGift(_uid) async {
  final response = await post(
    Uri.parse('$API_URL/gift/recipientlist'),
    body: {"uid": _uid},
  );
  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    List gifts = jsonResponse['result'];
    return gifts.map((e) => Gift.fromJson(e)).toList();
  } else {
    throw NetworkException(response.statusCode);
  }
}

Future<Gift> fetchGiftDetail(String orderId) async {
  final response = await get(
    Uri.parse('$API_URL/gift/findbyorderid/$orderId'),
  );
  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    if (jsonResponse['status']) {
      Map<String, dynamic> gift = jsonResponse['gift'];
      return Gift.fromJson(gift);
    } else {
      throw NetworkException(response.statusCode);
    }
  } else {
    throw NetworkException(response.statusCode);
  }
}

Future<List<Gift>> fetchSentGift(_uid) async {
  final response = await post(
    Uri.parse('$API_URL/gift/findbysenderuid'),
    body: {"uid": _uid},
  );
  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    if (jsonResponse['status']) {
      List gifts = jsonDecode(response.body)['result'];
      return gifts.map((e) => Gift.fromJson(e)).toList();
    } else {
      throw NetworkException(response.statusCode);
    }
  } else {
    throw NetworkException(response.statusCode);
  }
}

Future<List<String>> checkUserValid(String studentId) async {
  final List<Map> studentList = [
    {'studentid': studentId}
  ];
  final validResponse = await post(
    Uri.parse('$API_URL/gift/uservalid'),
    body: {'users': jsonEncode(studentList)},
  );
  if (validResponse.statusCode == 200) {
    final jsonResponse = jsonDecode(validResponse.body);
    if (jsonResponse['result']['isValid']) {
      final nameResponse = await post(
        Uri.parse('$API_URL/gift/namefromstid'),
        body: {"users": jsonEncode(studentList)},
      );
      if (nameResponse.statusCode == 200) {
        final jsonResponse = jsonDecode(nameResponse.body);
        return jsonResponse['result'];
      } else {
        throw NetworkException(validResponse.statusCode);
      }
    } else {
      throw InvalidTargetException(users: jsonResponse['result']['invusers']);
    }
  } else {
    throw NetworkException(validResponse.statusCode);
  }
}
