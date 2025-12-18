import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:lvoapp/core/config/theme.dart';
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Theme.of(
                context,
              ).colorScheme.surface.withValues(alpha: 0.5),
            ),
          ),
        ),
        title: Text(
          widget.userId == null ? 'Profil Saya' : 'Profil',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
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
                        blocked
                            ? CupertinoIcons.nosign
                            : CupertinoIcons.person_crop_circle_badge_exclam,
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
                  backgroundColor: const Color(
                    0xFF1E1E2E,
                  ), // Custom dark dialog
                  title: Text(
                    'Keluar Aplikasi',
                    style: GoogleFonts.outfit(color: Colors.white),
                  ),
                  content: Text(
                    'Apakah Anda yakin ingin keluar?',
                    style: GoogleFonts.inter(color: Colors.white70),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Batal',
                        style: GoogleFonts.inter(color: Colors.white54),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ref.read(authRepositoryProvider).signOut();
                      },
                      child: Text(
                        'Keluar',
                        style: GoogleFonts.inter(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(
              CupertinoIcons.square_arrow_right,
              color: Colors.red,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. Background Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.backgroundColor,
                    Color(0xFF1A1A2E), // Deep Dark Blue
                    Color(0xFF2D1B4E), // Deep Purple
                    Colors.black,
                  ],
                  stops: [0.0, 0.4, 0.7, 1.0],
                ),
              ),
            ),
          ),

          // 2. Ambient Orbs (Animated)
          Positioned(
            top: -100,
            left: -50,
            child:
                ImageFiltered(
                      imageFilter: ui.ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.2),
                        ),
                      ),
                    )
                    .animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                    )
                    .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.2, 1.2),
                      duration: 6.seconds,
                    ),
          ),

          // 3. Content
          RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(profileProvider(targetUserId));
              ref.invalidate(userPostsProvider(targetUserId));
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: MediaQuery.of(context).padding.top + kToolbarHeight,
                  ),
                ),
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
                      child: Center(
                        child: Text(
                          'Error: $error',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(2.0),
                  sliver: postsState.when(
                    data: (posts) {
                      if (posts.isEmpty) {
                        return SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    CupertinoIcons.camera,
                                    size: 48,
                                    color: Colors.white.withValues(alpha: 0.2),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Belum ada postingan',
                                    style: GoogleFonts.inter(
                                      color: Colors.white54,
                                    ),
                                  ),
                                ],
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
                            child: Hero(
                              tag: 'post_${post.id}',
                              child: CachedNetworkImage(
                                imageUrl: post.imageUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.white.withValues(alpha: 0.05),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  child: const Icon(
                                    CupertinoIcons.exclamationmark_triangle,
                                    color: Colors.white30,
                                  ),
                                ),
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
                      child: Center(
                        child: Text(
                          'Error: $error',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                  ),
                ),
                const SliverPadding(
                  padding: EdgeInsets.only(bottom: 80),
                ), // Bottom padding for FAB/Nav
              ],
            ),
          ),
        ],
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
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(3),
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.black,
                  backgroundImage: user.avatarUrl != null
                      ? CachedNetworkImageProvider(user.avatarUrl!)
                      : null,
                  child: user.avatarUrl == null
                      ? const Icon(
                          CupertinoIcons.person_fill,
                          size: 40,
                          color: Colors.white54,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // _buildStatItem('Postingan', '0'), // Removed placeholder
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
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          if (user.bio != null && user.bio!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              user.bio!,
              style: GoogleFonts.inter(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 14,
              ),
            ),
          ],
          const SizedBox(height: 24),
          if (isMe)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  context.push('/edit-profile', extra: user);
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                  backgroundColor: Colors.white.withValues(alpha: 0.05),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  'Edit Profil',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
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
                            ? Colors.white.withValues(alpha: 0.1)
                            : Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: _isFollowingLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              user.isFollowing ? 'Mengikuti' : 'Ikuti',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        context.push('/chat/user/${user.id}', extra: user);
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        backgroundColor: Colors.white.withValues(alpha: 0.05),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Pesan',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
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
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(color: Colors.white54, fontSize: 13),
        ),
      ],
    );
  }
}
