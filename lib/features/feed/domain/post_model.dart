import 'package:json_annotation/json_annotation.dart';

part 'post_model.g.dart';

@JsonSerializable()
class PostModel {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  final String? caption;
  @JsonKey(name: 'image_url')
  final String imageUrl;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  // Profile fields (joined)
  final String? username;
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;

  PostModel({
    required this.id,
    required this.userId,
    this.caption,
    required this.imageUrl,
    required this.createdAt,
    this.username,
    this.avatarUrl,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    // Handle joined profile data if available
    String? username;
    String? avatarUrl;

    if (json['profiles'] != null) {
      username = json['profiles']['username'];
      avatarUrl = json['profiles']['avatar_url'];
    }

    return _$PostModelFromJson(
      json,
    ).copyWith(username: username, avatarUrl: avatarUrl);
  }

  PostModel copyWith({String? username, String? avatarUrl}) {
    return PostModel(
      id: id,
      userId: userId,
      caption: caption,
      imageUrl: imageUrl,
      createdAt: createdAt,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  Map<String, dynamic> toJson() => _$PostModelToJson(this);
}
