import 'package:json_annotation/json_annotation.dart';

part 'School.g.dart';

@JsonSerializable()
class School {
  final String name;
  final String id;
  final Seller seller;
  School({
    required this.name,
    required this.id,
    required this.seller,
  });
  factory School.fromJson(Map<String, dynamic> json) => _$SchoolFromJson(json);
}

@JsonSerializable()
class Seller {
  final String name;
  final String founderName;
  final String address;
  final String tel;
  final String businessId;
  final String sellerId;

  Seller({
    required this.name,
    required this.founderName,
    required this.address,
    required this.tel,
    required this.businessId,
    required this.sellerId,
  });
  factory Seller.fromJson(Map<String, dynamic> json) => _$SellerFromJson(json);
}
