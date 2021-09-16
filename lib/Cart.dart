import 'dart:convert';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:h4pay_flutter/Product.dart';
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
    final cartString = prefs.getString('cart');
    if (cartString != null) {
      cartMap = json.decode(cartString);
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
                    ListView.builder(
                      itemCount: cartMap.length,
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        final idx =
                            int.parse(cartMap.keys.elementAt(index) as String);
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
                                text: totalPrice.toString(),
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(
                              text: ' 원',
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {
                          showBottomSheet(
                            context: context,
                            builder: (context) => Container(
                              height: MediaQuery.of(context).size.height * 0.75,
                              child: WebViewExample(
                                  amount: 2000, orderId: "48324328432984275"),
                            ),
                          );
                        },
                        child: Text("결제하기"),
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                              side: BorderSide(color: Colors.grey[400]!),
                            ),
                          ),
                        ),
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
}
