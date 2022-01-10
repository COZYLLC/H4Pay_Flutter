import 'dart:async';
import 'dart:convert';

import 'package:h4pay/Network/Network.dart';
import 'package:h4pay/exception.dart';
import 'package:h4pay/model/Product.dart';
import 'package:h4pay/Setting.dart';

Future<List<Product>> fetchProduct(String from) async {
  final response = await get(
    Uri.parse('$API_URL/product'),
  );
  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);

    List productsJson = jsonResponse['result'];
    List<Product> products =
        productsJson.map((e) => Product.fromList(e)).toList();
    return products;
  } else {
    throw NetworkException(response.statusCode);
  }
}

Future<List<Product>> fetchProductOnlyVisible(String from) async {
  final response = await get(
    Uri.parse('$API_URL/product/filter?withStored=0'),
  );
  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    List productsJson = jsonResponse['result'];
    List<Product> products =
        productsJson.map((e) => Product.fromList(e)).toList();
    return products;
  } else {
    throw NetworkException(response.statusCode);
  }
}
