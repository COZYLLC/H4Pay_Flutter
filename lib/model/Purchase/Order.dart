import 'package:h4pay/model/Purchase/Purchase.dart';
import 'package:json_annotation/json_annotation.dart';

part 'Order.g.dart';

@JsonSerializable()
class Order extends Purchase {
  final String uid;
  Order({
    required this.uid,
    required orderId,
    required paymentKey,
    required date,
    required item,
    required expire,
    required amount,
    required exchanged,
  }) : super(
          uid: uid,
          orderId: orderId,
          paymentKey: paymentKey,
          date: date,
          item: item,
          expire: expire,
          amount: amount,
          exchanged: exchanged,
        );

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
  Map<String, dynamic> toJson() => _$OrderToJson(this);
}
