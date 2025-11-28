// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['id'] as String,
  username: json['username'] as String,
  email: json['email'] as String?,
  bio: json['bio'] as String?,
  avatarUrl: json['avatar_url'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  followersCount: (json['followers_count'] as num?)?.toInt() ?? 0,
  followingCount: (json['following_count'] as num?)?.toInt() ?? 0,
  isFollowing: json['isFollowing'] as bool? ?? false,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'email': instance.email,
  'bio': instance.bio,
  'avatar_url': instance.avatarUrl,
  'created_at': instance.createdAt.toIso8601String(),
  'followers_count': instance.followersCount,
  'following_count': instance.followingCount,
  'isFollowing': instance.isFollowing,
};
