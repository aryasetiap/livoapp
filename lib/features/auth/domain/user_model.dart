import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String id;
  final String username;
  final String email;
  final String? bio;
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.bio,
    this.avatarUrl,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
