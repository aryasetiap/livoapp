import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livoapp/features/feed/data/post_repository.dart';
import 'package:livoapp/features/feed/domain/comment_model.dart';
import 'package:livoapp/features/feed/domain/post_model.dart';
import 'package:livoapp/features/feed/presentation/widgets/post_item.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';

final commentsProvider = FutureProvider.family<List<CommentModel>, String>((
  ref,
  postId,
) {
  return ref.watch(postRepositoryProvider).getComments(postId);
});

class PostDetailScreen extends ConsumerStatefulWidget {
  final PostModel post;

  const PostDetailScreen({super.key, required this.post});

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      await ref
          .read(postRepositoryProvider)
          .addComment(widget.post.id, content);
      _commentController.clear();
      // Refresh comments
      ref.invalidate(commentsProvider(widget.post.id));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mengirim komentar: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final commentsState = ref.watch(commentsProvider(widget.post.id));

    return Scaffold(
      appBar: AppBar(title: const Text('Postingan')),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: PostItem(post: widget.post, isDetail: true),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Komentar',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                commentsState.when(
                  data: (comments) {
                    if (comments.isEmpty) {
                      return const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Center(
                            child: Text(
                              'Belum ada komentar.\nJadilah yang pertama berkomentar!',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      );
                    }
                    return SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final comment = comments[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: comment.avatarUrl != null
                                ? CachedNetworkImageProvider(comment.avatarUrl!)
                                : null,
                            child: comment.avatarUrl == null
                                ? const Icon(Icons.person)
                                : null,
                          ),
                          title: Text(
                            comment.username ?? 'User',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(comment.content),
                              const SizedBox(height: 4),
                              Text(
                                timeago.format(comment.createdAt, locale: 'id'),
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      }, childCount: comments.length),
                    );
                  },
                  loading: () => const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, stack) => SliverToBoxAdapter(
                    child: Center(child: Text('Error: $error')),
                  ),
                ),
                const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(top: BorderSide(color: Colors.grey.shade800)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Tulis komentar...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade900,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _isSubmitting ? null : _submitComment,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            Icons.send_rounded,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
