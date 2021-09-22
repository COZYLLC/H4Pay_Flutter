import 'dart:convert';

import 'package:async/async.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:h4pay_flutter/Cart.dart';
import 'package:h4pay_flutter/Gift.dart';
import 'package:h4pay_flutter/Order.dart';
import 'package:h4pay_flutter/Product.dart';
import 'package:h4pay_flutter/Util.dart';
import 'package:h4pay_flutter/components/Card.dart';
import 'package:h4pay_flutter/components/WebView.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:h4pay_flutter/main.dart';

class Home extends StatefulWidget {
  final SharedPreferences prefs;
  Home(this.prefs);

  @override
  HomeState createState() => HomeState(prefs);
}

class HomeState extends State<Home> {
  final SharedPreferences prefs;
  int? currentTile;
  bool cartClicked = false;
  bool moving = false;
  Future<List<Product>?>? _fetchProduct;
  HomeState(this.prefs);

  @override
  void initState() {
    super.initState();
    _fetchProduct = fetchProduct('homePage');
  }

  @override
  Widget build(BuildContext context) {
    List<double> center = [
      MediaQuery.of(context).size.width * 0.5 -
          MediaQuery.of(context).size.width * 0.3 * 0.5,
      MediaQuery.of(context).size.height * 0.35
    ];
    return FutureBuilder(
      future: _fetchProduct,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final products = snapshot.data as List<Product>;
          return Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    CarouselSlider(
                      options: CarouselOptions(height: 170.0),
                      items: [1, 2, 3, 4, 5].map((i) {
                        return Builder(
                          builder: (BuildContext context) {
                            return Container(
                                width: MediaQuery.of(context).size.width,
                                margin: EdgeInsets.fromLTRB(5, 12, 5, 0),
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.circular(23),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0x1a000000),
                                      offset: Offset(0.0, 1.0),
                                      blurRadius: 6.0,
                                      spreadRadius: 0.1,
                                    ),
                                  ],
                                ),
                                child: Center(
                                    child: Text(
                                  'Advertisement $i',
                                  style: TextStyle(fontSize: 16.0),
                                )));
                          },
                        );
                      }).toList(),
                    ),
                    GridView.count(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      children: List.generate(
                        products.length,
                        (index) {
                          EdgeInsets margin;
                          index % 2 == 0
                              ? margin = EdgeInsets.fromLTRB(22, 12, 9, 12)
                              : margin = EdgeInsets.fromLTRB(9, 12, 22, 12);
                          return ProductCard(
                            product: products[index],
                            isClicked: currentTile == index,
                            cartOnClick: addProductToCart,
                            giftOnClick: () {
                              openGiftAlert(products[index]);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedPositioned(
                curve: Curves.fastOutSlowIn,
                child: cartClicked
                    ? Image.network(
                        products[currentTile!].img,
                        width: MediaQuery.of(context).size.width * 0.3,
                      )
                    : Container(),
                duration: Duration(
                  milliseconds: 500,
                ),
                left: moving
                    ? MediaQuery.of(context).size.width * 0.55
                    : center[0],
                bottom: moving ? 0 : center[1],
              )
            ],
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  addProductToCart(int id) async {
    showSnackbar(
      context,
      "장바구니에 추가되었습니다.",
      Colors.green,
      Duration(
        seconds: 1,
      ),
    );
    final cartString = prefs.getString('cart'); // SharedPrefernce에서 장바구니 로드
    Map cartMap = {"$id": 1}; // 장바구니 데이터가 없을 때 초기 데이터.
    if (cartString != null) {
      cartMap = json.decode(cartString); // 장바구니 데이터 파싱
      cartMap["$id"] == null
          ? cartMap["$id"] = 1
          : cartMap["$id"]++; // 해당 ID의 데이터가 없으면 1개로, 있으면 1 더하기
    }
    prefs.setString(
      'cart',
      json.encode(cartMap),
    ); // 장바구니 데이터 Stringify 후 SharedPreference에 저장
    final MyHomePageState? parentState =
        context.findAncestorStateOfType<MyHomePageState>();
    print(parentState!);
    parentState.setState(() {
      parentState.cartBadgeCount = countAllItemsInCart(cartMap);
    });
    setState(() {
      cartClicked = true;
    });
    await Future.delayed(Duration(milliseconds: 800));
    setState(() {
      moving = true;
    });
    await Future.delayed(Duration(milliseconds: 500));
    setState(() {
      cartClicked = false;
      moving = false;
    });
  }

  openGiftAlert(Product product) {
    final TextEditingController _inputController = new TextEditingController();
    showCustomAlertDialog(
      context,
      "선물 옵션",
      [
        Form(
          child: TextFormField(
            controller: _inputController,
            decoration: InputDecoration(
              labelText: "학번",
            ),
            keyboardType: TextInputType.number,
            maxLength: 4,
          ),
        )
      ],
      [
        TextButton(
          child: Text("확인"),
          onPressed: () async {
            print("[GIFT] ${_inputController.text}");
            final String? result = await checkUserValid(_inputController.text);
            if (result != null) {
              _sendGift(result, product, _inputController.text);
            }
          },
        )
      ],
      true,
    );
    setState(() {
      currentTile = null;
    });
  }

  void _sendGift(String userName, Product product, String stId) {
    final _orderId = "2" + genOrderId() + "000";
    final Map tempPurchase = {
      'type': 'Gift',
      'uidto': stId,
      'amount': product.price,
      'item': {product.id.toString(): 1},
      'orderId': _orderId
    };
    prefs.setString('tempPurchase', json.encode(tempPurchase));
    Navigator.pop(context);
    showAlertDialog(context, "발송 확인", "$userName 님에게 선물을 발송할까요?", () {
      showSnackbar(
        context,
        "$userName 님에게 선물을 전송할게요.",
        Colors.green,
        Duration(
          seconds: 1,
        ),
      );
      Navigator.pop(context);
      showBottomSheet(
        context: context,
        builder: (context) => Container(
          child: WebViewExample(
            type: Gift,
            amount: product.price,
            orderId: _orderId,
            orderName: product.productName,
            customerName: "최경민",
          ),
        ),
      );
    }, () {
      Navigator.pop(context);
    });
  }
}
