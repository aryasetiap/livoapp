import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livoapp/features/moderation/domain/report_model.dart';
import 'package:livoapp/features/feed/domain/post_model.dart';

final moderationRepositoryProvider = Provider<ModerationRepository>((ref) {
  return ModerationRepository(Supabase.instance.client);
});

class ModerationRepository {
  final SupabaseClient _supabase;
  GoTrueClient get _auth => _supabase.auth;

  ModerationRepository(this._supabase);

  // Report Post functionality
  Future<void> reportPost({
    required String postId,
    required String reason,
  }) async {
    final currentUserId = _auth.currentUser?.id;
    if (currentUserId == null) throw Exception('Not authenticated');

    try {
      await _supabase.from('reports').insert({
        'post_id': postId,
        'reporter_id': currentUserId,
        'reason': reason,
      });
    } catch (e) {
      throw Exception('Failed to report post: $e');
    }
  }

  // Block User functionality
  Future<void> blockUser(String blockedUserId) async {
    final currentUserId = _auth.currentUser?.id;
    if (currentUserId == null) throw Exception('Not authenticated');

    try {
      // Check if already blocked
      final existingBlock = await _supabase
          .from('blocked_users')
          .select()
          .eq('user_id', currentUserId)
          .eq('blocked_user_id', blockedUserId)
          .maybeSingle();

      if (existingBlock == null) {
        await _supabase.from('blocked_users').insert({
          'user_id': currentUserId,
          'blocked_user_id': blockedUserId,
        });
      }
    } catch (e) {
      throw Exception('Failed to block user: $e');
    }
  }

  // Unblock User functionality
  Future<void> unblockUser(String blockedUserId) async {
    final currentUserId = _auth.currentUser?.id;
    if (currentUserId == null) throw Exception('Not authenticated');

    try {
      await _supabase
          .from('blocked_users')
          .delete()
          .eq('user_id', currentUserId)
          .eq('blocked_user_id', blockedUserId);
    } catch (e) {
      throw Exception('Failed to unblock user: $e');
    }
  }

  // Check if user is blocked
  Future<bool> isUserBlocked(String userId) async {
    final currentUserId = _auth.currentUser?.id;
    if (currentUserId == null) return false;

    try {
      final result = await _supabase
          .from('blocked_users')
          .select()
          .eq('user_id', currentUserId)
          .eq('blocked_user_id', userId)
          .maybeSingle();

      return result != null;
    } catch (e) {
      return false;
    }
  }

  // Get list of blocked users
  Future<List<String>> getBlockedUserIds() async {
    final currentUserId = _auth.currentUser?.id;
    if (currentUserId == null) return [];

    try {
      final response = await _supabase
          .from('blocked_users')
          .select('blocked_user_id')
          .eq('user_id', currentUserId);

      final List<dynamic> data = response as List<dynamic>;
      return data.map((e) => e['blocked_user_id'] as String).toList();
    } catch (e) {
      return [];
    }
  }

  // Filter posts from blocked users
  Future<List<PostModel>> filterBlockedUsersFromPosts(
    List<PostModel> posts,
  ) async {
    final currentUserId = _auth.currentUser?.id;
    if (currentUserId == null) return posts;

    try {
      // Get blocked users list
      final blockedUserIds = await getBlockedUserIds();

      // Filter posts where author is not blocked
      final filteredPosts = posts.where((post) {
        return !blockedUserIds.contains(post.userId);
      }).toList();

      return filteredPosts;
    } catch (e) {
      // Return original posts if filtering fails
      return posts;
    }
  }

  // Get user's reports (for moderation purposes)
  Future<List<ReportModel>> getReports({int limit = 50}) async {
    try {
      final response = await _supabase
          .from('reports')
          .select('*, posts(*)')
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List).map((json) {
        final reportData = Map<String, dynamic>.from(json);
        // Merge post data if available
        if (reportData['posts'] != null) {
          reportData['post'] = reportData['posts'];
        }
        return ReportModel.fromJson(reportData);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch reports: $e');
    }
  }
}
