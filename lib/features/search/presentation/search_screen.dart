import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

import 'dart:convert';
import 'dart:io';

import 'package:lvoapp/features/feed/data/post_repository.dart';
import 'package:lvoapp/features/feed/domain/post_model.dart';
import 'package:lvoapp/features/feed/presentation/widgets/post_item.dart';
import 'package:path_provider/path_provider.dart';
import 'package:lvoapp/core/config/theme.dart';
import 'package:lvoapp/features/auth/data/auth_repository.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  late TabController _tabController;

  List<Map<String, dynamic>> _userResults = [];
  List<PostModel> _postResults = [];
  List<String> _recentSearches = [];
  List<Map<String, dynamic>> _suggestedUsers = [];

  bool _isLoading = false;
  Timer? _debounce;
  final String _recentSearchesFileName = 'recent_searches.json';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _loadRecentSearches();
    _loadSuggestedUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_searchController.text.isNotEmpty) {
      _performSearch(_searchController.text);
    }
  }

  Future<void> _loadRecentSearches() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_recentSearchesFileName');
      if (await file.exists()) {
        final content = await file.readAsString();
        final List<dynamic> jsonList = json.decode(content);
        setState(() {
          _recentSearches = jsonList.cast<String>();
        });
      }
    } catch (e) {
      debugPrint('Error loading recent searches: $e');
    }
  }

  Future<void> _saveRecentSearch(String query) async {
    if (query.isEmpty) return;
    if (!_recentSearches.contains(query)) {
      setState(() {
        _recentSearches.insert(0, query);
        if (_recentSearches.length > 10) _recentSearches.removeLast();
      });
      try {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$_recentSearchesFileName');
        await file.writeAsString(json.encode(_recentSearches));
      } catch (e) {
        debugPrint('Error saving recent search: $e');
      }
    }
  }

  Future<void> _clearRecentSearches() async {
    setState(() {
      _recentSearches.clear();
    });
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_recentSearchesFileName');
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Error creating recent search: $e');
    }
  }

  Future<void> _loadSuggestedUsers() async {
    // For now, search empty string to get some users or implement getSuggestedUsers
    try {
      final results = await ref.read(authRepositoryProvider).searchUsers('');
      if (mounted) {
        setState(() {
          _suggestedUsers = results;
        });
      }
    } catch (e) {
      // Ignore
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        _performSearch(query);
      } else {
        setState(() {
          _userResults = [];
          _postResults = [];
        });
      }
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_tabController.index == 0) {
        // Users
        final results = await ref
            .read(authRepositoryProvider)
            .searchUsers(query);
        if (mounted) {
          setState(() {
            _userResults = results;
          });
        }
      } else if (_tabController.index == 1) {
        // Posts
        final results = await ref
            .read(postRepositoryProvider)
            .searchPosts(query);
        if (mounted) {
          setState(() {
            _postResults = results;
          });
        }
      } else {
        // Tags - reuse posts search for now but filter by hash?
        // simple implementation: just search posts containing the query #query
        final results = await ref
            .read(postRepositoryProvider)
            .searchPosts('#$query');
        if (mounted) {
          setState(() {
            _postResults = results;
          });
        }
      }

      _saveRecentSearch(query);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Pencarian gagal: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
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

          // 2. Animated Orbs
          Positioned(
            top: -50,
            right: -50,
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
          Positioned(
            bottom: 100,
            left: -50,
            child:
                ImageFiltered(
                      imageFilter: ui.ImageFilter.blur(sigmaX: 80, sigmaY: 80),
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
                    .scale(
                      begin: const Offset(1.2, 1.2),
                      end: const Offset(1, 1),
                      duration: 7.seconds,
                    ),
          ),

          // 3. Content
          SafeArea(
            child: Column(
              children: [
                // Header & Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    children: [
                      if (context.canPop())
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: IconButton(
                            icon: const Icon(
                              CupertinoIcons.back,
                              color: Colors.white,
                            ),
                            onPressed: () => context.pop(),
                          ),
                        ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.1),
                                ),
                              ),
                              child: TextField(
                                controller: _searchController,
                                onChanged: _onSearchChanged,
                                autofocus: false,
                                style: GoogleFonts.inter(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Cari sesuatu...',
                                  hintStyle: GoogleFonts.inter(
                                    color: Colors.white54,
                                  ),
                                  border: InputBorder.none,
                                  prefixIcon: const Icon(
                                    CupertinoIcons.search,
                                    color: Colors.white54,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Tabs
                Theme(
                  data: ThemeData(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: Theme.of(context).colorScheme.primary,
                    indicatorWeight: 3,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white54,
                    labelStyle: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    unselectedLabelStyle: GoogleFonts.outfit(fontSize: 14),
                    tabs: const [
                      Tab(text: 'Akun'),
                      Tab(text: 'Postingan'),
                      Tab(text: 'Tagar'),
                    ],
                  ),
                ),

                // Results
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            _buildUserTab(),
                            _buildPostTab(),
                            _buildPostTab(), // Reuse for tags
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTab() {
    if (_searchController.text.isEmpty) {
      return _buildRecentAndSuggested();
    }
    return _buildUserList(_userResults);
  }

  Widget _buildPostTab() {
    if (_searchController.text.isEmpty) {
      return _buildRecentAndSuggested();
    }
    if (_postResults.isEmpty) {
      return Center(
        child: Text(
          'Tidak ada postingan ditemukan',
          style: GoogleFonts.inter(color: Colors.white54),
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: _postResults.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: PostItem(post: _postResults[index]),
        );
      },
    );
  }

  Widget _buildRecentAndSuggested() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Terakhir Dicari',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                GestureDetector(
                  onTap: _clearRecentSearches,
                  child: Text(
                    'Hapus Semua',
                    style: GoogleFonts.inter(
                      color: Colors.blueAccent,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildRecentSearches(),
            const SizedBox(height: 24),
          ],

          Text(
            'Disarankan untuk Anda',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          _buildUserList(_suggestedUsers, shrinkWrap: true),
        ],
      ),
    );
  }

  Widget _buildRecentSearches() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _recentSearches.map((search) {
        return GestureDetector(
          onTap: () {
            _searchController.text = search;
            _handleTabSelection(); // Trigger search
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  CupertinoIcons.time,
                  color: Colors.white54,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(search, style: GoogleFonts.inter(color: Colors.white)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildUserList(
    List<Map<String, dynamic>> users, {
    bool shrinkWrap = false,
  }) {
    if (users.isEmpty) {
      if (shrinkWrap) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Belum ada saran saat ini.',
            style: GoogleFonts.inter(color: Colors.white30, fontSize: 13),
          ),
        );
      }
      return Center(
        child: Text(
          'Tidak ada pengguna ditemukan',
          style: GoogleFonts.inter(color: Colors.white54),
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: shrinkWrap,
      physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.black,
                    backgroundImage: user['avatar_url'] != null
                        ? CachedNetworkImageProvider(user['avatar_url'])
                        : null,
                    child: user['avatar_url'] == null
                        ? const Icon(
                            CupertinoIcons.person_fill,
                            color: Colors.white54,
                          )
                        : null,
                  ),
                  title: Text(
                    user['username'] ?? 'User',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  subtitle:
                      user['full_name'] !=
                          null // Changed to full_name (db column)
                      ? Text(
                          user['full_name'],
                          style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        )
                      : null,
                  trailing: const Icon(
                    CupertinoIcons.chevron_right,
                    color: Colors.white30,
                    size: 20,
                  ),
                  onTap: () {
                    context.push('/profile/${user['id']}');
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
