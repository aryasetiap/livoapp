// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    NotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: json['notification_type'] as String,
      title: json['title'] as String?,
      body: json['body'] as String?,
      relatedId: json['relatedId'] as String?,
      relatedUserId: json['related_user_id'] as String?,
      relatedUser: json['relatedUser'] == null
          ? null
          : UserModel.fromJson(json['relatedUser'] as Map<String, dynamic>),
      isRead: json['is_read'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$NotificationModelToJson(NotificationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'notification_type': instance.type,
      'title': instance.title,
      'body': instance.body,
      'relatedId': instance.relatedId,
      'related_user_id': instance.relatedUserId,
      'relatedUser': instance.relatedUser,
      'is_read': instance.isRead,
      'created_at': instance.createdAt.toIso8601String(),
    };
