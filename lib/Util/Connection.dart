import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:h4pay/Setting.dart';
import 'package:h4pay/Util/Dialog.dart';
import 'package:h4pay/components/Button.dart';
import 'package:h4pay/dialog/H4PayDialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

showIpChangeDialog(BuildContext context, GlobalKey<FormState> formKey,
    TextEditingController ipController) {
  showCustomAlertDialog(
      context,
      H4PayDialog(
        title: "서버 URL 변경",
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                "서버 URL을 프로토콜, 포트, Route와 함께 입력해주세요. ex) https://yoon-lab.xyz:23408/api"),
            Form(
              key: formKey,
              child: TextFormField(
                controller: ipController,
                validator: (value) {
                  return value!.isNotEmpty ? null : "URL을 입력해주세요.";
                },
              ),
            )
          ],
        ),
        actions: [
          H4PayOkButton(
            context: context,
            onClick: () async {
              FocusScope.of(context).requestFocus(FocusNode());
              if (formKey.currentState!.validate()) {
                final _prefs = await SharedPreferences.getInstance();
                _prefs.setString(
                  'API_URL',
                  ipController.text,
                );
                API_URL = ipController.text;
                print("API URL newly setted: $API_URL");
                final connStatus = await connectionCheck();
                if (connStatus) {
                  Navigator.pop(context);
                  showSnackbar(
                    context,
                    "IP '${ipController.text}' 로 서버 URL을 설정합니다.",
                    Colors.green,
                    Duration(seconds: 1),
                  );
                } else {
                  showSnackbar(
                    context,
                    "IP '${ipController.text}' 로 연결을 시도했지만 잘 안 되는 것 같네요...",
                    Colors.red,
                    Duration(seconds: 1),
                  );
                }
              }
            },
          )
        ],
      ),
      true);
}
