import 'package:json_annotation/json_annotation.dart';
import 'package:lvoapp/features/auth/domain/user_model.dart';

part 'message_model.g.dart';

@JsonSerializable()
class MessageModel {
  final String id;
  @JsonKey(name: 'chat_id')
  final String chatId;
  @JsonKey(name: 'sender_id')
  final String senderId;
  final String content;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'is_read')
  final bool isRead;

  // Sender profile (optional, for UI display)
  final UserModel? sender;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.createdAt,
    this.isRead = false,
    this.sender,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);

  Map<String, dynamic> toJson() => _$MessageModelToJson(this);
}
