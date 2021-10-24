import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:h4pay/Gift.dart';
import 'package:h4pay/Setting.dart';
import 'package:h4pay/components/Button.dart';
import 'package:h4pay/components/WebView.dart';
import 'package:intl/intl.dart';

final DateFormat dateFormat = new DateFormat('yyyy-MM-dd hh:mm');
final DateFormat dateFormatNoTime = new DateFormat('yyyy-MM-dd');
final NumberFormat numberFormat = new NumberFormat('###,###,###,###');

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

Future<bool> connectionCheck() async {
  final connStatus = await Connectivity().checkConnectivity();
  if (connStatus == ConnectivityResult.mobile ||
      connStatus == ConnectivityResult.wifi) {
    try {
      final socket = await Socket.connect(
        API_URL!.split(":")[1].split("//")[1],
        int.parse(API_URL!.split(":")[2].split("/")[0]),
        timeout: Duration(seconds: 3),
      );
      socket.destroy();
      return true;
    } catch (e) {
      return false;
    }
  }
  return false;
}

String getPrettyDateStr(String date, bool withTime) {
  if (withTime) {
    return dateFormat.format(
      DateTime.parse(date).toLocal(),
    );
  } else {
    return dateFormatNoTime.format(
      DateTime.parse(date).toLocal(),
    );
  }
}

String getPrettyAmountStr(int amount) {
  return "${numberFormat.format(amount)}원";
}

String getProductName(Map item, String firstProductName) {
  final int firstProductId = int.parse(
    item.entries.elementAt(0).key,
  );
  int totalQty = 0;
  item.forEach(
    (key, value) {
      if (int.parse(key) != firstProductId) {
        totalQty += value as int;
      }
    },
  );
  return totalQty == 0
      ? "$firstProductName"
      : "$firstProductName 외 $totalQty 개";
}

void showAlertDialog(BuildContext context, String title, String content,
    okClicked, cancelClicked) async {
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
          children: [
            Text(content),
            Container(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            OkCancelGroup(okClicked: okClicked, cancelClicked: cancelClicked)
          ],
        ),
      );
    },
  );
}

class OkCancelGroup extends StatelessWidget {
  final okClicked;
  final cancelClicked;
  OkCancelGroup({required this.okClicked, required this.cancelClicked});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 8,
          child: H4PayButton(
            text: "확인",
            onClick: okClicked,
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
            onClick: cancelClicked,
            backgroundColor: Colors.red,
          ),
        ),
      ],
    );
  }
}

checkExpire(String expire) {
  return DateTime.now().millisecondsSinceEpoch >
      DateTime.parse(expire).millisecondsSinceEpoch;
}

showCustomAlertDialog(BuildContext context, String title, List<Widget> content,
    List<Widget>? actions, bool dismissable) async {
  await showDialog(
    context: context,
    barrierDismissible: dismissable, // user must tap button!
    builder: (BuildContext context) {
      return H4PayDialog(
        title: title,
        content: Column(
          children: content,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        actions: actions,
      );
    },
  );
}

class H4PayDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget>? actions;

  const H4PayDialog(
      {Key? key, required this.title, required this.content, this.actions})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(23.0),
          ),
        ),
        title: Text(title),
        content: SingleChildScrollView(child: content),
        actions: actions);
  }
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
                    print(
                        "$amount | $orderId | $orderName | $customerName | $cashReceiptType");
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

navigateTo(Widget page, BuildContext context) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => page));
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
