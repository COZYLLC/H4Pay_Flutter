import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:h4pay/Gift.dart';
import 'package:h4pay/IntroPage.dart';
import 'package:h4pay/PurchaseDetail.dart';
import 'package:h4pay/Util.dart';
import 'package:uni_links/uni_links.dart';

Future<Widget?> appLinkToRoute(H4PayRoute route) async {
  if (route.route == 'giftView') {
    print("gift route");

    final Gift? gift = await fetchGiftDetail(route.data);
    if (gift != null) {
      return PurchaseDetailPage(purchase: gift);
    } else {
      return null;
    }
  }
}

H4PayRoute parseUrl(String url) {
  return H4PayRoute(route: url.split("/")[3], data: url.split("/")[4]);
}

registerListener(context) {
  StreamSubscription? _sub;
  print("registered listener");
  _sub = linkStream.listen((String? link) async {
    print("link listened");
    if (link != null) {
      final H4PayRoute route = parseUrl(link);
      final Widget? routeToNavigate = await appLinkToRoute(route);
      if (routeToNavigate != null) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => routeToNavigate));
      } else {
        throw Error();
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
    print(initialLink);
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