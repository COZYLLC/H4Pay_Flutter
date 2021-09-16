import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class WebViewExample extends StatefulWidget {
  final amount;
  final orderId;
  WebViewExample({required this.amount, required this.orderId});

  @override
  WebViewExampleState createState() => WebViewExampleState();
}

class WebViewExampleState extends State<WebViewExample> {
  WebViewController? _webViewController;

  final String paymentHtml = '''
  <html>
  <head>
    <title>결제하기</title>
    <script src="https://js.tosspayments.com/v1"></script>
    <script>
      var clientKey = "test_ck_5GePWvyJnrKWyAz0GB1rgLzN97Eo";
      var tossPayments = TossPayments(clientKey);
    </script>
  </head>
  <body></body>
  </html>
  ''';

  @override
  void initState() {
    super.initState();
    // Enable hybrid composition.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        shape: ContinuousRectangleBorder(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
        ),
        title: Align(
          alignment: Alignment.center,
          child: Container(
            width: 100,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(width: 1, color: Colors.white),
              borderRadius: BorderRadius.all(Radius.circular(38)),
            ),
          ),
        ),
      ),
      body: WebView(
        initialUrl:
            /* Uri.dataFromString(
          paymentHtml,
          mimeType: 'text/html',
          encoding: Encoding.getByName('utf-8'),
        ).toString() */
            "https://h4pay.co.kr/payment?amount=${widget.amount}&orderId=${widget.orderId}",
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          _webViewController = webViewController;
        },
        navigationDelegate: (request) async {
          final appInfo = AppInfo(url: request.url);
          if (appInfo.isAppLink()) {
            try {
              await appInfo.getAppInfo();
              if (await canLaunch(appInfo.appUrl!)) {
                launch(appInfo.appUrl!);
                return NavigationDecision.prevent;
              } else {
                if (Platform.isIOS) {
                  launch("https://apps.apple.com/app/{appInfo.package}");
                } else if (Platform.isAndroid) {
                  launch("market://details?id=${appInfo.package}");
                }
                return NavigationDecision.prevent;
              }
            } catch (e) {
              print("cannot open app");

              return NavigationDecision.prevent;
            }
          } else {
            return NavigationDecision.navigate;
          }
        },
      ),
    );
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
