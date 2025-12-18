import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lvoapp/features/auth/data/auth_repository.dart'; // Added import

import 'dart:ui' as ui;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lvoapp/features/feed/data/post_repository.dart';
import 'package:lvoapp/features/feed/domain/post_model.dart';
import 'package:lvoapp/features/feed/presentation/widgets/post_item.dart';
import '../../../../core/config/theme.dart';

enum FeedMode { global, following }

final feedModeProvider = StateProvider<FeedMode>((ref) => FeedMode.global);

final feedControllerProvider =
    StateNotifierProvider<FeedController, AsyncValue<List<PostModel>>>((ref) {
      final mode = ref.watch(feedModeProvider);
      return FeedController(
        ref.watch(postRepositoryProvider),
        ref.watch(authRepositoryProvider),
        mode,
      );
    });

class FeedController extends StateNotifier<AsyncValue<List<PostModel>>> {
  final PostRepository _postRepository;
  final AuthRepository _authRepository;
  final FeedMode _mode;
  int _page = 0;
  final int _limit = 10;
  bool _hasMore = true;

  FeedController(this._postRepository, this._authRepository, this._mode)
    : super(const AsyncValue.loading()) {
    loadInitialPosts();
  }

  Future<void> loadInitialPosts() async {
    try {
      _page = 0;
      _hasMore = true;
      state = const AsyncValue.loading();

      List<String>? filterUserIds;
      if (_mode == FeedMode.following) {
        filterUserIds = await _authRepository.getFollowedUserIds();
        if (filterUserIds.isEmpty) {
          // If following no one, return empty list immediately
          state = const AsyncValue.data([]);
          _hasMore = false;
          return;
        }
      }

      final posts = await _postRepository.getPosts(
        page: _page,
        limit: _limit,
        filterUserIds: filterUserIds,
      );
      state = AsyncValue.data(posts);
      if (posts.length < _limit) _hasMore = false;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadMorePosts() async {
    if (!_hasMore || state.isLoading || state.isRefreshing) return;

    try {
      _page++;
      final currentPosts = state.value ?? [];

      List<String>? filterUserIds;
      if (_mode == FeedMode.following) {
        filterUserIds = await _authRepository.getFollowedUserIds();
        if (filterUserIds.isEmpty) {
          _hasMore = false;
          return;
        }
      }

      final newPosts = await _postRepository.getPosts(
        page: _page,
        limit: _limit,
        filterUserIds: filterUserIds,
      );

      if (newPosts.isEmpty) {
        _hasMore = false;
      } else {
        state = AsyncValue.data([...currentPosts, ...newPosts]);
        if (newPosts.length < _limit) _hasMore = false;
      }
    } catch (e) {
      // Handle error silently or show snackbar in UI
      _hasMore = false;
    }
  }

  Future<void> refresh() async {
    await loadInitialPosts();
  }
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(feedControllerProvider.notifier).loadMorePosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(feedControllerProvider);
    final feedMode = ref.watch(feedModeProvider);

    return Scaffold(
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
            left: -100,
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
                          ).colorScheme.primary.withValues(alpha: 0.3),
                        ),
                      ),
                    )
                    .animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                    )
                    .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.2, 1.2),
                      duration: 4.seconds,
                    ),
          ),
          Positioned(
            bottom: 200,
            right: -50,
            child:
                ImageFiltered(
                      imageFilter: ui.ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(
                            context,
                          ).colorScheme.secondary.withValues(alpha: 0.2),
                        ),
                      ),
                    )
                    .animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                    )
                    .moveY(begin: 0, end: 30, duration: 5.seconds),
          ),

          // 3. Content
          RefreshIndicator(
            color: AppTheme.primaryColor,
            backgroundColor: AppTheme.surfaceColor,
            onRefresh: () async =>
                ref.read(feedControllerProvider.notifier).refresh(),
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverAppBar(
                  floating: true,
                  snap: true,
                  pinned: true, // Keep it pinned for better UX
                  backgroundColor:
                      Colors.transparent, // Transparent for glassmorphism
                  flexibleSpace: ClipRRect(
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        color: Theme.of(
                          context,
                        ).colorScheme.surface.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  title: Row(
                    children: [
                      Image.asset(
                        'assets/images/lvo_logo_square.png',
                        height: 32,
                        width: 32,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'LVO',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    IconButton(
                      onPressed: () {
                        context.push('/notifications');
                      },
                      icon: const Icon(Icons.notifications_outlined, size: 28),
                    ),
                    const SizedBox(width: 8), // Add some spacing at the end
                  ],
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 110,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: 10,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(3),
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
                                child: CircleAvatar(
                                  radius: 32,
                                  backgroundColor: Colors.black,
                                  child: ClipOval(
                                    child: Image.network(
                                      'https://i.pravatar.cc/150?u=story$index',
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              width: 60,
                                              height: 60,
                                              color: Colors.grey[800],
                                              child: const Icon(
                                                Icons.person_off,
                                                color: Colors.white54,
                                              ),
                                            );
                                          },
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'User $index',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Stack(
                        children: [
                          AnimatedAlign(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutBack,
                            alignment: feedMode == FeedMode.global
                                ? Alignment.centerLeft
                                : Alignment.centerRight,
                            child: FractionallySizedBox(
                              widthFactor: 0.5,
                              child: Container(
                                margin: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(21),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      ref
                                              .read(feedModeProvider.notifier)
                                              .state =
                                          FeedMode.global,
                                  behavior: HitTestBehavior.opaque,
                                  child: Center(
                                    child: Text(
                                      'Global',
                                      style: TextStyle(
                                        color: feedMode == FeedMode.global
                                            ? Colors.white
                                            : Colors.grey,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      ref
                                              .read(feedModeProvider.notifier)
                                              .state =
                                          FeedMode.following,
                                  behavior: HitTestBehavior.opaque,
                                  child: Center(
                                    child: Text(
                                      'Mengikuti',
                                      style: TextStyle(
                                        color: feedMode == FeedMode.following
                                            ? Colors.white
                                            : Colors.grey,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                feedState.when(
                  data: (posts) {
                    if (posts.isEmpty) {
                      return const SliverFillRemaining(
                        child: Center(
                          child: Text(
                            'Belum ada postingan.\nJadilah yang pertama memposting!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      );
                    }
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index == posts.length) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          return PostItem(post: posts[index]);
                        },
                        childCount: posts.length + 1,
                      ), // +1 for loading indicator
                    );
                  },
                  loading: () => const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, stack) => SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_off_rounded,
                            size: 64,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Gagal memuat postingan',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Periksa koneksi internet Anda',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                          ),
                          const SizedBox(height: 24),
                          FilledButton.icon(
                            onPressed: () {
                              ref
                                  .read(feedControllerProvider.notifier)
                                  .refresh();
                            },
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
