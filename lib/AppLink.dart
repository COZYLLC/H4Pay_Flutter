import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:h4pay/Network/H4PayService.dart';
import 'package:h4pay/Page/Error.dart';
import 'package:h4pay/Page/Purchase/PurchaseDetail.dart';
import 'package:h4pay/Util/Dialog.dart';
import 'package:h4pay/Util/Wakelock.dart';
import 'package:h4pay/Page/Voucher/VoucherView.dart';
import 'package:h4pay/main.dart';
import 'package:h4pay/model/User.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';

final customUriRegex = RegExp(r'h4pay://h4payapp/(\w+)/{0,1}(\w{0,})');
final universalUrlRegex =
    RegExp(r'https://h4pay.co.kr/{0,1}(\w{0,})/{0,1}(\w{0,})');

class H4PayRoute {
  final String route;
  final String? data;
  H4PayRoute({required this.route, this.data});

  static fromCustomUri(String uri) {
    final matches = customUriRegex.firstMatch(uri)?.groups([1, 2]);
    if (matches != null && matches.length >= 1)
      return H4PayRoute(
          route: matches.elementAt(0) ??
              (throw new Exception("올바른 URL 형태가 아닙니다.")),
          data: matches.elementAt(1) ?? "");
  }

  static fromUniversalUrl(String url) {
    final matches = universalUrlRegex.firstMatch(url)?.groups([1, 2]);
    if (matches != null && matches.length >= 1)
      return H4PayRoute(
          route: matches.elementAt(0) ??
              (throw new Exception("올바른 URL 형태가 아닙니다.")),
          data: matches.elementAt(1) ?? "");
  }

  static parseUri(String uri) {
    if (uri.startsWith("https://")) {
      return H4PayRoute.fromUniversalUrl(uri);
    } else if (uri.startsWith("h4pay://")) {
      return H4PayRoute.fromCustomUri(uri);
    }
    return null;
  }
}

Future<Widget?> appLinkToRoute(H4PayRoute route) async {
  final H4PayService service = getService();
  final prefs = await SharedPreferences.getInstance();
  debugPrint(route.route);

  if (route.route == 'giftView') {
    try {
      debugPrint((await userFromStorage())!.token);
      final gift = await service.getGiftDetail(route.data!);
      if (gift.isNotEmpty)
        return PurchaseDetailPage(purchase: gift[0]);
      else
        throw Exception("선물 정보를 불러오지 못했습니다.");
    } catch (e) {
      debugPrint("Failed to fetch gift");
      return ErrorPage(
        e as Exception,
      );
    }
  } else if (route.route == 'voucherView') {
    try {
      final vouchers = await service.getVoucherDetail(route.data!);
      return VoucherDetailPage(voucher: vouchers[0]);
    } catch (e) {
      debugPrint("Failed to fetch voucher");
      return ErrorPage(e as Exception);
    }
  } else if (route.route == 'main') {
    return MyApp(prefs);
  }
  return null;
}

registerListener(context) {
  if (!kIsWeb) {
    debugPrint("registering listener");
    StreamSubscription? _sub;
    _sub = linkStream.listen((String? link) async {
      debugPrint("listener works@");
      if (link == null) throw Error();
      final H4PayRoute? route = H4PayRoute.parseUri(link);
      if (route == null) throw Error();
      final Widget? routeToNavigate = await appLinkToRoute(route);
      if (routeToNavigate != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => routeToNavigate),
        ).then(disableWakeLock);
      } else {
        throw Error();
      }
    }, onError: (err) {
      // Handle exception by warning the user their action did not succeed
      showSnackbar(
        context,
        "앱 링크를 받았지만 열지 못했어요: ${err.toString()}",
        Colors.red,
        Duration(seconds: 1),
      );
    });
  }
}

Future<Widget?> initUniLinks(BuildContext context) async {
  // Platform messages may fail, so we use a try/catch PlatformException.
  registerListener(context);
  debugPrint("registering listener");
  try {
    final String? initialLink = await getInitialLink();
    debugPrint("$initialLink");
    if (initialLink == null) return null;
    final H4PayRoute? route = H4PayRoute.parseUri(initialLink);
    debugPrint("${route?.route}, ${route?.data}");
    return route == null ? null : await appLinkToRoute(route);
  } on PlatformException {
    // Handle exception by warning the user their action did not succeed
    // return?
    return null;
  }
}
