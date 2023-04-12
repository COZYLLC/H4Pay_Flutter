// ignore_for_file: non_constant_identifier_names

import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

String? apiUrl;
bool isTestMode = dotenv.env["TEST_MODE"] == "TRUE";
final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();
