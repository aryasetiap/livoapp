import 'package:json_annotation/json_annotation.dart';

part 'comment_model.g.dart';

@JsonSerializable()
class CommentModel {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'post_id')
  final String postId;
  final String content;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  // Profile fields (joined)
  final String? username;
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;

  CommentModel({
    required this.id,
    required this.userId,
    required this.postId,
    required this.content,
    required this.createdAt,
    this.username,
    this.avatarUrl,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    // Create a mutable copy to modify types if needed
    final Map<String, dynamic> data = Map<String, dynamic>.from(json);

    // Handle joined profile data if available
    String? username;
    String? avatarUrl;

    if (data['profiles'] != null) {
      username = data['profiles']['username'];
      avatarUrl = data['profiles']['avatar_url'];
    }

    // Fix id type issue (bigint -> String)
    if (data['id'] is int) {
      data['id'] = data['id'].toString();
    }

    return _$CommentModelFromJson(
      data,
    ).copyWith(username: username, avatarUrl: avatarUrl);
  }

  CommentModel copyWith({String? username, String? avatarUrl}) {
    return CommentModel(
      id: id,
      userId: userId,
      postId: postId,
      content: content,
      createdAt: createdAt,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  Map<String, dynamic> toJson() => _$CommentModelToJson(this);
}
