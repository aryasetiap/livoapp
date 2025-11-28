import 'package:json_annotation/json_annotation.dart';
import 'package:livoapp/features/auth/domain/user_model.dart';
import 'package:livoapp/features/chat/domain/message_model.dart';

part 'chat_model.g.dart';

@JsonSerializable()
class ChatModel {
  final String id;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  // This will be populated by joining with profiles
  // We expect the query to return a list of participants (profiles)
  // But usually in a chat list, we want to show the "other" user.
  // For simplicity in Supabase, we might fetch all participants.
  final List<UserModel>? participants;

  // Last message for preview
  @JsonKey(name: 'last_message')
  final MessageModel? lastMessage;

  ChatModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.participants,
    this.lastMessage,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) =>
      _$ChatModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChatModelToJson(this);
}
