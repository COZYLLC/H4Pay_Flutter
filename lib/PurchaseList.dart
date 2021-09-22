import 'package:flutter/material.dart';
import 'package:h4pay_flutter/Gift.dart';
import 'package:h4pay_flutter/Order.dart';
import 'package:h4pay_flutter/Product.dart';
import 'package:h4pay_flutter/Purchase.dart';
import 'package:h4pay_flutter/components/Card.dart';
import 'package:h4pay_flutter/User.dart';

class PurchaseList extends StatefulWidget {
  final Type type;
  final bool appBar;
  PurchaseList({required this.type, required this.appBar});
  @override
  PurchaseListState createState() => PurchaseListState();
}

class PurchaseListState extends State<PurchaseList> {
  int componentKey = 0;

  Future<Map> _loadThings() async {
    final H4PayUser? user = await userFromStorage();
    final List<Purchase>? purchases = widget.type == Order
        ? await fetchOrder(user!.uid)
        : widget.type == Gift
            ? await fetchGift(user!.uid)
            : await fetchSentGift(user!.uid);
    final List<Product>? products = await fetchProduct('orderList');
    return {
      'purchases': purchases,
      'products': products,
    };
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.appBar == true
          ? AppBar(
              title: Text(
                widget.type == Order
                    ? "주문 내역"
                    : widget.type == Gift
                        ? "받은 선물함"
                        : "선물 발송 내역",
              ),
            )
          : null,
      body: FutureBuilder(
        future: _loadThings(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            final Map data = snapshot.data as Map;
            final List<Purchase>? purchases = data['purchases'];
            final List<Product> products = data['products'];
            if (purchases == null || purchases.length == 0) {
              return Center(
                child: Text(
                  "주문 내역이 없는 것 같아요.",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
              );
            } else {
              return ListView.builder(
                itemCount: purchases.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return PurchaseCard(
                    purchase: purchases[index],
                    product: products[int.parse(
                      purchases[index].item.entries.elementAt(0).key,
                    )],
                  );
                },
              );
            }
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
