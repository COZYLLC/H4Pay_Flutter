import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:h4pay_flutter/Order.dart';
import 'package:h4pay_flutter/Payment.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewExample extends StatefulWidget {
  final amount;
  final orderId;
  final orderName;
  final customerName;
  final Type type;
  WebViewExample(
      {required this.amount,
      required this.orderId,
      required this.orderName,
      required this.customerName,
      required this.type});

  @override
  WebViewExampleState createState() => WebViewExampleState();
}

class WebViewExampleState extends State<WebViewExample> {
  WebViewController? _webViewController;
  bool isMoved = false;

  @override
  void initState() {
    super.initState();
    // Enable hybrid composition.
  }

  @override
  Widget build(BuildContext context) {
    final url = "http://192.168.1.253:8080";
    return Scaffold(
      body: WebView(
        initialUrl:
            //"https://h4pay.co.kr/payment?amount=${widget.amount}&orderId=${widget.orderId}",
            "$url/payment?amount=${widget.amount}&orderId=${widget.orderId}&orderName=${widget.orderName}&customerName=${widget.customerName}",

        //"http://10.172.16.134:8080/payment/success/presuccess.html",
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          _webViewController = webViewController;
        },
        navigationDelegate: (request) async {
          print("[WEBVIEW] ${request.url}");
          print("[WEBVIEW] ${request.url.startsWith("$url/payment/success")}");
          final appInfo = AppInfo(url: request.url);
          if (appInfo.isAppLink()) {
            try {
              await appInfo.getAppInfo();
              if (await canLaunch(appInfo.appUrl!)) {
                launch(appInfo.appUrl!);
                return NavigationDecision.prevent;
              } else {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("앱 설치"),
                        content: const Text("토스 앱이 설치되어 있지 않습니다. 스토어로 이동합니다."),
                        actions: [
                          TextButton(
                            onPressed: () {
                              if (Platform.isIOS) {
                                launch(
                                  "https://apps.apple.com/app/id839333328",
                                );
                              } else if (Platform.isAndroid) {
                                launch(
                                  "market://details?id=${appInfo.package}",
                                );
                              }
                              Navigator.pop(context);
                            },
                            child: Text("확인"),
                          ),
                        ],
                      );
                    });
                return NavigationDecision.prevent;
              }
            } catch (e) {
              print("cannot open app");
              return NavigationDecision.prevent;
            }
          } else if (request.url.startsWith("$url/payment/success")) {
            print("[WEBVIEW] PAYMENT SUCCESS");
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PaymentSuccessPage(
                  type: widget.type,
                  params: _parseParams(request.url),
                ),
              ),
            );
            return NavigationDecision.prevent;
          } else if (request.url.startsWith("$url/payment/fail")) {
            Navigator.pop(context);
            return NavigationDecision.prevent;
          } else {
            return NavigationDecision.navigate;
          }
        },
      ),
    );
  }

  Map _parseParams(String url) {
    print("[API] $url");
    final params = url.split('/success?')[1].split("&");
    var parsedParams = {};
    for (var i = 0; i < 3; i++) {
      final param = params[i].split("=");
      parsedParams[param[0]] = param[1];
    }
    print("[API] $parsedParams");
    return parsedParams;
  }
}

class AppInfo {
  final String url;
  String? appScheme;
  String? appUrl;
  String? package;
  AppInfo({required this.url});

  bool isAppLink() {
    final appScheme = Uri.parse(this.url).scheme;

    return appScheme != 'http' &&
        appScheme != 'https' &&
        appScheme != 'about:blank' &&
        appScheme != 'data';
  }

  getAppInfo() {
    List<String> splittedUrl =
        this.url.replaceFirst(RegExp(r'://'), ' ').split(' ');
    this.appScheme = splittedUrl[0];
    if (Platform.isIOS) {
      this.appUrl =
          this.appScheme == 'itmss' ? 'https://${splittedUrl[1]}' : url;
    } else if (Platform.isAndroid) {
      if (this.isAppLink()) {
        if (this.appScheme!.contains('intent')) {
          List<String> intentUrl = splittedUrl[1].split('#Intent;');
          String host = intentUrl[0];

          List<String> arguments = intentUrl[1].split(';');
          arguments.forEach(
            (s) {
              if (s.startsWith('scheme')) {
                String scheme = s.split('=')[1]; //scheme
                this.appUrl = scheme + '://' + host;
                this.appScheme = scheme;
              } else if (s.startsWith('package')) {
                this.package = s.split('=')[1];
              }
            },
          );
        } else {
          this.appUrl = url;
        }
      } else {
        this.appUrl = url;
      }
    }
  }

  final appLinks = [
    'tauthlink://',
    'ktauthexternalcall://',
    'upluscorporation://',
    'ispmobile://',
    'shinsegaeeasypayment://',
    'payco://',
    'lpayapp://',
    'smhyundaiansimclick://',
    'hdcardappcardansimclick://',
    'hanawalletmembers://',
    'cloudpay://',
    'citimobileapp://',
    'citicardappkr://',
    'citispay://',
    'newsmartpib://',
    'com.wooricard.wcard://',
    'smshinhanansimclick://',
    'shinhan-sr-ansimclick://',
    'scardcertiapp://',
    'samsungpay://',
    'vguardstart://',
    'ansimclickipcollect://',
    'tswansimclick://',
    'ansimclickscard://',
    'mpocket.online.ansimclick://',
    'lotteappcard://',
    'lottesmartpay://',
    'nonghyupcardansimclick://',
    'nhallonepayansimclick://',
    'nhappcardansimclick://',
    'liivbank://',
    'kb-acp://',
    'supertoss://'
  ];
}

class WebViewScaffold extends StatelessWidget {
  final String initialUrl;

  const WebViewScaffold({Key? key, required this.initialUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: ContinuousRectangleBorder(),
      ),
      body: WebView(
        initialUrl: initialUrl,
      ),
    );
  }
}
