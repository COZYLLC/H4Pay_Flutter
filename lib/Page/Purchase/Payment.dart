import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:h4pay/Network/H4PayService.dart';
import 'package:h4pay/Page/Error.dart';
import 'package:h4pay/Page/Purchase/PurchaseDetail.dart';
import 'package:h4pay/Util/Wakelock.dart';
import 'package:h4pay/exception.dart';
import 'package:h4pay/model/Purchase/Gift.dart';
import 'package:h4pay/model/Purchase/Purchase.dart';
import 'package:h4pay/model/Purchase/TempPurchase.dart';
import 'package:h4pay/model/User.dart';
import 'package:h4pay/components/Button.dart';
import 'package:h4pay/Util/Beautifier.dart';
import 'package:h4pay/main.dart';
import 'package:kakao_flutter_sdk/all.dart' as kakao;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animated_check/animated_check.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentSuccessPage extends StatefulWidget {
  final TempPurchase tempPurchase;
  final Map params;

  const PaymentSuccessPage(
      {Key? key, required this.tempPurchase, required this.params})
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
    _processFuture = _processPayment(widget.tempPurchase);
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
              body: Container(
                margin: EdgeInsets.all(40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AnimatedCheck(progress: _animation!, size: 200),
                    Column(
                      children: [
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
                        Divider(color: Colors.black),
                        Container(
                          child: Visibility(
                            child: Text(
                              "카카오톡 선물하기가 제대로 되지 않은 경우에는 마이페이지 -> 선물 발송 내역 -> 재발송 과정을 통해 1회 재발송 가능합니다.",
                            ),
                            visible: purchase is Gift,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 20),
                      child: Row(
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
                              backgroundColor: Colors.grey[200],
                              textColor: Color(0xff000000),
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
                                ).then(disableWakeLock);
                              },
                              backgroundColor: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return ErrorPage(snapshot.error as Exception);
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

  Future<Purchase> _processPayment(TempPurchase tempPurchase) async {
    _prefs = await SharedPreferences.getInstance();
    final H4PayUser? user = await userFromStorageAndVerify();
    if (user != null) {
      final Map paymentData = widget.params;
      if (true) {
        tempPurchase.paymentKey = paymentData['paymentKey'];
        if (tempPurchase is TempOrder) {
          // Order
          tempPurchase.uid = user.uid;
          final createResult = await service.createOrder(tempPurchase.toJson());

          if (createResult.response.statusCode == 200) {
            _prefs!.setString('cart', json.encode({}));
            return tempPurchase;
          } else {
            throw NetworkException(createResult.response.statusCode!);
          }
        } else {
          // Gift
          final TempGift gift = tempPurchase as TempGift;
          try {
            await service.createKakaoGift(gift.toJson());
            kakao.KakaoContext.clientId = dotenv.env["KAKAO_API_KEY"]!;
            final int templateId = 71671;
            final Map<String, String> templateArgs = {
              "productName": tempPurchase.orderName,
              "issuerName": user.name!,
              "message": tempPurchase.reason,
              "orderId": gift.orderId,
            };
            Uri uri = await kakao.LinkClient.instance.customWithTalk(
              templateId,
              templateArgs: templateArgs,
            );
            try {
              await launch(uri.toString());
            } catch (e) {
              Uri uri = await kakao.LinkClient.instance.customWithWeb(
                templateId,
                templateArgs: templateArgs,
              );
              await launch(uri.toString());
            }
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
