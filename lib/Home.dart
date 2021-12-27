import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:h4pay/Cart.dart';
import 'package:h4pay/Event.dart';
import 'package:h4pay/Notice.dart';
import 'package:h4pay/Product.dart';
import 'package:h4pay/Util.dart';
import 'package:h4pay/components/Card.dart';
import 'package:h4pay/dialog/Event.dart';
import 'package:h4pay/dialog/GiftOption.dart';
import 'package:h4pay/dialog/Notice.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:h4pay/main.dart';

class Home extends StatefulWidget {
  final SharedPreferences prefs;
  Home(this.prefs);

  @override
  HomeState createState() => HomeState(prefs);
}

class HomeState extends State<Home> {
  final SharedPreferences prefs;
  final GlobalKey _carouselKey = GlobalKey();
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
    List<Product>? products = await fetchProductOnlyVisible('homePage');
    products!.sort((a, b) => a.productName.compareTo(b.productName));
    data['product'] = products;
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
                        height: MediaQuery.of(context).size.width * 0.35,
                      ),
                      items: adList.map((i) {
                        return LayoutBuilder(
                          builder: (BuildContext context, constraint) {
                            return InkWell(
                              onTap: () {
                                i.runtimeType == Notice
                                    ? showCustomAlertDialog(
                                        context,
                                        NoticeDialog(
                                          context: context,
                                          notice: i,
                                        ),
                                        true,
                                      )
                                    : showCustomAlertDialog(
                                        context,
                                        EventDialog(
                                          context: context,
                                          event: i as Event,
                                        ),
                                        true,
                                      );
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                margin: EdgeInsets.fromLTRB(5, 12, 5, 0),
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      i.img,
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                  color: Theme.of(context).primaryColor,
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
                            isClicked: currentTile == products[index].id,
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
                        imageUrl: products
                            .firstWhere((product) => product.id == currentTile!)
                            .img,
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
    parentState!.setState(() {
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
      GiftOptionDialog(
        context: context,
        formKey: _formKey,
        studentId: studentId,
        qty: qty,
        prefs: prefs,
        product: product,
      ),
      true,
    );
  }
}
