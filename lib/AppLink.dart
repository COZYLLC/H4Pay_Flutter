import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:h4pay/Purchase/Gift.dart';
import 'package:h4pay/IntroPage.dart';
import 'package:h4pay/Page/Purchase/PurchaseDetail.dart';
import 'package:h4pay/Util.dart';
import 'package:h4pay/Util/Wakelock.dart';
import 'package:h4pay/Voucher.dart';
import 'package:h4pay/Page/Voucher/VoucherView.dart';
import 'package:h4pay/main.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';
import 'package:wakelock/wakelock.dart';

Future<Widget?> appLinkToRoute(H4PayRoute route) async {
  if (route.route == 'giftView') {
    final Gift? gift = await fetchGiftDetail(route.data);
    if (gift != null) {
      return PurchaseDetailPage(purchase: gift);
    } else {
      return null;
    }
  } else if (route.route == 'voucherView') {
    final Voucher? voucher = await fetchVoucherDetail(route.data);
    if (voucher != null) {
      return VoucherDetailPage(voucher: voucher);
    } else {
      return null;
    }
  } else if (route.route == 'main') {
    final prefs = await SharedPreferences.getInstance();
    return MyApp(prefs);
  }
}

H4PayRoute? parseUrl(String url) {
  if (url.startsWith("https://")) {
    return H4PayRoute(route: url.split("/")[3], data: url.split("/")[4]);
  } else if (url.startsWith("h4pay://")) {
    final String routeWithoutProtocol = url.split("//")[1];
    final List<String> routes = routeWithoutProtocol.split("/");
    return H4PayRoute(
      route: routes[1],
      data: routes[2],
    );
  }
  return null;
}

registerListener(context) {
  StreamSubscription? _sub;
  _sub = linkStream.listen((String? link) async {
    if (link != null) {
      final H4PayRoute? route = parseUrl(link);
      if (route != null) {
        final Widget? routeToNavigate = await appLinkToRoute(route);
        if (routeToNavigate != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => routeToNavigate),
          ).then(disableWakeLock);
        } else {
          throw Error();
        }
      }
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

Future<Widget?> initUniLinks(BuildContext context) async {
  // Platform messages may fail, so we use a try/catch PlatformException.
  H4PayRoute? route;
  try {
    final String? initialLink = await getInitialLink();
    if (initialLink != null) {
      route = parseUrl(initialLink);
    }
    return route == null ? null : await appLinkToRoute(route);
  } on PlatformException {
    // Handle exception by warning the user their action did not succeed
    // return?
    return null;
  }
}
