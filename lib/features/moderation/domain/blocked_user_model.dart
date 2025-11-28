import 'package:json_annotation/json_annotation.dart';

part 'blocked_user_model.g.dart';

@JsonSerializable()
class BlockedUserModel {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'blocked_user_id')
  final String blockedUserId;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  BlockedUserModel({
    required this.id,
    required this.userId,
    required this.blockedUserId,
    required this.createdAt,
  });

  factory BlockedUserModel.fromJson(Map<String, dynamic> json) =>
      _$BlockedUserModelFromJson(json);

  Map<String, dynamic> toJson() => _$BlockedUserModelToJson(this);
}