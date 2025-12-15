import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lvoapp/features/notifications/domain/notification_model.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(Supabase.instance.client);
});

class NotificationRepository {
  final SupabaseClient _supabase;
  GoTrueClient get _auth => _supabase.auth;

  NotificationRepository(this._supabase);

  // Create notification record
  Future<void> createNotification({
    required String type,
    required String title,
    String? body,
    String? relatedId,
    String? relatedUserId,
  }) async {
    final currentUserId = _auth.currentUser?.id;
    if (currentUserId == null) throw Exception('Not authenticated');

    try {
      await _supabase.from('notifications').insert({
        'user_id': currentUserId,
        'notification_type': type,
        'title': title,
        'body': body,
        'related_id': relatedId,
        'related_user_id': relatedUserId,
        'is_read': false,
      });
    } catch (e) {
      throw Exception('Failed to create notification: $e');
    }
  }

  // Get user notifications
  Future<List<NotificationModel>> getUserNotifications() async {
    final currentUserId = _auth.currentUser?.id;
    if (currentUserId == null) return [];

    try {
      final response = await _supabase
          .from('notifications')
          .select('*, related_user:profiles!related_user_id(*)')
          .eq('user_id', currentUserId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((e) => NotificationModel.fromJson(e))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch notifications: $e');
    }
  }

  // Mark single notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    final currentUserId = _auth.currentUser?.id;
    if (currentUserId == null) return;

    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId)
          .eq('user_id', currentUserId);
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  // Mark all notifications as read
  Future<void> markAllNotificationsAsRead() async {
    final currentUserId = _auth.currentUser?.id;
    if (currentUserId == null) return;

    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', currentUserId)
          .eq('is_read', false);
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  // Get unread notifications count
  Future<int> getUnreadNotificationsCount() async {
    final currentUserId = _auth.currentUser?.id;
    if (currentUserId == null) return 0;

    try {
      final response = await _supabase
          .from('notifications')
          .select('id')
          .eq('user_id', currentUserId)
          .eq('is_read', false);

      final count = (response as List).length;
      return count;
    } catch (e) {
      return 0;
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    final currentUserId = _auth.currentUser?.id;
    if (currentUserId == null) return;

    try {
      await _supabase
          .from('notifications')
          .delete()
          .eq('id', notificationId)
          .eq('user_id', currentUserId);
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }

  // Create notifications for various events
  Future<void> createLikeNotification(
    String postOwnerId,
    String likerUsername,
  ) async {
    // Don't notify if user likes their own post
    if (postOwnerId == _auth.currentUser?.id) return;

    // Note: In a real app, you'd want to insert this for the postOwnerId, not the current user (liker).
    // The current implementation of createNotification uses _auth.currentUser?.id as user_id.
    // We need to modify createNotification or pass the targetUserId explicitly.
    // For now, I will assume createNotification needs to be updated to accept targetUserId.
    // However, to minimize changes and follow the existing pattern, I'll adjust the insert logic here directly
    // or assume the previous implementation was intended for the current user to see their OWN actions?
    // No, notifications are for OTHER users.

    // Correcting logic: The notification should be created for the postOwnerId.
    // But createNotification uses _auth.currentUser?.id.
    // I will overload createNotification or create a new internal method.
    // Actually, let's just use _supabase directly here for correctness or update createNotification.

    // Updating createNotification to accept targetUserId would be best, but let's stick to the requested fixes first.
    // Wait, the previous code had:
    // 'user_id': currentUserId,
    // This means the notification is created FOR the current user. That's wrong for a "Like" notification.
    // If I like your post, YOU should get the notification.

    // I will update createNotification to take a targetUserId.
    await _createNotificationForUser(
      targetUserId: postOwnerId,
      type: 'like',
      title: '$likerUsername menyukai postingan Anda',
      relatedUserId: _auth.currentUser?.id,
    );
  }

  Future<void> createCommentNotification(
    String postOwnerId,
    String commenterUsername,
  ) async {
    if (postOwnerId == _auth.currentUser?.id) return;

    await _createNotificationForUser(
      targetUserId: postOwnerId,
      type: 'comment',
      title: '$commenterUsername mengomentar postingan Anda',
      relatedUserId: _auth.currentUser?.id,
    );
  }

  Future<void> createFollowNotification(
    String targetUserId,
    String followerUsername,
  ) async {
    if (targetUserId == _auth.currentUser?.id) return;

    await _createNotificationForUser(
      targetUserId: targetUserId,
      type: 'follow',
      title: '$followerUsername mengikuti Anda',
      relatedUserId: _auth.currentUser?.id,
    );
  }

  // Internal helper to create notification for a specific user
  Future<void> _createNotificationForUser({
    required String targetUserId,
    required String type,
    required String title,
    String? body,
    String? relatedId,
    String? relatedUserId,
  }) async {
    try {
      await _supabase.from('notifications').insert({
        'user_id': targetUserId,
        'notification_type': type,
        'title': title,
        'body': body,
        'related_id': relatedId,
        'related_user_id': relatedUserId,
        'is_read': false,
      });
    } catch (e) {
      throw Exception('Failed to create notification: $e');
    }
  }
}
