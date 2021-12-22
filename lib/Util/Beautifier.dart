import 'package:intl/intl.dart';

final DateFormat dateFormat = new DateFormat('yyyy-MM-dd HH:mm');
final DateFormat dateFormatNoTime = new DateFormat('yyyy-MM-dd');
final NumberFormat numberFormat = new NumberFormat('###,###,###,###');

isPassedExpire(String expire) {
  return DateTime.now().millisecondsSinceEpoch >
      DateTime.parse(expire).millisecondsSinceEpoch;
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
