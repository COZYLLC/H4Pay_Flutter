import 'dart:async';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:dio/dio.dart';
import 'package:h4pay/Page/Info.dart';
import 'package:h4pay/Util/Connection.dart';
import 'package:h4pay/Util/Dialog.dart';
import 'package:h4pay/components/Button.dart';
import 'package:h4pay/dialog/H4PayDialog.dart';
import 'package:h4pay/exception.dart';
import 'package:h4pay/main.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:device_info_plus/device_info_plus.dart';

class ErrorPage extends StatelessWidget {
  final Exception error;
  ErrorPage(this.error);
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  Future<String> buildExampleBody() async {
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      final vendor = androidInfo.manufacturer;
      final model = androidInfo.model;
      final buildInfo = androidInfo.bootloader;
      return Uri(
        scheme: "mailto",
        path: "support@cozyllc.co.kr",
        query: encodeQueryParameters(
          {
            "subject": "H4Pay 오류 신고",
            "body":
                "제조사: $vendor\n모델명: $model\n소프트웨어 정보: $buildInfo\n증상 및 발생조건:\n",
          },
        ),
      ).toString();
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      final vendor = "Apple";
      final model = iosInfo.utsname.machine;
      final buildInfo =
          "${iosInfo.systemName} | ${iosInfo.systemVersion} | ${iosInfo.utsname.version}";
      return Uri(
        scheme: "mailto",
        path: "support@cozyllc.co.kr",
        query: encodeQueryParameters(
          {
            "subject": "H4Pay 오류 신고",
            "body":
                "제조사: $vendor\n모델명: $model\n소프트웨어 정보: $buildInfo\n증상 및 발생조건:\n",
          },
        ),
      ).toString();
    } else {
      return "기기 제조사:\n모델명:\n소프트웨어 정보(선택):\n증상 및 발생조건:";
    }
  }

  String extractMessage() {
    if (error is H4PayException) {
      return (error as H4PayException).message;
    } else {
      return error.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: H4PayAppbar(canGoBack: true, height: 56, title: "오류"),
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/image/error.png",
              width: MediaQuery.of(context).size.width * 0.4,
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                "오류가 발생했습니다.",
                style: TextStyle(fontSize: 28),
              ),
            ),
            Text(extractMessage().replaceFirst("Exception: ", "오류 상세 내용: ")),
            Container(
              margin: EdgeInsets.only(top: 20),
              child: H4PayButton(
                text: "오류 대응 빠르게 받는 방법 알아보기",
                onClick: () {
                  showCustomAlertDialog(
                      context,
                      H4PayDialog(
                        title: "오류 신고 방법",
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text.rich(
                              TextSpan(
                                text: "스크린샷을 찍어 앱 내 왼쪽 하단 지원 페이지 혹은 ",
                                children: [
                                  TextSpan(
                                    text: "support@cozyllc.co.kr",
                                    recognizer: new TapGestureRecognizer()
                                      ..onTap = () async {
                                        final body = await buildExampleBody();
                                        final launchRes = await launch(
                                          body,
                                        );
                                        debugPrint(launchRes.toString());
                                      },
                                    style: TextStyle(
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                  TextSpan(
                                    text: " 로 문의주시면 빠르게 대응해드리겠습니다.",
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          H4PayOkButton(
                            context: context,
                            onClick: () {
                              Navigator.pop(context);
                            },
                          )
                        ],
                      ),
                      true);
                },
                backgroundColor: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
