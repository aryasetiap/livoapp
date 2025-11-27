import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:livoapp/features/feed/domain/post_model.dart';

final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepository(Supabase.instance.client);
});

class PostRepository {
  final SupabaseClient _supabase;

  PostRepository(this._supabase);

  Future<void> createPost({
    required String userId,
    required String caption,
    required File imageFile,
  }) async {
    final imageUrl = await _uploadImage(userId, imageFile);

    await _supabase.from('posts').insert({
      'user_id': userId,
      'caption': caption,
      'image_url': imageUrl,
    });
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

  Future<List<PostModel>> getPosts() async {
    final response = await _supabase
        .from('posts')
        .select('*, profiles(username, avatar_url)')
        .order('created_at', ascending: false);

    return response.map((json) => PostModel.fromJson(json)).toList();
  }
}
