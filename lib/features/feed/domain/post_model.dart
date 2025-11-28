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

  // Engagement fields
  final int likeCount;
  final bool isLiked;

  PostModel({
    required this.id,
    required this.userId,
    this.caption,
    required this.imageUrl,
    required this.createdAt,
    this.username,
    this.avatarUrl,
    this.likeCount = 0,
    this.isLiked = false,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    // Handle joined profile data if available
    String? username;
    String? avatarUrl;

    if (json['profiles'] != null) {
      username = json['profiles']['username'];
      avatarUrl = json['profiles']['avatar_url'];
    }

    // Handle like count
    int likeCount = 0;
    if (json['likes'] != null) {
      if (json['likes'] is List && (json['likes'] as List).isNotEmpty) {
        // If using select('*, likes(count)'), it returns [{count: N}]
        final first = (json['likes'] as List).first;
        if (first is Map && first.containsKey('count')) {
          likeCount = first['count'] as int;
        }
      }
    }

    // isLiked is usually set manually or via a separate check, default to false here
    // unless we join with a filter, but that's complex for the main feed query.

    return _$PostModelFromJson(
      json,
    ).copyWith(username: username, avatarUrl: avatarUrl, likeCount: likeCount);
  }

  PostModel copyWith({
    String? username,
    String? avatarUrl,
    int? likeCount,
    bool? isLiked,
  }) {
    return PostModel(
      id: id,
      userId: userId,
      caption: caption,
      imageUrl: imageUrl,
      createdAt: createdAt,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  Map<String, dynamic> toJson() => _$PostModelToJson(this);
}
