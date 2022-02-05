import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:h4pay/Network/H4PayService.dart';
import 'package:h4pay/Util/Generator.dart';
import 'package:h4pay/exception.dart';
import 'package:h4pay/model/Product.dart';
import 'package:h4pay/model/Purchase/Gift.dart';
import 'package:h4pay/model/User.dart';
import 'package:h4pay/Util/Dialog.dart';
import 'package:h4pay/Util/Beautifier.dart';
import 'package:h4pay/components/Input.dart';
import 'package:h4pay/components/WebView.dart';
import 'package:h4pay/dialog/H4PayDialog.dart';
import 'package:h4pay/model/UserValidResponse.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GiftOptionDialog extends H4PayDialog {
  final H4PayService service = getService();
  final BuildContext context;
  final GlobalKey<FormState> formKey;
  final TextEditingController studentId;
  final TextEditingController qty;
  final SharedPreferences prefs;
  final Product product;

  Future<List<Map<String, dynamic>>?> _nameFromStudentId(
      String studentId) async {
    final UserValidResponse response = await service.nameFromStudentId({
      'users': json.encode([
        {"studentid": studentId}
      ])
    });
    if (response.isValid) return response.users;
  }

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
                    maxLength: 4,
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
      ),
      actions: [
        OkCancelGroup(
          okClicked: () async {
            if (!formKey.currentState!.validate()) {
              return;
            }
            final List<Map<String, dynamic>>? result =
                await _nameFromStudentId(studentId.text);
            if (result != null)
              _sendGift(
                result[0],
                product,
                int.parse(qty.text),
              );
            else
              showSnackbar(
                context,
                "하나 이상의 학번이 존재하지 않습니다.",
                Colors.red,
                Duration(seconds: 1),
              );
          },
          cancelClicked: () {
            Navigator.pop(context);
          },
        )
      ],
    );
  }

  void _sendGift(Map<String, dynamic> target, Product product, int qty) async {
    final _orderId = "2" + genOrderId() + "000";
    final H4PayUser? user = await userFromStorageAndVerify();

    if (user != null) {
      final Map tempPurchase = {
        'type': 'Gift',
        'target': target,
        'uidfrom': user.uid,
        'amount': product.price * qty,
        'item': {product.id.toString(): qty},
        'orderId': _orderId,
        "uidto": target['uid']
      };
      prefs.setString('tempPurchase', json.encode(tempPurchase));
      Navigator.pop(context);

      showAlertDialog(context, "발송 확인", "${target['name']} 님에게 선물을 발송할까요?", () {
        Navigator.pop(context);
/*         showDropdownAlertDialog(context, "현금영수증 옵션", userName,
            product.price * qty, _orderId, product.productName, user.name!); */
        showSnackbar(
          context,
          "${target['name']} 님에게 선물을 전송할게요.",
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
