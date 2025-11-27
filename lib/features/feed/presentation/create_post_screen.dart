import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:livoapp/features/feed/data/post_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final createPostControllerProvider =
    StateNotifierProvider<CreatePostController, AsyncValue<void>>((ref) {
      return CreatePostController(ref.watch(postRepositoryProvider));
    });

class CreatePostController extends StateNotifier<AsyncValue<void>> {
  final PostRepository _repository;

  CreatePostController(this._repository) : super(const AsyncValue.data(null));

  Future<void> createPost({
    required String userId,
    required String caption,
    required File imageFile,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repository.createPost(
        userId: userId,
        caption: caption,
        imageFile: imageFile,
      ),
    );
  }
}

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _captionController = TextEditingController();
  File? _imageFile;
  final _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _submit() async {
    if (_imageFile == null) return;

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final controller = ref.read(createPostControllerProvider.notifier);
    await controller.createPost(
      userId: user.id,
      caption: _captionController.text,
      imageFile: _imageFile!,
    );

    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createPostControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Postingan Baru'),
        actions: [
          TextButton(
            onPressed: state.isLoading || _imageFile == null ? null : _submit,
            child: state.isLoading
                ? const CircularProgressIndicator()
                : const Text('Posting'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade800),
                ),
                child: _imageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_imageFile!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_rounded,
                            size: 48,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Pilih Foto',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _captionController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Tulis caption menarik...',
                border: InputBorder.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
