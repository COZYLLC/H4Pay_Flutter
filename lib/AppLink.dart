import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:h4pay/Network/H4PayService.dart';
import 'package:h4pay/Page/Error.dart';
import 'package:h4pay/Page/Purchase/PurchaseDetail.dart';
import 'package:h4pay/Util/Dialog.dart';
import 'package:h4pay/Util/Wakelock.dart';
import 'package:h4pay/Page/Voucher/VoucherView.dart';
import 'package:h4pay/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';

class H4PayRoute {
  final String route;
  final String? data;
  H4PayRoute({required this.route, this.data});
}

Future<Widget?> appLinkToRoute(H4PayRoute route) async {
  final H4PayService service = getService();
  final prefs = await SharedPreferences.getInstance();

  if (route.route == 'giftView') {
    try {
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
}

H4PayRoute? parseUrl(String url) {
  print(url);
  if (url.startsWith("https://")) {
    return H4PayRoute(route: url.split("/")[3], data: url.split("/")[4]);
  } else if (url.startsWith("h4pay://")) {
    final String routeWithoutProtocol = url.split("//")[1];
    final List<String> routes = routeWithoutProtocol.split("/");
    return H4PayRoute(
      route: routes[1],
      data: routes[1] == 'main' ? null : routes[2],
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
