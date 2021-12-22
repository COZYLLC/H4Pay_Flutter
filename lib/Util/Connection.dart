import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:h4pay/Setting.dart';

Future<bool> connectionCheck() async {
  final connStatus = await Connectivity().checkConnectivity();
  if (connStatus == ConnectivityResult.mobile ||
      connStatus == ConnectivityResult.wifi) {
    try {
      final host = parseHost(API_URL!);
      print(host);
      final socket = await Socket.connect(
        host['host'],
        host['port'],
        timeout: Duration(seconds: 3),
      );
      socket.destroy();
      return true;
    } catch (e) {
      return false;
    }
  }
  return false;
}

Map parseHost(String url) {
  Map result = {
    "host": "",
    "port": "",
  };
  final splitedByColon = url.split(":");
  if (splitedByColon.length > 2) {
    // 포트가 있는 경우
    result['host'] = splitedByColon[1].split("//")[1];
    result['port'] = int.parse(splitedByColon[2].split("/")[0]);
  } else {
    // 포트가 없는 경우
    result['host'] = splitedByColon[1].split("//")[1].split("/")[0];
    result['port'] = splitedByColon[0] == "https" ? 443 : 80;
  }
  return result;
}
