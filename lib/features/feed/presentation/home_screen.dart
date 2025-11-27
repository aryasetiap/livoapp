import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:livoapp/features/auth/presentation/auth_controller.dart';
import 'package:livoapp/features/feed/data/post_repository.dart';
import 'package:livoapp/features/feed/domain/post_model.dart';
import 'package:livoapp/features/feed/presentation/widgets/post_item.dart';

final feedProvider = FutureProvider<List<PostModel>>((ref) async {
  final repository = ref.watch(postRepositoryProvider);
  return repository.getPosts();
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedState = ref.watch(feedProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Livo',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(authControllerProvider.notifier).signOut();
              context.go('/login');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(feedProvider),
        child: feedState.when(
          data: (posts) {
            if (posts.isEmpty) {
              return const Center(
                child: Text(
                  'Belum ada postingan.\nJadilah yang pertama memposting!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }
            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return PostItem(post: posts[index]);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text(
              'Error: $error',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/create-post'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
