import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:livoapp/features/feed/domain/post_model.dart';

import 'package:flutter_image_compress/flutter_image_compress.dart';

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

  Future<List<PostModel>> getPosts({int page = 0, int limit = 10}) async {
    final from = page * limit;
    final to = from + limit - 1;

    final response = await _supabase
        .from('posts')
        .select('*, profiles(username, avatar_url)')
        .order('created_at', ascending: false)
        .range(from, to);

    return response.map((json) => PostModel.fromJson(json)).toList();
  }
}
