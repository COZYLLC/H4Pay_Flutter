import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:h4pay/Network/H4PayService.dart';
import 'package:json_annotation/json_annotation.dart';

part 'User.g.dart';

@JsonSerializable()
class H4PayUser {
  String? uid;
  String? name;
  String? email;
  String? role;
  String? tel;
  String? token;
  final storage = new FlutterSecureStorage();

  H4PayUser({
    this.uid,
    this.name,
    this.email,
    this.role,
    this.tel,
    this.token,
  });

  factory H4PayUser.fromJson(Map<String, dynamic> json) =>
      _$H4PayUserFromJson(json);
  Map<String, dynamic> toJson() => _$H4PayUserToJson(this);

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
    final Map<String, dynamic> userJson = await storage.readAll();
    final H4PayUser user = H4PayUser.fromJson(userJson);
    return await getService().tokenCheck(user.token!);
  } catch (e) {
    return null;
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
