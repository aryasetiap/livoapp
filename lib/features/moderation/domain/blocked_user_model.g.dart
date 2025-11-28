// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blocked_user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BlockedUserModel _$BlockedUserModelFromJson(Map<String, dynamic> json) =>
    BlockedUserModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      blockedUserId: json['blocked_user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$BlockedUserModelToJson(BlockedUserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'blocked_user_id': instance.blockedUserId,
      'created_at': instance.createdAt.toIso8601String(),
    };
