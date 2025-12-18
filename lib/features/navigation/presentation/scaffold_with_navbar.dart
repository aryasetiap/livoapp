import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lvoapp/features/chat/data/chat_repository.dart';
import 'package:lvoapp/features/notifications/data/notification_repository.dart';

final unreadCountsProvider = FutureProvider<Map<String, int>>((ref) async {
  final chatCount = await ref
      .watch(chatRepositoryProvider)
      .getTotalUnreadCount();
  final notifCount = await ref
      .watch(notificationRepositoryProvider)
      .getUnreadNotificationsCount();
  return {'chat': chatCount, 'notification': notifCount};
});

class ScaffoldWithNavBar extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({required this.navigationShell, Key? key})
    : super(key: key ?? const ValueKey<String>('ScaffoldWithNavBar'));

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCounts = ref.watch(unreadCountsProvider).valueOrNull ?? {};

    return Scaffold(
      extendBody:
          true, // Important for floating navbar to show content behind it
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(
                    alpha: 0.5,
                  ), // Semi-transparent black
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 0.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(
                        context,
                        index: 0,
                        icon: CupertinoIcons.house_fill,
                        label: 'Home',
                        isSelected: navigationShell.currentIndex == 0,
                      ),
                      _buildNavItem(
                        context,
                        index: 1,
                        icon: CupertinoIcons.compass,
                        label: 'Explore',
                        isSelected: navigationShell.currentIndex == 1,
                      ),
                      _buildCenterNavItem(context),
                      _buildNavItem(
                        context,
                        index: 3,
                        icon: CupertinoIcons.chat_bubble_2,
                        label: 'Chat',
                        isSelected: navigationShell.currentIndex == 3,
                        badgeCount: unreadCounts['chat'] ?? 0,
                      ),
                      _buildNavItem(
                        context,
                        index: 4,
                        icon: CupertinoIcons.person_crop_circle,
                        label: 'Profile',
                        isSelected: navigationShell.currentIndex == 4,
                        // Not showing notification badge on Profile standardly,
                        // but user asked for "Notifications/Chats tabs".
                        // Since Notifications is a top bar item in Home, logic might differ.
                        // I will leave Profile clean for now unless requested.
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
    int badgeCount = 0,
  }) {
    final color = isSelected
        ? Theme.of(context).colorScheme.primary
        : Colors.grey.withValues(alpha: 0.5);

    return InkWell(
      onTap: () => _goBranch(index),
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: color, size: 26)
                .animate(target: isSelected ? 1 : 0)
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.1, 1.1),
                  duration: 200.ms,
                  curve: Curves.easeOutBack,
                ),
          ),
          if (badgeCount > 0)
            Positioned(
              top: 0,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  badgeCount > 99 ? '99+' : badgeCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ).animate().scale(duration: 200.ms, curve: Curves.elasticOut),
            ),
        ],
      ),
    );
  }

  Widget _buildCenterNavItem(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/create-post'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 48,
        height: 48, // Slightly larger for emphasis
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(CupertinoIcons.add, color: Colors.white, size: 28),
      ).animate().scale(duration: 200.ms, curve: Curves.easeOutBack).fadeIn(),
    );
  }
}
