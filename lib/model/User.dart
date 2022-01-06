import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:h4pay/Network/User.dart';

class H4PayUser {
  String? uid;
  String? name;
  String? email;
  String? role;
  String? tel;
  String token;
  final storage = new FlutterSecureStorage();

  H4PayUser({
    this.uid,
    this.name,
    this.email,
    this.role,
    this.tel,
    required this.token,
  });

  factory H4PayUser.fromjson(Map json) {
    return H4PayUser(
      uid: json['uid'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      tel: json['tel'],
      token: json['token'],
    );
  }

  Future<bool> saveToStorage() async {
    try {
      await storage.deleteAll();
      await storage.write(key: 'uid', value: this.uid);
      storage.write(key: 'name', value: this.name);
      storage.write(key: 'email', value: this.email);
      storage.write(key: 'role', value: this.role);
      storage.write(key: 'tel', value: this.tel);
      storage.write(key: 'token', value: this.token);
      return true;
    } catch (e) {
      return false;
    }
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
