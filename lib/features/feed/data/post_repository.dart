import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:livoapp/features/feed/domain/post_model.dart';
import 'package:livoapp/features/feed/domain/comment_model.dart';
import 'package:livoapp/features/moderation/data/moderation_repository.dart';
import 'package:livoapp/features/notifications/data/notification_repository.dart';

import 'package:flutter_image_compress/flutter_image_compress.dart';

final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepository(
    Supabase.instance.client,
    ref.read(moderationRepositoryProvider),
    ref.read(notificationRepositoryProvider),
  );
});

class PostRepository {
  final SupabaseClient _supabase;
  final ModerationRepository _moderationRepository;
  final NotificationRepository _notificationRepository;

  PostRepository(
    this._supabase,
    this._moderationRepository,
    this._notificationRepository,
  );

  Future<void> createPost({
    required String userId,
    required String caption,
    required File imageFile,
  }) async {
    final compressedImage = await _compressImage(imageFile);
    final imageUrl = await _uploadImage(userId, compressedImage);

    await _supabase.from('posts').insert({
      'user_id': userId,
      'caption': caption,
      'image_url': imageUrl,
    });
  }

  Future<File> _compressImage(File file) async {
    final filePath = file.absolute.path;
    final lastIndex = filePath.lastIndexOf(Platform.pathSeparator);
    final newPath = filePath.substring(0, lastIndex);
    final targetPath =
        '$newPath/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 80,
      minWidth: 1080,
      minHeight: 1080,
    );

    return File(result!.path);
  }

  Future<String> _uploadImage(String userId, File imageFile) async {
    final fileExt = imageFile.path.split('.').last;
    final fileName = '${const Uuid().v4()}.$fileExt';
    final filePath = '$userId/$fileName';

    await _supabase.storage
        .from('posts')
        .upload(
          filePath,
          imageFile,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );

    final imageUrl = _supabase.storage.from('posts').getPublicUrl(filePath);
    return imageUrl;
  }

  Future<List<PostModel>> getPosts({
    int page = 0,
    int limit = 10,
    List<String>? filterUserIds,
  }) async {
    final from = page * limit;
    final to = from + limit - 1;
    final userId = _supabase.auth.currentUser?.id;

    var query = _supabase
        .from('posts')
        .select('*, profiles(username, avatar_url), likes(count)');

    if (filterUserIds != null) {
      query = query.filter('user_id', 'in', filterUserIds);
    }

    final response = await query
        .order('created_at', ascending: false)
        .range(from, to);

    final posts = response.map((json) => PostModel.fromJson(json)).toList();

    // Apply moderation filter - remove posts from blocked users
    final filteredPosts = await _moderationRepository
        .filterBlockedUsersFromPosts(posts);

    if (userId != null && filteredPosts.isNotEmpty) {
      final postIds = filteredPosts.map((p) => p.id).toList();
      final likedResponse = await _supabase
          .from('likes')
          .select('post_id')
          .eq('user_id', userId)
          .filter('post_id', 'in', postIds);

      final likedPostIds = (likedResponse as List)
          .map((e) => e['post_id'] as String)
          .toSet();

      return filteredPosts
          .map((p) => p.copyWith(isLiked: likedPostIds.contains(p.id)))
          .toList();
    }

    return filteredPosts;
  }

  Future<void> toggleLike(String postId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    final postOwnerId = await _getPostOwnerId(postId);

    try {
      await _supabase.from('likes').insert({
        'user_id': userId,
        'post_id': postId,
      });

      // Create notification for post owner
      if (postOwnerId != null && postOwnerId != userId) {
        await _notificationRepository.createLikeNotification(
          postOwnerId,
          _supabase.auth.currentUser?.userMetadata?['username'] ?? 'User',
        );
      }
    } catch (e) {
      // If insert fails (unique constraint), it means already liked, so delete
      await _supabase
          .from('likes')
          .delete()
          .eq('user_id', userId)
          .eq('post_id', postId);
    }
  }

  Future<String?> _getPostOwnerId(String postId) async {
    try {
      final response = await _supabase
          .from('posts')
          .select('user_id')
          .eq('id', postId)
          .single();

      return response['user_id'] as String?;
    } catch (e) {
      return null;
    }
  }

  Future<List<CommentModel>> getComments(String postId) async {
    final response = await _supabase
        .from('comments')
        .select('*, profiles!comments_user_id_fkey(username, avatar_url)')
        .eq('post_id', postId)
        .order('created_at', ascending: true);

    return response.map((json) => CommentModel.fromJson(json)).toList();
  }

  Future<List<PostModel>> getUserPosts(String userId) async {
    final response = await _supabase
        .from('posts')
        .select('*, profiles(username, avatar_url), likes(count)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    final posts = response.map((json) => PostModel.fromJson(json)).toList();
    return posts;
  }

  Future<void> addComment(String postId, String content) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    await _supabase.from('comments').insert({
      'user_id': userId,
      'post_id': postId,
      'content': content,
    });

    // Create notification for post owner
    final postOwnerId = await _getPostOwnerId(postId);
    if (postOwnerId != null && postOwnerId != userId) {
      await _notificationRepository.createCommentNotification(
        postOwnerId,
        _supabase.auth.currentUser?.userMetadata?['username'] ?? 'User',
      );
    }
  }
}
