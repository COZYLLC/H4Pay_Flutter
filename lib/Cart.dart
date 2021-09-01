import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:h4pay_flutter/components/Card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartPage extends StatefulWidget {
  final SharedPreferences prefs;

  @override
  CartPage(this.prefs);

  _CartPageState createState() => _CartPageState(prefs);
}

class _CartPageState extends State<CartPage> {
  final SharedPreferences prefs;
  _CartPageState(this.prefs);

  Map cartMap = {};

  @override
  void initState() {
    super.initState();
    final cartString = prefs.getString('cart');
    if (cartString != null) {
      cartMap = json.decode(cartString);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            GridView.count(
              crossAxisCount: 1,
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: List.generate(cartMap.length, (index) {
                final idx = cartMap.keys.elementAt(index) as int;
                return CardWidget(
                  margin: EdgeInsets.all(18),
                  onClick: () {},
                  child: Row(
                    children: [Text("$idx 번 상품 ${cartMap[idx]}개")],
                  ),
                );
              }),
            )
          ],
        ),
      ),
    );
  }
}
