import 'package:h4pay/model/Notice.dart';
import 'package:json_annotation/json_annotation.dart';

part 'Event.g.dart';

@JsonSerializable()
class Event extends Notice {
  final String id;
  final String title;
  final String start;
  final String end;
  final int qty;
  final int totalqty;
  final int price;
  final String content;
  final String img;

  Event(
      {required this.id,
      required this.title,
      required this.start,
      required this.end,
      required this.qty,
      required this.totalqty,
      required this.price,
      required this.content,
      required this.img})
      : super(
          id: id,
          title: title,
          content: content,
          date: start,
          img: img,
        );

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
  Map<String, dynamic> toJson() => _$EventToJson(this);
}
