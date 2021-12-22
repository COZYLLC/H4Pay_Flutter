import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:h4pay/Payment.dart';
import 'package:h4pay/Util.dart';
import 'package:h4pay/Util/Beautifier.dart';
import 'package:h4pay/Voucher.dart';
import 'package:h4pay/main.dart';

class VoucherDetailPage extends StatelessWidget {
  final Voucher voucher;
  VoucherDetailPage({required this.voucher});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: H4PayAppbar(title: "상품권 사용", height: 56, canGoBack: true),
      body: Container(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BarcodeWidget(
              barcode: Barcode.code128(),
              data: voucher.id,
            ),
            Column(
              children: [
                ReceiptText(
                    title: "발송인 이름",
                    content: voucher.issuer['name'].toString()),
                ReceiptText(
                    title: "발행 일시",
                    content: getPrettyDateStr(voucher.date, true)),
                ReceiptText(
                    title: "만료 일시",
                    content: getPrettyDateStr(voucher.expire, true)),
                ReceiptText(
                    title: "액면가", content: getPrettyAmountStr(voucher.amount)),
                ReceiptText(title: "선물 메시지", content: voucher.message)
              ],
            )
          ],
        ),
      ),
    );
  }
}
