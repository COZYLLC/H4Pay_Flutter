import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:h4pay/Network/H4PayService.dart';
import 'package:h4pay/Page/Error.dart';
import 'package:h4pay/Page/Purchase/Payment.dart';
import 'package:h4pay/exception.dart';
import 'package:h4pay/model/Product.dart';
import 'package:h4pay/model/Purchase/Purchase.dart';
import 'package:h4pay/model/User.dart';
import 'package:h4pay/Util/Beautifier.dart';
import 'package:h4pay/components/Card.dart';
import 'package:h4pay/main.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:wakelock/wakelock.dart';
import 'package:collection/collection.dart';

class PurchaseDetailPage extends StatefulWidget {
  final Purchase purchase;

  const PurchaseDetailPage({Key? key, required this.purchase})
      : super(key: key);
  @override
  PurchaseDetailPageState createState() => PurchaseDetailPageState();
}

class PurchaseDetailPageState extends State<PurchaseDetailPage> {
  Future<Map>? _fetchProduct;
  double? brightness;
  final H4PayService service = getService();

  @override
  void initState() {
    super.initState();
    _fetchProduct = _loadThings();
    _setUpBrightness();
  }

  _setUpBrightness() async {
    await ScreenBrightness.setScreenBrightness(1.0);
    await Wakelock.toggle(enable: true);
  }

  Future<Map> _loadThings() async {
    Map result = {};
    result['product'] = await service.getProducts();
    result['user'] = await userFromStorage();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final Map item = widget.purchase.item;
    return Scaffold(
      appBar: H4PayAppbar(
        title: "주문 상세 내역",
        height: 56.0,
        backPressed: () {
          Navigator.pop(context, brightness);
        },
        canGoBack: true,
      ),
      body: FutureBuilder(
        future: _fetchProduct,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final Map data = snapshot.data as Map;
            final List<Product> products = data['product'];
            return Container(
              margin: EdgeInsets.all(40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BarcodeWidget(
                    barcode: Barcode.code128(),
                    data: widget.purchase.orderId,
                  ),
                  Spacer(),
                  ReceiptText(title: "주문 번호", content: widget.purchase.orderId),
                  ReceiptText(
                    title: "상품명",
                    content: getOrderName(
                      widget.purchase.item,
                      products
                          .singleWhereOrNull(
                            (element) =>
                                element.id ==
                                int.parse(widget.purchase.item.entries
                                    .elementAt(0)
                                    .key),
                          )!
                          .productName,
                    ),
                  ),
                  ReceiptText(
                    title: "주문 일시",
                    content: getPrettyDateStr(widget.purchase.date, true),
                  ),
                  ReceiptText(
                    title: "만료 일시",
                    content: getPrettyDateStr(widget.purchase.expire, true),
                  ),
                  ReceiptText(
                    title: "결제 금액",
                    content: getPrettyAmountStr(widget.purchase.amount),
                  ),
                  Container(
                    child: widget.purchase.uid == null
                        ? Column(
                            children: [
                              ReceiptText(
                                title: "수신자 ID",
                                content: widget.purchase.uidto!,
                              )
                            ],
                          )
                        : Container(),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 20, bottom: 5),
                    child: const Text(
                      "주문 품목",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Container(
                    height: 100,
                    child: ListView.builder(
                      itemCount: widget.purchase.item.length,
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (BuildContext context, int index) {
                        final int idx = int.parse(item.keys.elementAt(index));
                        final product = products
                            .firstWhereOrNull((product) => product.id == idx);
                        return CardWidget(
                          margin: EdgeInsets.only(right: 5),
                          child: Row(
                            children: [
                              CachedNetworkImage(
                                imageUrl: product!.img,
                                height: 40,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(product.productName),
                                  Text("${item[idx.toString()]} 개")
                                ],
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return ErrorPage(
              title: "서버 오류가 발생했습니다.",
              description: "${(snapshot.error as NetworkException).statusCode}",
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
