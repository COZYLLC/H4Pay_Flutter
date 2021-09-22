import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';

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

Future<H4PayUser?> userFromStorage() async {
  final storage = new FlutterSecureStorage();
  try {
    final Map userJson = await storage.readAll();
    return H4PayUser.fromjson(userJson);
  } catch (e) {
    return null;
  }
}

Future<H4PayUser?> tokenCheck(String _token) async {
  final response = await http.post(
    Uri.parse("${dotenv.env['API_URL']}/users/tokencheck"),
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
