import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:h4pay/exception.dart';
import 'package:h4pay/model/Maintenance.dart';

Future<Maintenance> fetchMaintenence() async {
  final networkResponse =
      await http.get(Uri.parse(dotenv.env['MAINTENENCE_URL']!));
  if (networkResponse.statusCode == 200) {
    final jsonResponse = json.decode(networkResponse.body);
    return Maintenance.fromJson(jsonResponse);
  } else {
    throw NetworkException(networkResponse.statusCode);
  }
}
