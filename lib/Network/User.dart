import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:h4pay/Network/Network.dart';
import 'package:http/http.dart' as http;
import 'package:h4pay/Setting.dart';
import 'package:h4pay/exception.dart';
import 'package:h4pay/model/User.dart';

Future<String> login(String id, String pw) async {
  print("APIURL $API_URL");
  final bytes = utf8.encode(pw);
  final digest = sha256.convert(bytes);

  final response = await http.post(
    Uri.parse("$API_URL/users/login"),
    body: {
      'uid': id,
      'password': base64.encode(digest.bytes),
    },
  );
  if (response.statusCode == 200) {
    final String? accessToken = response.headers['x-access-token'];
    if (accessToken == null) {
      throw UserNotFoundException();
    }
    return accessToken;
  } else {
    throw NetworkException(response.statusCode);
  }
}

Future<bool> logout() async {
  try {
    final storage = new FlutterSecureStorage();
    await storage.deleteAll();
    return true;
  } catch (e) {
    return false;
  }
}

Future<bool> uidDuplicateCheck(String uid) async {
  final response = await post(
    Uri.parse("$API_URL/users/valid"),
    body: {"type": "live", "uid": uid},
  );
  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    final bool isValid = jsonResponse['result']['isValid'];
    return isValid;
  } else {
    throw NetworkException(response.statusCode);
  }
}

Future<H4PayUser?> tokenCheck(String _token) async {
  final response = await http.post(
    Uri.parse("$API_URL/users/tokencheck"),
    headers: {
      "X-Access-Token": _token,
    },
  );
  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    print(response.body);
    final message = jsonResponse['message'];
    final Map userJson = jsonResponse['result'];
    userJson['token'] = _token;
    return H4PayUser.fromjson(userJson);
  } else {
    throw NetworkException(response.statusCode);
  }
}

//User management
Future<bool> changePassword(
  H4PayUser user,
  String prevPrassword,
  String pw2Change,
) async {
  final bytesPrev = utf8.encode(prevPrassword);
  final digestPrev = sha256.convert(bytesPrev);
  final bytes = utf8.encode(pw2Change);
  final digest = sha256.convert(bytes);

  final response = await post(
    Uri.parse("$API_URL/users/changepass"),
    body: {
      'uid': user.uid,
      'password': base64.encode(digestPrev.bytes),
      'cpassword': base64.encode(digest.bytes)
    },
  );
  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    await logout();
    return jsonResponse['status'];
  } else {
    throw NetworkException(response.statusCode);
  }
}

Future<bool> createUser(
  String email,
  String password,
  String tel,
) async {
  final bytes = utf8.encode(password);
  final digest = sha256.convert(bytes);

  final response = await post(
    Uri.parse("$API_URL/users/create"),
    body: {
      'uid': email.split("@")[0],
      'password': base64.encode(digest.bytes),
      'aID': '',
      'gID': '',
      'email': email,
      'tel': tel,
      'role': 'S',
    },
  );
  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    return jsonResponse['status'];
  } else {
    throw NetworkException(response.statusCode);
  }
}

Future<bool> withdraw(
  String uid,
  String name,
) async {
  final response = await post(
    Uri.parse("$API_URL/users/withdrawal"),
    body: {
      'uid': uid,
      'name': name,
    },
  );
  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    await logout();
    return jsonResponse['status'];
  } else {
    throw NetworkException(response.statusCode);
  }
}

Future<bool> findId(String name, String email) async {
  final response = await post(
    Uri.parse("$API_URL/users/find/uid"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: {
      "name": name,
      "email": email,
    },
  );
  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    return jsonResponse['status'];
  } else {
    throw NetworkException(response.statusCode);
  }
}

Future<bool> findPw(String name, String email, String uid) async {
  final response = await post(
    Uri.parse("$API_URL/users/find/password"),
    body: {"name": name, "email": email, "uid": uid},
  );
  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    return jsonResponse['status'];
  } else {
    throw NetworkException(response.statusCode);
  }
}
