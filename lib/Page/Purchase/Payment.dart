import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:h4pay/Network/H4PayService.dart';
import 'package:h4pay/Page/Error.dart';
import 'package:h4pay/Page/Purchase/PurchaseDetail.dart';
import 'package:h4pay/exception.dart';
import 'package:h4pay/model/Purchase/Gift.dart';
import 'package:h4pay/model/Purchase/Order.dart';
import 'package:h4pay/model/Purchase/Purchase.dart';
import 'package:h4pay/model/User.dart';
import 'package:h4pay/components/Button.dart';
import 'package:h4pay/Util/Beautifier.dart';
import 'package:h4pay/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animated_check/animated_check.dart';

class PaymentSuccessPage extends StatefulWidget {
  final Type type;
  final Map params;

  const PaymentSuccessPage({Key? key, required this.type, required this.params})
      : super(key: key);
  @override
  PaymentSuccessPageState createState() => PaymentSuccessPageState();
}

class PaymentSuccessPageState extends State<PaymentSuccessPage>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _animation;
  SharedPreferences? _prefs;
  Future<Purchase>? _processFuture;
  final H4PayService service = getService();

  @override
  void initState() {
    super.initState();
    _processFuture = _processPayment();
    _initAnimation();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: FutureBuilder(
        future: _processFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _animationController!.forward();
            final Purchase purchase = snapshot.data as Purchase;
            return Scaffold(
              appBar: H4PayAppbar(
                title: "결제 완료",
                height: 56.0,
                canGoBack: false,
              ),
              body: Align(
                alignment: Alignment.center,
                child: Container(
                  margin: EdgeInsets.all(40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AnimatedCheck(progress: _animation!, size: 200),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.15,
                      ),
                      ReceiptText(title: "주문 번호", content: purchase.orderId),
                      Divider(color: Colors.black),
                      ReceiptText(
                        title: "주문 일시",
                        content: getPrettyDateStr(purchase.date, true),
                      ),
                      ReceiptText(
                        title: "만료 일시",
                        content: getPrettyDateStr(purchase.expire, true),
                      ),
                      ReceiptText(title: "결제 방법", content: "토스"),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.1,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: H4PayButton(
                              text: "홈으로 돌아가기",
                              width: MediaQuery.of(context).size.width * 0.4,
                              onClick: () {
                                Navigator.pop(context);
                              },
                              backgroundColor: Theme.of(context).primaryColor,
                            ),
                          ),
                          Container(width: 10),
                          Expanded(
                            child: H4PayButton(
                              text: "상세 정보 확인",
                              width: MediaQuery.of(context).size.width * 0.4,
                              onClick: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PurchaseDetailPage(
                                      purchase: purchase,
                                    ),
                                  ),
                                );
                              },
                              backgroundColor: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Scaffold(body: ErrorPage(snapshot.error as Exception));
          } else {
            return Center(
              child: Scaffold(body: CircularProgressIndicator()),
            );
          }
        },
      ),
    );
  }

  void _initAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
    _animation = new Tween<double>(begin: 0, end: 1).animate(
      new CurvedAnimation(
        parent: _animationController!,
        curve: Curves.easeInOutCirc,
      ),
    );
  }

  Future<Purchase> _processPayment() async {
    _prefs = await SharedPreferences.getInstance();
    final H4PayUser? user = await userFromStorageAndVerify();
    if (user != null) {
      final Map<String, dynamic> tempPurchase =
          json.decode(_prefs!.getString('tempPurchase')!);
      final Map paymentData = widget.params;
      if (true) {
        final date = DateTime.now();
        final expire = date.add(
          Duration(days: 7),
        );
        tempPurchase['date'] = date.toIso8601String();
        tempPurchase['expire'] = expire.toIso8601String();
        tempPurchase['exchanged'] = false;
        tempPurchase['paymentKey'] = paymentData['paymentKey'];

        if (tempPurchase['type'] == 'Order') {
          tempPurchase['uid'] = user.uid;
          final order = Order.fromJson(tempPurchase);
          final createResult = await service.createOrder(order.toJson());
          if (createResult.response.statusCode == 200) {
            _prefs!.setString('cart', json.encode({}));
            return order;
          } else {
            throw NetworkException(createResult.response.statusCode!);
          }
        } else {
          tempPurchase['extended'] = false;
          final gift = Gift.fromJson(tempPurchase);
          try {
            final giftJson = gift.toJson();
            giftJson['target'] = tempPurchase['target'];
            giftJson['issuerName'] = user.name;
            giftJson['reason'] = "TEST";
            await service.createGift(giftJson);
            _prefs!.setString('cart', json.encode({}));
            return gift;
          } catch (e) {
            throw e;
          }
        }
      }
    } else {
      throw UserNotFoundException();
    }
  }
}

class ReceiptText extends StatelessWidget {
  final String title;
  final String content;
  ReceiptText({required this.title, required this.content});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text("$title\t\t\t"), Text(content)],
    );
  }
}
