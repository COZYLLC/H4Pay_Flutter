import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:h4pay/Result.dart';
import 'package:h4pay/Setting.dart';
import 'package:http/http.dart' as http;

class H4PayUser {
  String? uid;
  String? name;
  String? email;
  String? role;
  String token;
  final storage = new FlutterSecureStorage();

  H4PayUser({this.uid, this.name, this.email, this.role, required this.token});

  factory H4PayUser.fromjson(Map json) {
    return H4PayUser(
        uid: json['uid'],
        name: json['name'],
        email: json['email'],
        role: json['role'],
        token: json['token']);
  }

  Future<bool> saveToStorage() async {
    print("[API] $token");
    try {
      await storage.deleteAll();
      await storage.write(key: 'uid', value: this.uid);
      storage.write(key: 'name', value: this.name);
      storage.write(key: 'email', value: this.email);
      storage.write(key: 'role', value: this.role);
      storage.write(key: 'token', value: this.token);
      return true;
    } catch (e) {
      print("[ERROR] $e");
      return false;
    }
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
  final response = await http.post(
    Uri.parse("$API_URL/users/valid"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: json.encode(
      {"type": "live", "uid": uid},
    ),
  );
  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    print(jsonResponse);
    final bool status = jsonResponse['status'];
    return status;
  } else {
    return false;
  }
}

Future<H4PayUser?> userFromStorage() async {
  final storage = new FlutterSecureStorage();
  try {
    final Map userJson = await storage.readAll();
    final H4PayUser user = H4PayUser.fromjson(userJson);
    return await tokenCheck(user.token);
  } catch (e) {
    return null;
  }
}

Future<H4PayUser?> tokenCheck(String _token) async {
  final response = await http.post(
    Uri.parse("$API_URL/users/tokencheck"),
    headers: {'x-access-token': _token},
  );
  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    final message = jsonResponse['message'];
    message['token'] = _token;
    return H4PayUser.fromjson(message);
  } else {
    return null;
  }
}

//User management
Future<bool> changePassword(
  H4PayUser user,
  String prevPrassword,
  String pw2Change,
) async {
  final bytes_prev = utf8.encode(prevPrassword);
  final digest_prev = sha256.convert(bytes_prev);
  final bytes = utf8.encode(pw2Change);
  final digest = sha256.convert(bytes);

  final response = await http.post(
    Uri.parse("$API_URL/users/changepass"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: json.encode({
      'uid': user.uid,
      'password': base64.encode(digest_prev.bytes),
      'cpassword': base64.encode(digest.bytes)
    }),
  );
  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    await logout();
    return jsonResponse['status'];
  } else {
    return false;
  }
}

Future<H4PayResult> createUser(
  String name,
  String uid,
  String password,
  String userAuth,
  String email,
  String tel,
  String role,
) async {
  bool isVerified = false;
  switch (role) {
    case 'A':
      isVerified = userAuth == dotenv.env['AUTH_CODE_ADMIN_SYSTEM'];
      break;
    case 'AT':
      isVerified = userAuth == dotenv.env['AUTH_CODE_ADMIN_TEACHER'];
      break;
    case 'T':
      isVerified = userAuth == dotenv.env['AUTH_CODE_TEACHER'];
      break;
    case 'M':
      isVerified = userAuth == dotenv.env['AUTH_CODE_MANAGER_STUDENT'];
      break;
    case 'S':
      isVerified = true;
      break;
  }
  if (!isVerified) {
    return H4PayResult(success: false, data: "인증코드가 틀렸습니다.");
  }

  final bytes = utf8.encode(password);
  final digest = sha256.convert(bytes);

  final response = await http.post(
    Uri.parse("$API_URL/users/create"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: json.encode({
      'name': name,
      'uid': uid,
      'password': base64.encode(digest.bytes),
      'studentid': role == 'S' ? userAuth : "",
      'email': email,
      'aID': '',
      'gID': '',
      'tel': tel,
      'role': role,
    }),
  );
  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    print("[API] $jsonResponse");
    return H4PayResult(
        success: jsonResponse['status'], data: jsonResponse['message']);
  } else {
    return H4PayResult(success: false, data: "서버 오류입니다.");
  }
}

Future<H4PayResult> withdraw(
  String uid,
  String name,
) async {
  final response = await http.post(
    Uri.parse("$API_URL/users/withdrawal"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: json.encode(
      {
        'uid': uid,
        'name': name,
      },
    ),
  );
  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    await logout();
    return H4PayResult(
        success: jsonResponse['status'], data: jsonResponse['message']);
  } else {
    return H4PayResult(success: false, data: "서버 오류입니다.");
  }
}
