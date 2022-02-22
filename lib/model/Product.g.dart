// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
      id: json['id'] as int,
      desc: json['desc'] as String,
      img: json['img'] as String,
      price: json['price'] as int,
      productName: json['productName'] as String,
      soldout: json['soldout'] as bool,
    );

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
      'id': instance.id,
      'productName': instance.productName,
      'price': instance.price,
      'desc': instance.desc,
      'img': instance.img,
      'soldout': instance.soldout,
    };
