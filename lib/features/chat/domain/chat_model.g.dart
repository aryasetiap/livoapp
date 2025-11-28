// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatModel _$ChatModelFromJson(Map<String, dynamic> json) => ChatModel(
  id: json['id'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  participants: (json['participants'] as List<dynamic>?)
      ?.map((e) => UserModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  lastMessage: json['last_message'] == null
      ? null
      : MessageModel.fromJson(json['last_message'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ChatModelToJson(ChatModel instance) => <String, dynamic>{
  'id': instance.id,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'participants': instance.participants,
  'last_message': instance.lastMessage,
};
