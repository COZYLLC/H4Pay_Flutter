import 'package:json_annotation/json_annotation.dart';

part 'UserValidResponse.g.dart';

@JsonSerializable()
class UserValidResponse {
  final bool isValid;
  final List<Map<String, dynamic>> users;
  UserValidResponse({
    required this.isValid,
    required this.users,
  });
  factory UserValidResponse.fromJson(Map<String, dynamic> json) =>
      _$UserValidResponseFromJson(json);
}
