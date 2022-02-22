import 'package:json_annotation/json_annotation.dart';

part 'Product.g.dart';

@JsonSerializable()
class Product {
  final int id;
  final String productName;
  final int price;
  final String desc;
  final String img;
  final bool soldout;

  Product({
    required this.id,
    required this.desc,
    required this.img,
    required this.price,
    required this.productName,
    required this.soldout,
  });

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}
