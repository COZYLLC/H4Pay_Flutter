import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:h4pay_flutter/Product.dart';
import 'package:h4pay_flutter/components/Card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Cart extends StatefulWidget {
  final SharedPreferences prefs;

  @override
  Cart(this.prefs);

  _CartState createState() => _CartState(prefs);
}

class _CartState extends State<Cart> {
  final SharedPreferences prefs;
  _CartState(this.prefs);
  int dummy = 0;

  Map cartMap = {};

  @override
  void initState() {
    super.initState();
    final cartString = prefs.getString('cart');
    if (cartString != null) {
      cartMap = json.decode(cartString);
      print(cartMap);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: fetchProduct(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final List<Product> products = snapshot.data as List<Product>;
              return Column(
                children: [
                  ListView.builder(
                    itemCount: cartMap.length,
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final idx =
                          int.parse(cartMap.keys.elementAt(index) as String);
                      /*return  Column(children: [
                        Text("$cartMap['$idx']"),
                        IconButton(
                            onPressed: () {
                              setState(() {
                                cartMap["$idx"]++;
                              });
                            },
                            icon: Icon(Icons.add))
                      ]); */
                      return CardWidget(
                        margin: EdgeInsets.all(18),
                        onClick: () {},
                        child: Row(
                          children: [
                            Container(
                              // 제품 사진
                              padding: EdgeInsets.all(20),
                              child: CachedNetworkImage(
                                imageUrl: products[idx].img,
                                progressIndicatorBuilder:
                                    (context, url, downloadProgress) =>
                                        CircularProgressIndicator(
                                            value: downloadProgress.progress),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                                width: MediaQuery.of(context).size.width * 0.25,
                                height:
                                    MediaQuery.of(context).size.width * 0.25,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.4,
                                  height: 30,
                                  child: Text(
                                    products[idx].productName,
                                    //dummy.toString(),
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.fade,
                                  ),
                                ),
                                Text(
                                  (products[idx].price * cartMap["$idx"])
                                      .toString(),
                                  style: TextStyle(fontSize: 20),
                                ),
                                Row(
                                  children: [
                                    cartMap["$idx"] != 1
                                        ? IconButton(
                                            onPressed: () {
                                              setState(() {
                                                cartMap["$idx"] -= 1;
                                              });
                                              updateCart();
                                            },
                                            icon: Icon(Icons.remove),
                                          )
                                        : Container(),
                                    Text(
                                      cartMap["$idx"].toString(),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          cartMap["$idx"] += 1;
                                        });
                                        updateCart();
                                      },
                                      icon: Icon(Icons.add),
                                    )
                                  ],
                                )
                              ],
                            ),
                            Spacer(),
                            TextButton(
                              onPressed: () {},
                              child: Text("삭제"),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              );
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }

  void updateCart() {
    prefs.setString('cart', json.encode(cartMap));
  }
}
