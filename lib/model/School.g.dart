// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'School.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

School _$SchoolFromJson(Map<String, dynamic> json) => School(
      name: json['name'] as String,
      id: json['id'] as String,
      seller: Seller.fromJson(json['seller'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SchoolToJson(School instance) => <String, dynamic>{
      'name': instance.name,
      'id': instance.id,
      'seller': instance.seller,
    };

Seller _$SellerFromJson(Map<String, dynamic> json) => Seller(
      name: json['name'] as String,
      founderName: json['founderName'] as String,
      address: json['address'] as String,
      tel: json['tel'] as String,
      businessId: json['businessId'] as String,
      sellerId: json['sellerId'] as String,
    );

Map<String, dynamic> _$SellerToJson(Seller instance) => <String, dynamic>{
      'name': instance.name,
      'founderName': instance.founderName,
      'address': instance.address,
      'tel': instance.tel,
      'businessId': instance.businessId,
      'sellerId': instance.sellerId,
    };
