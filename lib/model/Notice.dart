import 'package:json_annotation/json_annotation.dart';
part 'Notice.g.dart';

@JsonSerializable()
class Notice {
  final String id;
  final String title;
  final String content;
  final String img;
  final String date;

  Notice({
    required this.id,
    required this.title,
    required this.content,
    required this.img,
    required this.date,
  });

  factory Notice.fromJson(Map<String, dynamic> json) => _$NoticeFromJson(json);
}
