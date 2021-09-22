import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:h4pay_flutter/Gift.dart';
import 'package:h4pay_flutter/Order.dart';
import 'package:h4pay_flutter/Purchase.dart';
import 'package:h4pay_flutter/PurchaseDetail.dart';
import 'package:h4pay_flutter/User.dart';
import 'package:h4pay_flutter/components/Button.dart';
import 'package:h4pay_flutter/main.dart';
import 'package:h4pay_flutter/Util.dart';
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
  Future<Purchase?>? _processFuture;

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
          _animationController!.forward();
          if (snapshot.hasData) {
            final Purchase? purchase = snapshot.data as Purchase;

            return Scaffold(
              appBar: AppBar(
                title: Text("결제 완료"),
                automaticallyImplyLeading: false,
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
                      ReceiptText(title: "주문 번호", content: purchase!.orderId),
                      Divider(
                        color: Colors.black,
                      ),
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
                          H4PayButton(
                            text: "홈으로 돌아가기",
                            width: MediaQuery.of(context).size.width * 0.4,
                            onClick: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MyHomePage(
                                    title: "H4Pay",
                                    prefs: _prefs!,
                                  ),
                                ),
                              );
                            },
                            backgroundColor: Colors.blue,
                          ),
                          H4PayButton(
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
                            backgroundColor: Colors.blue,
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
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

  Future<Purchase?> _processPayment() async {
    _prefs = await SharedPreferences.getInstance();
    final H4PayUser? user = await userFromStorage();
    if (user != null) {
      final Map<String, dynamic> tempPurchase =
          json.decode(_prefs!.getString('tempPurchase')!);
      final Map paymentData = widget.params;
      print(tempPurchase['orderId']);
      print(paymentData['orderId']);
//     if (tempPurchase['orderId'] == paymentData['orderId']) {
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
          print("order");
          tempPurchase['uid'] = user.uid;
          final order = Order.fromJson(tempPurchase);
          order.create();
          print("[PAYMENT] $tempPurchase");

          return order;
        } else {
          print("gift");
          tempPurchase['uidfrom'] = user.uid;
          final gift = Gift.fromJson(tempPurchase);
          gift.create();
          print("[PAYMENT] $tempPurchase");
          return gift;
        }
      }
    } else {
      showSnackbar(
        context,
        "로그인 되어 있지 않은 것 같습니다!",
        Colors.red,
        Duration(seconds: 1),
      );
      return null;
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
