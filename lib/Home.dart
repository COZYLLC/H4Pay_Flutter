import 'dart:convert';

import 'package:async/async.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:h4pay_flutter/Cart.dart';
import 'package:h4pay_flutter/Event.dart';
import 'package:h4pay_flutter/Gift.dart';
import 'package:h4pay_flutter/Notice.dart';
import 'package:h4pay_flutter/Order.dart';
import 'package:h4pay_flutter/Product.dart';
import 'package:h4pay_flutter/Result.dart';
import 'package:h4pay_flutter/User.dart';
import 'package:h4pay_flutter/Util.dart';
import 'package:h4pay_flutter/components/Button.dart';
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

  Future<Map>? future;
  HomeState(this.prefs);

  @override
  void initState() {
    super.initState();
    future = _fetchThings();
  }

  Future<Map> _fetchThings() async {
    Map data = {};
    data['product'] = await fetchProduct('homePage');
    data['notice'] = await fetchNotice();
    data['event'] = await fetchEvent();
    return data;
  }

  @override
  Widget build(BuildContext context) {
    List<double> center = [
      MediaQuery.of(context).size.width * 0.5 -
          MediaQuery.of(context).size.width * 0.3 * 0.5,
      MediaQuery.of(context).size.height * 0.35
    ];
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data as Map;
          final products = data['product'] as List<Product>;
          final notices = data['notice'] as List<Notice>;
          final event = data['event'] as List<Event>;
          final noticeSublist =
              notices.length > 3 ? notices.sublist(0, 2) : notices;
          final eventSublist = event.length > 3 ? event.sublist(0, 2) : event;
          final adList = [...noticeSublist, ...eventSublist];
          return Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    CarouselSlider(
                      options: CarouselOptions(
                        height: MediaQuery.of(context).size.height * 0.165,
                      ),
                      items: adList.map((i) {
                        return Builder(
                          builder: (BuildContext context) {
                            return InkWell(
                              onTap: () {
                                i.runtimeType == Notice
                                    ? showNoticeCard(context, i)
                                    : showEventCard(context, i as Event);
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                margin: EdgeInsets.fromLTRB(5, 12, 5, 0),
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: NetworkImage(
                                        i.img,
                                      ),
                                      fit: BoxFit.fitHeight),
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
                              ),
                            );
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
                    ? CachedNetworkImage(
                        imageUrl: products[currentTile!].img,
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
    if (!mounted) return;
    setState(() {
      cartClicked = true;
    });
    await Future.delayed(Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() {
      moving = true;
    });
    await Future.delayed(Duration(milliseconds: 500));
    if (!mounted) return;

    setState(() {
      cartClicked = false;
      moving = false;
    });
  }

  openGiftAlert(Product product) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final TextEditingController studentId = new TextEditingController();
    final TextEditingController qty = new TextEditingController();
    showCustomAlertDialog(
      context,
      "선물 옵션",
      [
        Form(
          key: _formKey,
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: studentId,
                  decoration: InputDecoration(
                    labelText: "학번",
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  validator: (value) {
                    return value!.length == 4 ? null : "올바른 학번을 입력해주세요.";
                  },
                ),
              ),
              Spacer(flex: 1),
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: qty,
                  decoration: InputDecoration(
                    labelText: "수량",
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  validator: (value) {
                    return value!.length == 1 ? null : "올바른 수량을 입력해주세요.";
                  },
                ),
              ),
            ],
          ),
        ),
        OkCancelGroup(
          okClicked: () async {
            if (!_formKey.currentState!.validate()) {
              return;
            }
            print("[GIFT] ${studentId.text}");
            final H4PayResult result = await checkUserValid(studentId.text);
            if (result.success) {
              _sendGift(
                  result.data, product, studentId.text, int.parse(qty.text));
            } else {
              Navigator.pop(context);
              showSnackbar(
                context,
                result.data,
                Colors.red,
                Duration(seconds: 1),
              );
            }
          },
          cancelClicked: () {
            Navigator.pop(context);
          },
        )
      ],
      null,
      true,
    );
    setState(() {
      currentTile = null;
    });
  }

  void _sendGift(String userName, Product product, String stId, int qty) async {
    final _orderId = "2" + genOrderId() + "000";
    final Map tempPurchase = {
      'type': 'Gift',
      'uidto': stId,
      'amount': product.price * qty,
      'item': {product.id.toString(): qty},
      'orderId': _orderId
    };
    prefs.setString('tempPurchase', json.encode(tempPurchase));
    Navigator.pop(context);
    final H4PayUser? user = await userFromStorage();
    if (user != null) {
      showAlertDialog(context, "발송 확인", "$userName 님에게 선물을 발송할까요?", () {
        Navigator.pop(context);
/*         showDropdownAlertDialog(context, "현금영수증 옵션", userName,
            product.price * qty, _orderId, product.productName, user.name!); */
        showSnackbar(
          context,
          "$userName 님에게 선물을 전송할게요.",
          Colors.green,
          Duration(seconds: 1),
        );
        showBottomSheet(
          context: context,
          builder: (context) => WebViewExample(
            type: Gift,
            amount: product.price * qty,
            orderId: _orderId,
            orderName: product.productName,
            customerName: user.name!,
            cashReceiptType: "미발급",
          ),
        );
      }, () {
        Navigator.pop(context);
      });
    } else {
      showSnackbar(
        context,
        "사용자 정보를 불러오지 못했습니다.",
        Colors.red,
        Duration(seconds: 1),
      );
    }
  }
}
