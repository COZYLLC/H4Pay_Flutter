import 'dart:convert';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:h4pay_flutter/Gift.dart';
import 'package:h4pay_flutter/Order.dart';
import 'package:h4pay_flutter/Product.dart';
import 'package:h4pay_flutter/User.dart';
import 'package:h4pay_flutter/Util.dart';
import 'package:h4pay_flutter/components/Button.dart';
import 'package:h4pay_flutter/components/Card.dart';
import 'package:h4pay_flutter/components/WebView.dart';
import 'package:h4pay_flutter/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

int countAllItemsInCart(Map cartMap) {
  int itemCount = 0;
  cartMap.forEach(
    (key, value) {
      itemCount += value as int;
    },
  );
  return itemCount;
}

int calculateTotalPrice(Map cartMap, List<Product> products) {
  num price = 0;
  cartMap.forEach(
    (key, value) {
      price += products[int.parse(key)].price * value;
    },
  );
  return price.toInt();
}

class Cart extends StatefulWidget {
  final SharedPreferences prefs;

  @override
  Cart(this.prefs);

  CartState createState() => CartState(prefs);
}

class CartState extends State<Cart> {
  final SharedPreferences prefs;
  CartState(this.prefs);
  int totalPrice = 0;

  Map cartMap = {};
  List<Product>? products;
  Future<List<Product>?>? _fetchProduct;

  void updateCart() {
    prefs.setString('cart', json.encode(cartMap));
    final MyHomePageState? parentState =
        context.findAncestorStateOfType<MyHomePageState>();
    parentState!.setState(() {
      parentState.cartBadgeCount = countAllItemsInCart(cartMap);
    });
    setState(() {
      totalPrice = calculateTotalPrice(cartMap, products!);
    });
  }

  void incrementCounter(idx) {
    setState(() {
      cartMap['$idx']++;
    });
    updateCart();
  }

  void decrementCounter(idx) {
    setState(() {
      cartMap['$idx']--;
    });
    updateCart();
  }

  @override
  void initState() {
    super.initState();
    _fetchProduct = fetchProduct('cartPage');
    loadCart();
  }

  loadCart() {
    final cartString = prefs.getString('cart');
    print("[CART] $cartString");
    if (cartString != null) {
      setState(() {
        cartMap = json.decode(cartString);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: _fetchProduct!,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              products = snapshot.data as List<Product>;
              SchedulerBinding.instance!.addPostFrameCallback((_) {
                setState(() {
                  totalPrice = calculateTotalPrice(cartMap, products!);
                });
              });
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                child: Column(
                  children: [
                    AnimatedCrossFade(
                      firstChild: Column(
                        children: [
                          ListView.builder(
                            itemCount: cartMap.length,
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              final idx = int.parse(
                                  cartMap.keys.elementAt(index) as String);
                              return CartCard(
                                product: products![idx],
                                qty: cartMap['$idx'],
                              );
                            },
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text.rich(
                              TextSpan(
                                text: '총 가격: ',
                                children: <TextSpan>[
                                  TextSpan(
                                    text: getPrettyAmountStr(
                                      totalPrice,
                                    ),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          H4PayButton(
                            text: "결제하기",
                            onClick: _payment,
                            backgroundColor: Colors.blue,
                            width: double.infinity,
                          )
                        ],
                      ),
                      secondChild: Container(
                        height: MediaQuery.of(context).size.height * 0.8,
                        alignment: Alignment.center,
                        child: Text(
                          "장바구니가 비어 있는 것 같네요.",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w700),
                        ),
                      ),
                      crossFadeState: this.totalPrice != 0
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      duration: Duration(
                        milliseconds: 500,
                      ),
                    )
                  ],
                ),
              );
            } else {
              return CardWidget(
                margin: EdgeInsets.all(22),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 16.0),
                      width: double.infinity,
                      height: 100,
                      child: Shimmer.fromColors(
                        child: Container(),
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                      ),
                    ),
                  ],
                ),
                onClick: () {},
              );
            }
          },
        ),
      ),
    );
  }

  _payment() async {
    final _orderId = "1" + genOrderId() + "000";
    final tempPurchase = {
      'type': 'Order',
      'amount': this.totalPrice,
      'item': cartMap,
      'orderId': _orderId
    };
    prefs.setString('tempPurchase', json.encode(tempPurchase));
    final H4PayUser? user = await userFromStorage();
    if (user != null) {
      showBottomSheet(
        context: context,
        builder: (context) => Container(
          //height: MediaQuery.of(context).size.height,
          child: WebViewExample(
            type: Order,
            amount: this.totalPrice,
            orderId: _orderId,
            orderName:
                getProductNameFromList(tempPurchase['item'] as Map, products!),
            customerName: user.name,
          ),
        ),
      ).closed.whenComplete(() => loadCart());
    } else {
      showSnackbar(
          context, "사용자 정보를 불러올 수 없습니다.", Colors.red, Duration(seconds: 1));
    }
  }
}
