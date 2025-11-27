import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  bool _isLastPage = false;

  final List<OnboardingItem> _items = [
    OnboardingItem(
      title: 'Selamat Datang di Livo',
      description:
          'Tempat seru buat nongkrong dan berbagi momen kece bareng temen-temen baru.',
      icon: Icons.waving_hand_rounded,
    ),
    OnboardingItem(
      title: 'Ekspresikan Dirimu',
      description:
          'Posting foto, video, dan cerita serumu. Biar dunia tau betapa kerennya kamu!',
      icon: Icons.camera_alt_rounded,
    ),
    OnboardingItem(
      title: 'Jelajahi Tanpa Batas',
      description:
          'Temukan konten inspiratif dan kreator favoritmu. Gabung komunitas yang asik!',
      icon: Icons.explore_rounded,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF000000), // Black
              Color(0xFF1F2937), // Dark Gray
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Lewati'),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _isLastPage = index == _items.length - 1;
                    });
                  },
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                                padding: const EdgeInsets.all(32),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  item.icon,
                                  size: 100,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              )
                              .animate()
                              .scale(
                                duration: 600.ms,
                                curve: Curves.easeOutBack,
                              )
                              .fadeIn(duration: 600.ms),
                          const SizedBox(height: 48),
                          Text(
                                item.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                textAlign: TextAlign.center,
                              )
                              .animate()
                              .slideY(
                                begin: 0.3,
                                end: 0,
                                duration: 600.ms,
                                delay: 200.ms,
                                curve: Curves.easeOut,
                              )
                              .fadeIn(duration: 600.ms, delay: 200.ms),
                          const SizedBox(height: 16),
                          Text(
                                item.description,
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(color: Colors.grey),
                                textAlign: TextAlign.center,
                              )
                              .animate()
                              .slideY(
                                begin: 0.3,
                                end: 0,
                                duration: 600.ms,
                                delay: 400.ms,
                                curve: Curves.easeOut,
                              )
                              .fadeIn(duration: 600.ms, delay: 400.ms),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SmoothPageIndicator(
                      controller: _pageController,
                      count: _items.length,
                      effect: ExpandingDotsEffect(
                        activeDotColor: Theme.of(context).colorScheme.primary,
                        dotColor: Colors.grey.shade800,
                        dotHeight: 8,
                        dotWidth: 8,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_isLastPage) {
                          context.go('/login');
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        minimumSize: const Size(
                          120,
                          50,
                        ), // Override infinite width
                      ),
                      child: Text(_isLastPage ? 'Mulai' : 'Lanjut'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingItem {
  final String title;
  final String description;
  final IconData icon;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.icon,
  });
}
