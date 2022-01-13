import 'package:h4pay/model/Purchase/Purchase.dart';
import 'package:json_annotation/json_annotation.dart';

part 'Gift.g.dart';

@JsonSerializable()
class Gift extends Purchase {
  final String uidfrom;
  final String uidto;
  final bool extended;

  Gift(
      {required this.uidfrom,
      required this.uidto,
      required orderId,
      required date,
      required item,
      required expire,
      required amount,
      required exchanged,
      required paymentKey,
      required this.extended})
      : super(
          uidfrom: uidfrom,
          uidto: uidto,
          item: item,
          orderId: orderId,
          date: date,
          expire: expire,
          exchanged: exchanged,
          paymentKey: paymentKey,
          amount: amount,
        );

  factory Gift.fromJson(Map<String, dynamic> json) => _$GiftFromJson(json);
  Map<String, dynamic> toJson() => _$GiftToJson(this);
}

class SentGift {}
