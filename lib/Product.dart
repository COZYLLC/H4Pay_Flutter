import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Product {
  final int id;
  final String productName;
  final int price;
  final String desc;
  final String img;
  final bool soldout;

  Product(
      {required this.id,
      required this.desc,
      required this.img,
      required this.price,
      required this.productName,
      required this.soldout});

  factory Product.fromList(Map<String, dynamic> json) {
    //print(json);
    return Product(
        id: json['id'],
        desc: json['desc'],
        img: json['img'],
        price: json['price'],
        productName: json['productName'],
        soldout: json['soldout']);
  }
}

Future<List<Product>?> fetchProduct() async {
  final response = await http.get(
    Uri.parse('${dotenv.env['API_URL']}/product'),
  );
  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    if (jsonResponse['status']) {
      List products = jsonDecode(response.body)['list'];
      return products.map((e) => Product.fromList(e)).toList();
    } else {
      return null;
    }
  } else {
    throw Exception('Failed to fetch product.');
  }
}
