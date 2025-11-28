// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageModel _$MessageModelFromJson(Map<String, dynamic> json) => MessageModel(
  id: json['id'] as String,
  chatId: json['chat_id'] as String,
  senderId: json['sender_id'] as String,
  content: json['content'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  isRead: json['is_read'] as bool? ?? false,
  sender: json['sender'] == null
      ? null
      : UserModel.fromJson(json['sender'] as Map<String, dynamic>),
);

Map<String, dynamic> _$MessageModelToJson(MessageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'chat_id': instance.chatId,
      'sender_id': instance.senderId,
      'content': instance.content,
      'created_at': instance.createdAt.toIso8601String(),
      'is_read': instance.isRead,
      'sender': instance.sender,
    };
