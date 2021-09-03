import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:h4pay_flutter/Product.dart';
import 'package:h4pay_flutter/components/Card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:h4pay_flutter/main.dart';

class Home extends StatefulWidget {
  final SharedPreferences prefs;
  Home(this.prefs);

  @override
  _HomeState createState() => _HomeState(prefs);
}

class _HomeState extends State<Home> {
  final SharedPreferences prefs;

  _HomeState(this.prefs);
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
          FutureBuilder(
            future: fetchProduct(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final products = snapshot.data as List<Product>;
                return GridView.count(
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
                      return CardWidget(
                        margin: margin,
                        onClick: () {
                          addProductToCart(index);
                        },
                        child: Column(
                          children: [
                            CachedNetworkImage(
                              imageUrl: products[index].img,
                              progressIndicatorBuilder:
                                  (context, url, downloadProgress) =>
                                      CircularProgressIndicator(
                                          value: downloadProgress.progress),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                              width: MediaQuery.of(context).size.width * 0.3,
                              height: MediaQuery.of(context).size.width * 0.3,
                            ),
                            Container(
                              child: Column(
                                children: [
                                  Container(
                                    child: Text(
                                      products[index].productName,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15),
                                    ),
                                    alignment: Alignment(-1, 0),
                                  ),
                                  Container(
                                    child: Text(
                                      "${products[index].price} 원",
                                      textAlign: TextAlign.left,
                                    ),
                                    alignment: Alignment(-1, 0),
                                  ),
                                ],
                              ),
                              alignment: Alignment(-1, 0),
                              padding: EdgeInsets.only(left: 20),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                );
              } else {
                return CircularProgressIndicator();
              }
            },
          ),
        ],
      ),
    );
  }

  addProductToCart(int id) {
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
    final MyHomePageState parentState =
        context.findAncestorStateOfType() as MyHomePageState;
    parentState.setState(() {
      parentState.cartBadgeCount = countAllItemsInCart(cartMap);
    });
  }
}

int countAllItemsInCart(Map cartMap) {
  int itemCount = 0;
  cartMap.forEach(
    (key, value) {
      itemCount += value as int;
    },
  );
  return itemCount;
}
