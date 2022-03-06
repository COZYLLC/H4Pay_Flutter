import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:h4pay/Page/Error.dart';
import 'package:h4pay/Page/Purchase/Payment.dart';
import 'package:h4pay/Setting.dart';
import 'package:h4pay/Util/Connection.dart';
import 'package:h4pay/Util/Dialog.dart';
import 'package:h4pay/main.dart';
import 'package:h4pay/model/AppInfo.dart';
import 'package:h4pay/model/Purchase/TempPurchase.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

const IOS_STORE_URL_PREFIX = "https://apps.apple.com/app/";
const ANDROID_STORE_URL_PREFIX = "market://details?id=";

class WebViewExample extends StatefulWidget {
  final TempPurchase tempPurchase;
  WebViewExample({required this.tempPurchase});

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

  FutureOr updateBadges(value) {
    final MyHomePageState? myHomePageState =
        context.findAncestorStateOfType<MyHomePageState>();
    myHomePageState!.updateBadges();
    myHomePageState.setState(() {});
    Navigator.pop(context);
  }

  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers = {
    Factory(() => EagerGestureRecognizer())
  };

  @override
  Widget build(BuildContext context) {
    final url = dotenv.env['WEB_URL']!;
    final Map<String, String> queryParams = {
      "cashReceipt": widget.tempPurchase.cashReceiptType,
      "amount": widget.tempPurchase.amount.toString(),
      "orderId": widget.tempPurchase.orderId,
      "orderName": widget.tempPurchase.orderName,
      "customerName": widget.tempPurchase.customerName,
      "development": isTestMode.toString()
    };
    final splittedUrl = url.split("://");
    final String uri = Uri(
      scheme: splittedUrl[0],
      path: splittedUrl[1] + "/payment",
      query: encodeQueryParameters(queryParams),
    ).toString();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        toolbarHeight: 20,
        centerTitle: true,
        shadowColor: Colors.grey[100],
        automaticallyImplyLeading: false,
        shape: ContinuousRectangleBorder(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(38),
            topRight: Radius.circular(38),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 3,
              decoration: BoxDecoration(
                color: Colors.grey,
                border: Border.all(width: 1, color: Colors.grey),
                borderRadius: BorderRadius.all(Radius.circular(38)),
              ),
            ),
          ],
        ),
      ),
      body: WebView(
        initialUrl: uri,
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          _webViewController = webViewController;
        },
        gestureRecognizers: gestureRecognizers,
        navigationDelegate: (request) async {
          final appInfo = AppInfo(url: request.url);
          if (appInfo.isAppLink()) {
            try {
              await appInfo.getAppInfo();
              debugPrint(appInfo.appUrl);
              if (await canLaunch(appInfo.appUrl!)) {
                launch(appInfo.appUrl!);
                return NavigationDecision.prevent;
              } else {
                String? url;
                if (Platform.isIOS) {
                  final String? iosAppId = appInfo.getIosAppId();
                  if (iosAppId != null) {
                    url = IOS_STORE_URL_PREFIX + iosAppId;
                  } else {
                    return NavigationDecision.prevent;
                  }
                } else if (Platform.isAndroid) {
                  url = ANDROID_STORE_URL_PREFIX + appInfo.package!;
                }
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("앱 설치"),
                        content:
                            const Text("결제를 위한 앱이 설치되어 있지 않습니다. 스토어로 이동합니다."),
                        actions: [
                          TextButton(
                            onPressed: () {
                              launch(url!);
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
              return NavigationDecision.prevent;
            }
          } else if (request.url.startsWith("$url/paySuccess")) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PaymentSuccessPage(
                  tempPurchase: widget.tempPurchase,
                  params: _parseParams(request.url),
                ),
              ),
            ).then(updateBadges);
            return NavigationDecision.prevent;
          } else if (request.url.startsWith("$url/payFail")) {
            final errMsg = Uri.decodeFull(
              Uri.dataFromString(request.url).queryParameters['message']!,
            );
            Navigator.pop(context);
            navigateRoute(
              context,
              ErrorPage(Exception(errMsg)),
            );
            return NavigationDecision.prevent;
          } else {
            return NavigationDecision.navigate;
          }
        },
      ),
    );
  }

  Map _parseParams(String url) {
    final params = url.split('?')[1].split("&");
    var parsedParams = {};
    for (var i = 0; i < 3; i++) {
      final param = params[i].split("=");
      parsedParams[param[0]] = param[1];
    }
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
    appScheme = Uri.parse(this.url).scheme;
    return appScheme != 'http' &&
        appScheme != 'https' &&
        appScheme != 'about' &&
        appScheme != 'data';
  }

  String? getIosAppId() {
    try {
      final PreparedAppInfo appInfo = appLinks.singleWhere(
        (element) => element.scheme == appScheme,
      );
      return appInfo.appleAppId;
    } catch (e) {
      return null;
    }
  }

  getAppInfo() async {
    List<String> splittedUrl =
        this.url.replaceFirst(RegExp(r'://'), ' ').split(' ');
    this.appScheme = splittedUrl[0];

    if (Platform.isIOS) {
      appUrl = appScheme == 'itmss' ? 'https://${splittedUrl[1]}' : url;
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

  final List<PreparedAppInfo> appLinks = [
    PreparedAppInfo(
        appName: "토스", appleAppId: "id839333328", scheme: "supertoss"),
    PreparedAppInfo(
        appName: "현대카드 앱카드",
        appleAppId: "id702653088",
        scheme: "hdcardappcardansimclick"),
    PreparedAppInfo(
        appName: "현대카드 공인인증서",
        appleAppId: "id702653088",
        scheme: "smhyundaiansimclick"),
    PreparedAppInfo(
        appName: "우리WON카드",
        appleAppId: "id1499598869",
        scheme: "com.wooricard.wcard"),
    PreparedAppInfo(
        appName: "우리WON뱅킹", appleAppId: "id1470181651", scheme: "newsmartpib"),
    PreparedAppInfo(
        appName: "신한카드 앱카드",
        appleAppId: "id572462317",
        scheme: "shinhan-sr-ansimclick"),
    PreparedAppInfo(
        appName: "신한카드 공인인증서",
        appleAppId: "id572462317",
        scheme: "smshinhanansimclick"),
    PreparedAppInfo(
        appName: "KB Pay", appleAppId: "id695436326", scheme: "kb-acp"),
    PreparedAppInfo(
        appName: "롯데카드 앱카드", appleAppId: "id688047200", scheme: "lotteappcard"),
    PreparedAppInfo(
        appName: "하나카드 앱카드", appleAppId: "id847268987", scheme: "cloudpay"),
    PreparedAppInfo(
        appName: "농협카드 앱카드",
        appleAppId: "id1177889176",
        scheme: "nhappvardansimclick"),
    PreparedAppInfo(
        appName: "농협카드 공인인증서",
        appleAppId: "id1177889176",
        scheme: "nonghyupcardansimclick"),
    PreparedAppInfo(
        appName: "씨티카드 앱카드", appleAppId: "id1179759666", scheme: "citispay"),
    PreparedAppInfo(
        appName: "씨티카드 공인인증서",
        appleAppId: "id1179759666",
        scheme: "citicardappkr"),
    PreparedAppInfo(
        appName: "씨티카드 앱카드",
        appleAppId: "id1179759666",
        scheme: "citimobileapp"),
    PreparedAppInfo(
        appName: "ISP모바일", appleAppId: "id369125087", scheme: "ispmobile")
  ];
}

class WebViewScaffold extends StatelessWidget {
  final String initialUrl;
  final String title;

  const WebViewScaffold(
      {Key? key, required this.title, required this.initialUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: H4PayAppbar(
        title: title,
        height: 56.0,
        canGoBack: true,
      ),
      body: WebView(
        initialUrl: initialUrl,
      ),
    );
  }
}
