import 'dart:convert';

import 'package:h4pay/Network/Network.dart';
import 'package:h4pay/exception.dart';
import 'package:h4pay/model/Voucher.dart';
import 'package:h4pay/Setting.dart';

Future<List<Voucher>> fetchVouchers(String tel) async {
  final response = await get(
    Uri.parse("$API_URL/voucher/filter?tel=$tel"),
  );
  if (response.statusCode == 200) {
    final Map jsonBody = jsonDecode(response.body);
    final List vouchersJson = jsonBody['result'];
    return vouchersJson.map((e) => Voucher.fromJson(e)).toList();
  } else {
    throw NetworkException(response.statusCode);
  }
}

Future<Voucher> fetchVoucherDetail(String id) async {
  final response = await get(Uri.parse("$API_URL/voucher/filter?id=$id"));
  if (response.statusCode == 200) {
    final Map jsonBody = jsonDecode(response.body);
    return Voucher.fromJson(jsonBody['result'][0]);
  } else {
    throw NetworkException(response.statusCode);
  }
}
