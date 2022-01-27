import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:h4pay/Network/H4PayService.dart';
import 'package:h4pay/Util/Generator.dart';
import 'package:h4pay/exception.dart';
import 'package:h4pay/model/Product.dart';
import 'package:h4pay/model/Purchase/Order.dart';
import 'package:h4pay/model/User.dart';
import 'package:h4pay/Util/Beautifier.dart';
import 'package:h4pay/Util/Dialog.dart';
import 'package:h4pay/components/Button.dart';
import 'package:h4pay/components/Card.dart';
import 'package:h4pay/components/WebView.dart';
import 'package:h4pay/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:collection/collection.dart';

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
      try {
        price += products
                .singleWhereOrNull((element) => element.id == int.parse(key))!
                .price *
            value;
      } catch (e) {}
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
  final H4PayService service = getService();
  CartState(this.prefs);

  int totalPrice = 0;

  Map cartMap = {};
  List<Product>? products;
  Future<List<Product>?>? _fetchProduct;
  List<String> cashReceipts = ["미발급", "소득공제", "지출증빙"];
  String cashReceiptType = "미발급";

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
    try {
      _fetchProduct = service.getProducts();
    } on NetworkException catch (e) {
      showServerErrorSnackbar(context, e);
    }
    loadCart();
  }

  loadCart() {
    final cartString = prefs.getString('cart');
    if (cartString != null) {
      setState(() {
        cartMap = json.decode(cartString);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                                product: products!.firstWhereOrNull(
                                    (product) => product.id == idx)!,
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
                                    text: getPrettyAmountStr(totalPrice),
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
/*                           Row(
                            children: [
                              Text("현금영수증 옵션"),
                              Container(width: 10),
                              DropdownButton(
                                value: cashReceiptType,
                                icon: Icon(Icons.keyboard_arrow_down),
                                items: cashReceipts.map((String items) {
                                  return DropdownMenuItem(
                                    value: items,
                                    child: Text(items),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    cashReceiptType = value as String;
                                  });
                                },
                              ),
                            ],
                          ), */
                          H4PayButton(
                            text: "결제하기",
                            onClick: _payment,
                            backgroundColor: Theme.of(context).primaryColor,
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

  List<String?>? checkSoldout() {
    List<String> soldoutProducts = [];
    cartMap.entries.forEach((item) {
      final product = products!.singleWhereOrNull(
        (product) => product.id == int.parse(item.key),
      );
      if (product != null) {
        if (product.soldout) {
          soldoutProducts.add(product.productName);
        }
      } else {
        return null;
      }
    });
    return soldoutProducts;
  }

  _payment() async {
    products = await service.getProducts();
    final List<String?>? soldoutList = checkSoldout();
    if (soldoutList != null) {
      var soldoutString = "";
      soldoutList.forEachIndexed((idx, element) {
        soldoutString +=
            (element! + (idx + 1 == soldoutList.length ? "" : ", "));
      });
      if (soldoutList.length != 0) {
        showSnackbar(
          context,
          "품절된 상품이 있어요: $soldoutString",
          Colors.red,
          Duration(seconds: 1),
        );
        return;
      }
    }

    final _orderId = "1" + genOrderId() + "000";
    final tempPurchase = {
      'type': 'Order',
      'amount': this.totalPrice,
      'item': cartMap,
      'orderId': _orderId
    };
    prefs.setString('tempPurchase', json.encode(tempPurchase));
    final H4PayUser? user = await userFromStorageAndVerify();
    if (user != null) {
      showBottomSheet(
        context: context,
        builder: (context) => Container(
          //height: MediaQuery.of(context).size.height,
          child: WebViewExample(
              type: Order,
              amount: this.totalPrice,
              orderId: _orderId,
              orderName: getOrderName(
                tempPurchase['item'] as Map,
                products!
                    .singleWhereOrNull((element) =>
                        element.id.toString() ==
                        cartMap.entries.elementAt(0).key)!
                    .productName,
              ),
              customerName: user.name!,
              cashReceiptType: cashReceiptType),
        ),
      ).closed.whenComplete(() => loadCart());
    } else {
      showSnackbar(
          context, "사용자 정보를 불러올 수 없습니다.", Colors.red, Duration(seconds: 1));
    }
  }
}
