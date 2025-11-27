import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:livoapp/features/auth/presentation/auth_controller.dart';
import 'package:livoapp/features/feed/data/post_repository.dart';
import 'package:livoapp/features/feed/domain/post_model.dart';
import 'package:livoapp/features/feed/presentation/widgets/post_item.dart';

final feedControllerProvider =
    StateNotifierProvider<FeedController, AsyncValue<List<PostModel>>>((ref) {
      return FeedController(ref.watch(postRepositoryProvider));
    });

class FeedController extends StateNotifier<AsyncValue<List<PostModel>>> {
  final PostRepository _repository;
  int _page = 0;
  final int _limit = 10;
  bool _hasMore = true;

  FeedController(this._repository) : super(const AsyncValue.loading()) {
    loadInitialPosts();
  }

  Future<void> loadInitialPosts() async {
    try {
      _page = 0;
      _hasMore = true;
      state = const AsyncValue.loading();
      final posts = await _repository.getPosts(page: _page, limit: _limit);
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
      final newPosts = await _repository.getPosts(page: _page, limit: _limit);

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

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Theme.of(context).colorScheme.surface, Colors.black],
          ),
        ),
        child: RefreshIndicator(
          onRefresh: () async =>
              ref.read(feedControllerProvider.notifier).refresh(),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                floating: true,
                snap: true,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surface.withValues(alpha: 0.8),
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/livo_logo_square.png',
                      height: 32,
                      width: 32,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.image_not_supported_rounded,
                          color: Theme.of(context).colorScheme.primary,
                          size: 32,
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Livo',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 28,
                        color: Theme.of(context).colorScheme.primary,
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_none_rounded),
                  ),
                  IconButton(
                    onPressed: () {
                      ref.read(authControllerProvider.notifier).signOut();
                      context.go('/login');
                    },
                    icon: const Icon(Icons.logout_rounded),
                  ),
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
                                child: CircleAvatar(
                                  radius: 30,
                                  backgroundImage: NetworkImage(
                                    'https://i.pravatar.cc/150?u=story$index',
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
                    child: Text(
                      'Error: $error',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
            ],
          ),
        ),
      ),
    );
  }
}
