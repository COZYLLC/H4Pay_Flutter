import 'package:flutter/material.dart';
import 'package:h4pay/Network/H4PayService.dart';
import 'package:h4pay/Util/Generator.dart';
import 'package:h4pay/Util/validator.dart';
import 'package:h4pay/model/Product.dart';
import 'package:h4pay/model/Purchase/TempPurchase.dart';
import 'package:h4pay/model/User.dart';
import 'package:h4pay/Util/Dialog.dart';
import 'package:h4pay/Util/Beautifier.dart';
import 'package:h4pay/components/Input.dart';
import 'package:h4pay/components/WebView.dart';
import 'package:h4pay/dialog/H4PayDialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GiftOptionDialog extends H4PayDialog {
  final H4PayService service = getService();
  final BuildContext context;
  final GlobalKey<FormState> formKey;
  final TextEditingController name;
  final TextEditingController qty;
  final TextEditingController reason = TextEditingController();
  final PageController _pageController = PageController();
  final SharedPreferences prefs;
  final Product product;

  GiftOptionDialog(
      {required this.context,
      required this.formKey,
      required this.name,
      required this.qty,
      required this.prefs,
      required this.product})
      : super(
          title: "선물 옵션",
          content: Container(),
        );

  @override
  Widget build(BuildContext context) {
    final Column nameAndQtyInput = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Form(
          key: formKey,
          child: Row(
            children: [
              Expanded(
                flex: 8,
                child: H4PayInput(
                  maxLength: 13,
                  title: "받는사람 이름",
                  controller: name,
                  validator: nameValidator,
                ),
              ),
              Spacer(flex: 1),
              Expanded(
                flex: 8,
                child: H4PayInput.done(
                  maxLength: 3,
                  isNumber: true,
                  controller: qty,
                  title: "수량",
                  validator: (value) {
                    return value!.length <= 3 ? null : "올바른 수량을 입력해주세요.";
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(23.0)),
      ),
      titlePadding: EdgeInsets.all(10),
      titleTextStyle: TextStyle(
        fontSize: 28,
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
      contentPadding: EdgeInsets.all(10),
      title: Text(title),
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.15,
        child: PageView(
          controller: _pageController,
          children: [
            nameAndQtyInput,
            H4PayInput(title: "한줄 메시지를 작성해주세요", controller: reason)
          ],
        ),
      ),
      actions: [
        OkCancelGroup(
          okClicked: () async {
            if (_pageController.page == 0) {
              if (!formKey.currentState!.validate())
                return;
              else
                _pageController.nextPage(
                  duration: Duration(milliseconds: 250),
                  curve: Curves.easeIn,
                );
            } else if (_pageController.page == 1) {
              if (reason.text.length > 25) {
                showSnackbar(
                  context,
                  "죄송합니다, 한줄 메시지는 25자 이상 입력 불가합니다.",
                  Colors.red,
                  Duration(seconds: 3),
                );
                return;
              } else {
                _sendGift(
                  name.text,
                  product,
                  int.parse(qty.text),
                );
              }
            }
          },
          cancelClicked: () {
            Navigator.pop(context);
          },
        )
      ],
    );
  }

  void _sendGift(String receiverName, Product product, int qty) async {
    final _orderId = "2" + genOrderId() + "000";
    final H4PayUser? user = await userFromStorageAndVerify();
    final String productName = getOrderName(
      {product.id.toString(): qty},
      product.productName,
    );

    if (user != null) {
      final date = DateTime.now();
      final expire = date.add(
        Duration(days: 7),
      );
      final TempPurchase tempPurchase = TempGift(
        receiverName: receiverName,
        customerName: user.name!,
        uidfrom: user.uid!,
        amount: product.price * qty,
        item: {product.id.toString(): qty},
        orderId: _orderId,
        uidto: '',
        orderName: productName,
        reason: reason.text,
        cashReceiptType: '미발행',
      );
      Navigator.pop(context);

      showAlertDialog(context, "발송 확인", "$receiverName 님에게 선물을 발송할까요?", () {
        Navigator.pop(context);
/*         showDropdownAlertDialog(context, "현금영수증 옵션", userName,
            product.price * qty, _orderId, product.productName, user.name!); */
        showSnackbar(
          context,
          "$receiverName 님에게 선물을 전송할게요.",
          Colors.green,
          Duration(seconds: 1),
        );
        showBottomSheet(
          context: context,
          builder: (context) => SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: WebViewExample(tempPurchase: tempPurchase),
          ),
        );
      }, () {
        Navigator.pop(context);
      });
    } else {
      showSnackbar(
        context,
        "사용자 정보를 불러오지 못했습니다.",
        Colors.red,
        Duration(seconds: 1),
      );
    }
  }
}
