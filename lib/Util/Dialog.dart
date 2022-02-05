import 'dart:io';

import 'package:flutter/material.dart';
import 'package:h4pay/components/Button.dart';
import 'package:h4pay/components/WebView.dart';
import 'package:h4pay/dialog/H4PayDialog.dart';
import 'package:h4pay/model/Purchase/Gift.dart';

int? lastTimeBackPressed;

Future<bool> onBackPressed(BuildContext context, bool canGoBack) async {
  if (canGoBack) {
    if (DateTime.now().millisecondsSinceEpoch <
        (lastTimeBackPressed ?? 0) + 2000) {
      // 현재 시간이 마지막으로 백버튼을 누른 시간으로부터 2초가 지난 시간보다 작은 경우
      exit(0);
    } else {
      lastTimeBackPressed = DateTime.now().millisecondsSinceEpoch;
      showSnackbar(
        context,
        "'뒤로' 버튼을 한번 더 누르시면 앱이 종료됩니다.",
        Theme.of(context).primaryColor,
        Duration(seconds: 1),
      );
      return false;
    }
  } else {
    return false;
  }
}

void showAlertDialog(BuildContext context, String title, String content,
    Function()? okClicked, Function()? cancelClicked) async {
  await showDialog(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(23.0),
          ),
        ),
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(content),
            Container(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            OkCancelGroup(
              okClicked: okClicked,
              cancelClicked: cancelClicked,
            )
          ],
        ),
      );
    },
  );
}

class OkCancelGroup extends StatelessWidget {
  final Function()? okClicked;
  final Function()? cancelClicked;
  OkCancelGroup({required this.okClicked, required this.cancelClicked});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 8,
          child: H4PayButton(
            text: "확인",
            onClick: okClicked ??
                () {
                  Navigator.pop(context);
                },
            backgroundColor: Theme.of(context).primaryColor,
          ),
        ),
        Spacer(
          flex: 1,
        ),
        Expanded(
          flex: 8,
          child: H4PayButton(
            text: "취소",
            onClick: cancelClicked ??
                () {
                  Navigator.pop(context);
                },
            backgroundColor: Colors.red,
          ),
        ),
      ],
    );
  }
}

showCustomAlertDialog(
    BuildContext context, H4PayDialog dialog, bool dismissable) async {
  await showDialog(
    context: context,
    barrierDismissible: dismissable, // user must tap button!
    builder: (BuildContext context) {
      return dialog;
    },
  );
}

showComponentDialog(
    BuildContext context, Widget widget, bool dismissable) async {
  await showDialog(
    context: context,
    barrierDismissible: dismissable,
    builder: (BuildContext context) {
      return widget;
    },
  );
}

navigateRoute(BuildContext context, Widget widget) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => widget));
}

showDropdownAlertDialog(BuildContext context, String title, String userName,
    int amount, String orderId, String orderName, String customerName) async {
  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context2) {
      List<String> cashReceipts = ["미발급", "소득공제", "지출증빙"];
      String cashReceiptType = "미발급";
      return AlertDialog(
        title: Text("현금영수증 옵션"),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(23.0),
          ),
        ),
        content: StatefulBuilder(
          builder: (context3, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              key: GlobalKey(),
              children: [
                DropdownButton(
                  value: cashReceiptType,
                  icon: Icon(Icons.keyboard_arrow_down),
                  items: cashReceipts.map((String items) {
                    return DropdownMenuItem(
                      value: items,
                      child: Text(items),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      cashReceiptType = value as String;
                    });
                  },
                ),
                H4PayButton(
                  width: double.infinity,
                  text: "확인",
                  onClick: () {
                    showSnackbar(
                      context,
                      "$userName 님에게 선물을 전송할게요.",
                      Colors.green,
                      Duration(seconds: 1),
                    );
                    Navigator.pop(context);
                    showBottomSheet(
                      context: context,
                      builder: (context) => WebViewExample(
                        type: Gift,
                        amount: amount,
                        orderId: orderId,
                        orderName: orderName,
                        customerName: customerName,
                        cashReceiptType: cashReceiptType,
                      ),
                    );
                  },
                  backgroundColor: Theme.of(context).primaryColor,
                )
              ],
            );
          },
        ),
      );
    },
  );
}

void showSnackbar(
    BuildContext context, String content, Color color, Duration duration) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
        content: Text(content), backgroundColor: color, duration: duration),
  );
}

String roleStrFromLetter(String letter) {
  String? role;
  switch (letter) {
    case 'SA':
      role = "시스템 관리자";
      break;
    case 'A':
      role = "행정실 관리자";
      break;
    case 'AT':
      role = "매점 관리 교사";
      break;
    case 'T':
      role = "일반 교사";
      break;
    case 'M':
      role = "매점 관리 학생";
      break;
    case 'S':
      role = "학생";
      break;
  }
  return role!;
}
