import 'dart:async';
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

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        _performSearch(query);
      } else {
        setState(() {
          _searchResults = [];
        });
      }
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await ref.read(authRepositoryProvider).searchUsers(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mencari user: $e')));
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
                      // Back Button if not root (optional, but good for UX if navigated to)
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
                                  hintText: 'Cari pengguna...',
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

                // Results List
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : _searchResults.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                CupertinoIcons.person_2_square_stack,
                                size: 64,
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchController.text.isEmpty
                                    ? 'Temukan teman baru'
                                    : 'Tidak ada hasil ditemukan',
                                style: GoogleFonts.inter(color: Colors.white54),
                              ),
                            ],
                          ).animate().fadeIn(duration: 500.ms),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final user = _searchResults[index];
                            return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: BackdropFilter(
                                      filter: ui.ImageFilter.blur(
                                        sigmaX: 5,
                                        sigmaY: 5,
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.05,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          border: Border.all(
                                            color: Colors.white.withValues(
                                              alpha: 0.05,
                                            ),
                                          ),
                                        ),
                                        child: ListTile(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 8,
                                              ),
                                          leading: Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: LinearGradient(
                                                colors: [
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.secondary,
                                                ],
                                              ),
                                            ),
                                            padding: const EdgeInsets.all(2),
                                            child: CircleAvatar(
                                              radius: 24,
                                              backgroundColor: Colors.black,
                                              backgroundImage:
                                                  user['avatar_url'] != null
                                                  ? CachedNetworkImageProvider(
                                                      user['avatar_url'],
                                                    )
                                                  : null,
                                              child: user['avatar_url'] == null
                                                  ? const Icon(
                                                      CupertinoIcons
                                                          .person_fill,
                                                      color: Colors.white54,
                                                    )
                                                  : null,
                                            ),
                                          ),
                                          title: Text(
                                            user['username'] ?? 'User',
                                            style: GoogleFonts.outfit(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                          subtitle: user['bio'] != null
                                              ? Text(
                                                  user['bio'],
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                                            context.push(
                                              '/profile/${user['id']}',
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .animate(delay: (50 * index).ms)
                                .slideX(begin: 0.2, end: 0)
                                .fadeIn();
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
