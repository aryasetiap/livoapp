// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommentModel _$CommentModelFromJson(Map<String, dynamic> json) => CommentModel(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  postId: json['post_id'] as String,
  content: json['content'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  username: json['username'] as String?,
  avatarUrl: json['avatar_url'] as String?,
);

Map<String, dynamic> _$CommentModelToJson(CommentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'post_id': instance.postId,
      'content': instance.content,
      'created_at': instance.createdAt.toIso8601String(),
      'username': instance.username,
      'avatar_url': instance.avatarUrl,
    };
