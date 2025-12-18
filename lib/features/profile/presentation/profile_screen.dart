import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lvoapp/features/auth/data/auth_repository.dart';
import 'package:lvoapp/features/auth/domain/user_model.dart';
import 'package:lvoapp/features/feed/data/post_repository.dart';
import 'package:lvoapp/features/feed/domain/post_model.dart';
import 'package:lvoapp/features/moderation/data/moderation_repository.dart';

final profileProvider = FutureProvider.family<UserModel, String>((ref, userId) {
  return ref.watch(authRepositoryProvider).getProfile(userId);
});

final userPostsProvider = FutureProvider.family<List<PostModel>, String>((
  ref,
  userId,
) {
  return ref.watch(postRepositoryProvider).getUserPosts(userId);
});

class ProfileScreen extends ConsumerStatefulWidget {
  final String? userId;

  const ProfileScreen({super.key, this.userId});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isFollowingLoading = false;

  Future<void> _toggleFollow(String userId, bool isFollowing) async {
    setState(() {
      _isFollowingLoading = true;
    });

    try {
      if (isFollowing) {
        await ref.read(authRepositoryProvider).unfollowUser(userId);
      } else {
        await ref.read(authRepositoryProvider).followUser(userId);
      }
      ref.invalidate(profileProvider(userId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengubah status follow: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isFollowingLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = ref.watch(authRepositoryProvider).currentUser?.id;
    final targetUserId = widget.userId ?? currentUserId;

    if (targetUserId == null) {
      return const Scaffold(body: Center(child: Text('User tidak ditemukan')));
    }

    final profileState = ref.watch(profileProvider(targetUserId));
    final postsState = ref.watch(userPostsProvider(targetUserId));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.userId == null ? 'Profil Saya' : 'Profil',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (widget.userId != null && widget.userId != currentUserId)
            Consumer(
              builder: (context, ref, child) {
                return FutureBuilder<bool>(
                  future: ref
                      .watch(moderationRepositoryProvider)
                      .isUserBlocked(widget.userId!),
                  builder: (context, snapshot) {
                    final blocked = snapshot.data ?? false;
                    return IconButton(
                      onPressed: () async {
                        try {
                          if (blocked) {
                            await ref
                                .read(moderationRepositoryProvider)
                                .unblockUser(widget.userId!);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('User dibatalkan blokirnya'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } else {
                            await ref
                                .read(moderationRepositoryProvider)
                                .blockUser(widget.userId!);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('User diblokir'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            }
                          }
                          // Refresh profile to update state
                          ref.invalidate(profileProvider(widget.userId!));
                          // Also invalidate posts to filter out if blocked
                          ref.invalidate(userPostsProvider(widget.userId!));
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Gagal memperbarui status: $e'),
                              ),
                            );
                          }
                        }
                      },
                      icon: Icon(
                        blocked ? Icons.block : Icons.person_off_outlined,
                        color: blocked ? Colors.grey : Colors.red,
                      ),
                      tooltip: blocked ? 'Batal blokir' : 'Blokir user',
                    );
                  },
                );
              },
            ),
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Keluar Aplikasi'),
                  content: const Text('Apakah Anda yakin ingin keluar?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ref.read(authRepositoryProvider).signOut();
                      },
                      child: const Text(
                        'Keluar',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.logout_rounded, color: Colors.red),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(profileProvider(targetUserId));
          ref.invalidate(userPostsProvider(targetUserId));
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: profileState.when(
                data: (user) =>
                    _buildProfileHeader(context, user, currentUserId),
                loading: () => const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, stack) => Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Center(child: Text('Error: $error')),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(2.0),
              sliver: postsState.when(
                data: (posts) {
                  if (posts.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(
                          child: Text(
                            'Belum ada postingan',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    );
                  }
                  return SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 2,
                          mainAxisSpacing: 2,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final post = posts[index];
                      return GestureDetector(
                        onTap: () {
                          context.push('/post/${post.id}', extra: post);
                        },
                        child: CachedNetworkImage(
                          imageUrl: post.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              Container(color: Colors.grey.shade900),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey.shade900,
                            child: const Icon(Icons.error),
                          ),
                        ),
                      );
                    }, childCount: posts.length),
                  );
                },
                loading: () => const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
                error: (error, stack) => SliverToBoxAdapter(
                  child: Center(child: Text('Error: $error')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    UserModel user,
    String? currentUserId,
  ) {
    final isMe = currentUserId == user.id;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: user.avatarUrl != null
                    ? CachedNetworkImageProvider(user.avatarUrl!)
                    : null,
                child: user.avatarUrl == null
                    ? const Icon(Icons.person, size: 40)
                    : null,
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Postingan', '0'), // Placeholder for now
                    _buildStatItem('Pengikut', '${user.followersCount}'),
                    _buildStatItem('Mengikuti', '${user.followingCount}'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            user.username,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          if (user.bio != null && user.bio!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(user.bio!),
          ],
          const SizedBox(height: 16),
          if (isMe)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  context.push('/edit-profile', extra: user);
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade700),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Edit Profil',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isFollowingLoading
                          ? null
                          : () => _toggleFollow(user.id, user.isFollowing),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: user.isFollowing
                            ? Colors.grey.shade800
                            : Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isFollowingLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(user.isFollowing ? 'Mengikuti' : 'Ikuti'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        // Create or get chat
                        // We need a provider or repository access here
                        // For now, let's just push to a route that handles creation or check
                        // Or better, call createChat here.
                        // But we don't have ref here easily without Consumer.
                        // We are in a ConsumerState, so we have ref.

                        // We need to import ChatRepository
                        // Let's assume we will add the import
                        // But wait, I can't add import with replace_file_content easily if it's far away.
                        // I should use multi_replace to add import and button.

                        // For now, let's just navigate to a "create chat" route or similar?
                        // No, let's do it properly.

                        // I'll use context.push('/chat/create?userId=${user.id}') or similar?
                        // Or just push to chat room and let it handle creation?
                        // The ChatRoomScreen takes chatId.
                        // So we need to get chatId first.

                        // Let's add a loading state for this button too?
                        // Or just navigate to a generic /chat/user/:userId route that resolves the chat ID?
                        // That seems cleaner for UI.
                        context.push('/chat/user/${user.id}', extra: user);
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade700),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Pesan',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
