import 'dart:convert';

import 'package:crypto/crypto.dart';

String encryptPassword(String string) {
  final bytes = utf8.encode(string);
  final digest = sha256.convert(bytes);
  return base64.encode(digest.bytes);
}
