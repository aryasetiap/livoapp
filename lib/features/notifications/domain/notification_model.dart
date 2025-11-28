import 'package:json_annotation/json_annotation.dart';
import 'package:livoapp/features/auth/domain/user_model.dart';

part 'notification_model.g.dart';

@JsonSerializable()
class NotificationModel {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'notification_type')
  final String type; // 'like', 'comment', 'follow', 'message'
  final String? title;
  final String? body;
  final String? relatedId; // post_id, comment_id, follower_id, chat_id
  @JsonKey(name: 'related_user_id')
  final String? relatedUserId; // user yang melakukan aksi
  @JsonKey(name: 'related_user')
  final UserModel? relatedUser;
  @JsonKey(name: 'is_read')
  final bool isRead;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    this.title,
    this.body,
    this.relatedId,
    this.relatedUserId,
    this.relatedUser,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);

  // Helper methods
  bool get isLike => type == 'like';
  bool get isComment => type == 'comment';
  bool get isFollow => type == 'follow';
  bool get isMessage => type == 'message';

  String get displayTitle {
    switch (type) {
      case 'like':
        return '${relatedUser?.username ?? 'User'} menyukai postingan Anda';
      case 'comment':
        return '${relatedUser?.username ?? 'User'} mengomentar postingan Anda';
      case 'follow':
        return '${relatedUser?.username ?? 'User'} mengikuti Anda';
      case 'message':
        return '${relatedUser?.username ?? 'User'} mengirim pesan';
      default:
        return title ?? 'Notifikasi';
    }
  }
}