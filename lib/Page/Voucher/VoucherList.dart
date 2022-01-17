import 'package:collection/src/iterable_extensions.dart';
import 'package:flutter/material.dart';
import 'package:h4pay/Network/H4PayService.dart';
import 'package:h4pay/Page/Purchase/PurchaseList.dart';
import 'package:h4pay/model/Product.dart';
import 'package:h4pay/model/User.dart';
import 'package:h4pay/model/Voucher.dart';
import 'package:h4pay/components/Card.dart';

class VoucherList extends StatefulWidget {
  @override
  VoucherListState createState() => VoucherListState();
}

class VoucherListState extends State<VoucherList> {
  int componentKey = 0;
  final H4PayService service = getService();

  Future<Map> _loadThings() async {
    final H4PayUser? user = await userFromStorage();
    final String tel = user!.tel!;
    final List<Voucher> vouchers = await service.getVouchers(tel);
    final List<Product> products = await service.getProducts();
    return {
      "vouchers": vouchers,
      "products": products,
    };
  }

  @override
  Widget build(BuildContext context) {
    return ListPage(
      appBarTitle: "상품권 보관함",
      withAppBar: true,
      type: Voucher,
      dataFuture: _loadThings(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          final Map data = snapshot.data as Map;
          final List<Voucher> vouchers = data['vouchers'];
          final List<Product> products = data['products'];
          if (vouchers == null || vouchers.length == 0) {
            return Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.8,
              child: Center(
                child: Text(
                  "상품권이 없는 것 같아요.",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            );
          } else {
            return ListView.builder(
              reverse: true,
              itemCount: vouchers.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return VoucherCard(
                  voucher: vouchers[index],
                  product: vouchers[index].item != null
                      ? products.singleWhereOrNull(
                          (element) =>
                              element.id ==
                              int.parse(
                                vouchers[index].item!.entries.elementAt(0).key,
                              ),
                        )!
                      : null,
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
