import 'dart:io';

import 'package:flutter/foundation.dart';

exitApp() {
  if (!kIsWeb) exit(0);
}
