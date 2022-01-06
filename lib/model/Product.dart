import 'dart:async';
import 'package:h4pay/Setting.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Product {
  final int id;
  final String productName;
  final int price;
  final String desc;
  final String img;
  final bool soldout;
  final bool isVisible;

  Product({
    required this.id,
    required this.desc,
    required this.img,
    required this.price,
    required this.productName,
    required this.soldout,
    required this.isVisible,
  });

  factory Product.fromList(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      desc: json['desc'],
      img: json['img'],
      price: json['price'],
      productName: json['productName'],
      soldout: json['soldout'],
      isVisible: json['isVisible'],
    );
  }
}
