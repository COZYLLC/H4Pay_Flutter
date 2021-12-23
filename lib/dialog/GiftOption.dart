import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:h4pay/Product.dart';
import 'package:h4pay/Purchase/Gift.dart';
import 'package:h4pay/Purchase/Order.dart';
import 'package:h4pay/Result.dart';
import 'package:h4pay/User.dart';
import 'package:h4pay/Util.dart';
import 'package:h4pay/Util/Beautifier.dart';
import 'package:h4pay/components/Input.dart';
import 'package:h4pay/components/WebView.dart';
import 'package:h4pay/dialog/H4PayDialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GiftOptionDialog extends H4PayDialog {
  final BuildContext context;
  final GlobalKey<FormState> formKey;
  final TextEditingController studentId;
  final TextEditingController qty;
  final SharedPreferences prefs;
  final Product product;

  GiftOptionDialog(
      {required this.context,
      required this.formKey,
      required this.studentId,
      required this.qty,
      required this.prefs,
      required this.product})
      : super(
          title: "선물 옵션",
          content: Container(),
        );

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(23.0),
        ),
      ),
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Form(
            key: formKey,
            child: Row(
              children: [
                Expanded(
                  flex: 8,
                  child: H4PayInput(
                    isNumber: true,
                    title: "학번",
                    controller: studentId,
                    validator: (value) {
                      return value!.length == 4 ? null : "올바른 학번을 입력해주세요.";
                    },
                  ),
                ),
                Spacer(flex: 1),
                Expanded(
                  flex: 8,
                  child: H4PayInput.done(
                    isNumber: true,
                    controller: qty,
                    title: "수량",
                    validator: (value) {
                      return value!.length == 1 ? null : "올바른 수량을 입력해주세요.";
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        OkCancelGroup(
          okClicked: () async {
            if (!formKey.currentState!.validate()) {
              return;
            }
            final H4PayResult result = await checkUserValid(studentId.text);
            if (result.success) {
              _sendGift(
                  result.data, product, studentId.text, int.parse(qty.text));
            } else {
              Navigator.pop(context);
              showSnackbar(
                context,
                result.data,
                Colors.red,
                Duration(seconds: 1),
              );
            }
          },
          cancelClicked: () {
            Navigator.pop(context);
          },
        )
      ],
    );
  }

  void _sendGift(String userName, Product product, String stId, int qty) async {
    final _orderId = "2" + genOrderId() + "000";
    final Map tempPurchase = {
      'type': 'Gift',
      'uidto': stId,
      'amount': product.price * qty,
      'item': {product.id.toString(): qty},
      'orderId': _orderId
    };
    prefs.setString('tempPurchase', json.encode(tempPurchase));
    Navigator.pop(context);
    final H4PayUser? user = await userFromStorage();
    if (user != null) {
      showAlertDialog(context, "발송 확인", "$userName 님에게 선물을 발송할까요?", () {
        Navigator.pop(context);
/*         showDropdownAlertDialog(context, "현금영수증 옵션", userName,
            product.price * qty, _orderId, product.productName, user.name!); */
        showSnackbar(
          context,
          "$userName 님에게 선물을 전송할게요.",
          Colors.green,
          Duration(seconds: 1),
        );
        showBottomSheet(
          context: context,
          builder: (context) => WebViewExample(
            type: Gift,
            amount: product.price * qty,
            orderId: _orderId,
            orderName: "(선물) ${getOrderName(
              {product.id.toString(): qty},
              product.productName,
            )}",
            customerName: user.name!,
            cashReceiptType: "미발급",
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
