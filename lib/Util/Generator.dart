String genOrderId() {
  final today = new DateTime.now();
  final year = today.year;
  final month = today.month;
  final date = today.day;
  final time = today.millisecondsSinceEpoch;
  String orderId = year.toString();

  if (month < 10) {
    orderId += "0";
  }
  orderId += month.toString();
  if (date < 10) {
    orderId += "0";
  }
  orderId += date.toString() + time.toString();
  return orderId;
}
