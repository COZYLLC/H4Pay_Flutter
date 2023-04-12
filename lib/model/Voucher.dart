import 'package:json_annotation/json_annotation.dart';

part 'Voucher.g.dart';

@JsonSerializable()
class Voucher {
  final String id;
  final Map issuer;
  final int amount;
  final String message;
  final String date;
  final String expire;
  final bool exchanged;
  final Map? item;

  Voucher({
    required this.id,
    required this.issuer,
    required this.amount,
    required this.message,
    required this.date,
    required this.expire,
    required this.exchanged,
    this.item,
  });

  factory Voucher.fromJson(json) => _$VoucherFromJson(json);
}
