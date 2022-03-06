import 'package:h4pay/model/Purchase/TempPurchase.dart';

class PaymentData {
  final TempPurchase tempPurchase;
  final String? receiverName;
  final String orderName;
  final String reason;
  final String customerName;
  final String cashReceiptType;

  PaymentData({
    required this.tempPurchase,
    required this.receiverName,
    required this.orderName,
    required this.reason,
    required this.customerName,
    required this.cashReceiptType,
  });

  PaymentData.order({
    this.receiverName,
    required this.tempPurchase,
    required this.orderName,
    required this.reason,
    required this.customerName,
    required this.cashReceiptType,
  });
}
