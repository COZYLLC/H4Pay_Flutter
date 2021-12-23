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

String getOrderName(Map item, String firstProductName) {
  final int firstProductId = int.parse(
    item.entries.elementAt(0).key,
  );
  final int firstProductQty = item.entries.elementAt(0).value;
  int totalQtyExceptFirst = 0;
  item.forEach(
    (key, value) {
      if (int.parse(key) != firstProductId) {
        totalQtyExceptFirst += value as int;
      }
    },
  );
  return totalQtyExceptFirst == 0
      ? "$firstProductName $firstProductQty개"
      : "$firstProductName $firstProductQty개 외 $totalQtyExceptFirst 개";
}
