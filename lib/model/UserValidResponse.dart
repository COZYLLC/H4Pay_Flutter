import 'package:json_annotation/json_annotation.dart';

part 'UserValidResponse.g.dart';

@JsonSerializable()
class UserValidResponse {
  final bool isValid;
  final List<String> users;
  UserValidResponse({
    required this.isValid,
    required this.users,
  });
  factory UserValidResponse.fromJson(Map<String, dynamic> json) =>
      _$UserValidResponseFromJson(json);
}
