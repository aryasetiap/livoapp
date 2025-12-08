import 'dart:ui' as ui;
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
      imageUrl: 'assets/images/waving_hand.png',
      fallbackIcon: Icons.waving_hand_rounded,
    ),
    OnboardingItem(
      title: 'Ekspresikan Dirimu',
      description:
          'Posting foto, video, dan cerita serumu. Biar dunia tau betapa kerennya kamu!',
      imageUrl: 'assets/images/camera.png',
      fallbackIcon: Icons.camera_alt_rounded,
    ),
    OnboardingItem(
      title: 'Jelajahi Tanpa Batas',
      description:
          'Temukan konten inspiratif dan kreator favoritmu. Gabung komunitas yang asik!',
      imageUrl: 'assets/images/rocket.png',
      fallbackIcon: Icons.explore_rounded,
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
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Elements
          Positioned(
            top: -100,
            right: -100,
            child: ImageFiltered(
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
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: ImageFiltered(
              imageFilter: ui.ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(
                    context,
                  ).colorScheme.secondary.withValues(alpha: 0.15),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Skip Button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16, top: 8),
                    child: TextButton(
                      onPressed: () => context.go('/login'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white60,
                      ),
                      child: const Text('Lewati'),
                    ),
                  ),
                ),

                // Main Content
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
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 3D Image Area
                          Expanded(
                            flex: 3,
                            child: Center(
                              child: Container(
                                width: 280,
                                height: 280,
                                margin: const EdgeInsets.only(bottom: 20),
                                child:
                                    Image.asset(
                                          item.imageUrl,
                                          fit: BoxFit.contain,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return Icon(
                                                  item.fallbackIcon,
                                                  size: 150,
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                                );
                                              },
                                        )
                                        .animate(
                                          onPlay: (controller) =>
                                              controller.repeat(reverse: true),
                                        )
                                        .moveY(
                                          begin: -10,
                                          end: 10,
                                          duration: 2000.ms,
                                          curve: Curves.easeInOutSine,
                                        ) // Floating effect
                                        .animate() // Entry animation
                                        .scale(
                                          duration: 600.ms,
                                          curve: Curves.easeOutBack,
                                        )
                                        .fadeIn(duration: 400.ms),
                              ),
                            ),
                          ),

                          // Text Content Area
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                              ),
                              decoration: const BoxDecoration(
                                color: Colors.transparent,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                        item.title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                              height: 1.2,
                                            ),
                                        textAlign: TextAlign.center,
                                      )
                                      .animate()
                                      .slideY(
                                        begin: 0.2,
                                        end: 0,
                                        duration: 600.ms,
                                        curve: Curves.easeOut,
                                      )
                                      .fadeIn(),
                                  const SizedBox(height: 16),
                                  Text(
                                        item.description,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              color: Colors.grey[400],
                                              height: 1.5,
                                              fontSize: 16,
                                            ),
                                        textAlign: TextAlign.center,
                                      )
                                      .animate()
                                      .slideY(
                                        begin: 0.2,
                                        end: 0,
                                        duration: 600.ms,
                                        delay: 100.ms,
                                        curve: Curves.easeOut,
                                      )
                                      .fadeIn(delay: 100.ms),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // Bottom Controls
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 48),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SmoothPageIndicator(
                        controller: _pageController,
                        count: _items.length,
                        effect: ExpandingDotsEffect(
                          activeDotColor: Theme.of(context).colorScheme.primary,
                          dotColor: Colors.white24,
                          dotHeight: 8,
                          dotWidth: 8,
                          spacing: 6,
                          expansionFactor: 4,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(
                                context,
                              ).colorScheme.tertiary, // Fun gradient
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            if (_isLastPage) {
                              context.go('/login');
                            } else {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOutCubic,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            minimumSize: const Size(120, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                _isLastPage ? 'Mulai' : 'Lanjut',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              if (!_isLastPage) ...[
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
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
}

class OnboardingItem {
  final String title;
  final String description;
  final String imageUrl;
  final IconData fallbackIcon;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.fallbackIcon,
  });
}
