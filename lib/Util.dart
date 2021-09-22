import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:h4pay_flutter/Order.dart';
import 'package:h4pay_flutter/Product.dart';
import 'package:h4pay_flutter/components/Button.dart';
import 'package:intl/intl.dart';

final DateFormat dateFormat = new DateFormat('yyyy-MM-dd hh:mm');
final DateFormat dateFormatNoTime = new DateFormat('yyyy-MM-dd');
final NumberFormat numberFormat = new NumberFormat('###,###,###,###');

String getPrettyDateStr(String date, bool withTime) {
  if (withTime) {
    return dateFormat.format(
      DateTime.parse(date),
    );
  } else {
    return dateFormatNoTime.format(
      DateTime.parse(date),
    );
  }
}

String getPrettyAmountStr(int amount) {
  return "${numberFormat.format(amount)}원";
}

String getProductNameFromList(Map item, List<Product> products) {
  final int firstProductId = int.parse(
    item.entries.elementAt(0).key,
  );
  final productName = products[firstProductId].productName;
  int totalQty = 0;
  item.forEach(
    (key, value) {
      if (int.parse(key) != firstProductId) {
        totalQty += value as int;
      }
    },
  );
  return totalQty == 0 ? "$productName" : "$productName 외 $totalQty 개";
}

String getProductName(Map item, Product product) {
  final int firstProductId = int.parse(
    item.entries.elementAt(0).key,
  );
  final productName = product.productName;
  int totalQty = 0;
  item.forEach(
    (key, value) {
      if (int.parse(key) != firstProductId) {
        totalQty += value as int;
      }
    },
  );
  return totalQty == 0 ? "$productName" : "$productName 외 $totalQty 개";
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
        content: Text(content),
        actions: <Widget>[
          H4PayButton(
              text: "확인",
              onClick: okClicked,
              backgroundColor: Colors.blue,
              width: MediaQuery.of(context).size.width * 0.3),
          H4PayButton(
              text: "취소",
              onClick: cancelClicked,
              backgroundColor: Colors.blue,
              width: MediaQuery.of(context).size.width * 0.3)
        ],
      );
    },
  );
}

showCustomAlertDialog(BuildContext context, String title, List<Widget> content,
    List<Widget> actions, bool dismissable) async {
  await showDialog(
    context: context,
    barrierDismissible: dismissable, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(23.0),
            ),
          ),
          title: Text(title),
          content: Column(
            children: content,
            mainAxisSize: MainAxisSize.min,
          ),
          actions: actions);
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
