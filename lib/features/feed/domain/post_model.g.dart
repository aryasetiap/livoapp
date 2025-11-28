// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostModel _$PostModelFromJson(Map<String, dynamic> json) => PostModel(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  caption: json['caption'] as String?,
  imageUrl: json['image_url'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  username: json['username'] as String?,
  avatarUrl: json['avatar_url'] as String?,
  likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
  isLiked: json['isLiked'] as bool? ?? false,
);

Map<String, dynamic> _$PostModelToJson(PostModel instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'caption': instance.caption,
  'image_url': instance.imageUrl,
  'created_at': instance.createdAt.toIso8601String(),
  'username': instance.username,
  'avatar_url': instance.avatarUrl,
  'likeCount': instance.likeCount,
  'isLiked': instance.isLiked,
};
