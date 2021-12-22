import 'dart:async';

import 'package:screen_brightness/screen_brightness.dart';
import 'package:wakelock/wakelock.dart';

FutureOr<dynamic> disableWakeLock(value) async {
  await ScreenBrightness.resetScreenBrightness();
  await Wakelock.toggle(enable: false);
}
