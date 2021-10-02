import 'package:flutter/material.dart';
import 'package:h4pay/Gift.dart';
import 'package:h4pay/Order.dart';
import 'package:h4pay/Product.dart';
import 'package:h4pay/Purchase.dart';
import 'package:h4pay/components/Card.dart';
import 'package:h4pay/User.dart';
import 'package:collection/collection.dart';

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
      'user': user,
    };
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.type == Order
        ? "주문 내역"
        : widget.type == Gift
            ? "받은 선물"
            : "선물 발송 내역";
    return ListPage(
      withAppBar: true,
      appBarTitle: title,
      type: widget.type,
      dataFuture: _loadThings(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          final Map data = snapshot.data as Map;
          final List<Purchase>? purchases = data['purchases'];
          final List<Product> products = data['products'];
          final H4PayUser? user = data['user'];
          if (purchases == null || purchases.length == 0) {
            return Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.8,
              child: Center(
                child: Text(
                  "$title이 없는 것 같아요.",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            );
          } else {
            return ListView.builder(
              itemCount: purchases.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                for (var i = 0; i < purchases.length; i++) {
                  print(purchases[i].orderId);
                }
                return PurchaseCard(
                  purchase: purchases[index],
                  product: products.singleWhereOrNull(
                    (element) =>
                        element.id ==
                        int.parse(
                          purchases[index].item.entries.elementAt(0).key,
                        ),
                  )!,
                  uid: user!.uid!,
                );
              },
            );
          }
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}

class ListPage extends StatefulWidget {
  final bool withAppBar;
  final String? appBarTitle;
  final Type type;
  final Future dataFuture;
  final builder;

  const ListPage(
      {Key? key,
      required this.withAppBar,
      this.appBarTitle,
      required this.type,
      required this.dataFuture,
      required this.builder})
      : super(key: key);

  @override
  ListPageState createState() => ListPageState();
}

class ListPageState extends State<ListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.withAppBar == true && widget.appBarTitle != null
          ? AppBar(
              title: Text(widget.appBarTitle!),
            )
          : null,
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: widget.dataFuture,
          builder: widget.builder,
        ),
      ),
    );
  }
}
