import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

class ScaffoldWithNavBar extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody:
          true, // Important for floating navbar to show content behind it
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context,
                  index: 0,
                  icon: Icons.grid_view_rounded,
                  label: 'Home',
                  isSelected: navigationShell.currentIndex == 0,
                ),
                _buildNavItem(
                  context,
                  index: 1,
                  icon: Icons.explore_rounded,
                  label: 'Explore',
                  isSelected: navigationShell.currentIndex == 1,
                ),
                _buildCenterNavItem(context),
                _buildNavItem(
                  context,
                  index: 3,
                  icon: Icons.chat_bubble_rounded,
                  label: 'Chat',
                  isSelected: navigationShell.currentIndex == 3,
                ),
                _buildNavItem(
                  context,
                  index: 4,
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  isSelected: navigationShell.currentIndex == 4,
                ),
              ],
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
  }) {
    final color = isSelected
        ? Theme.of(context).colorScheme.primary
        : Colors.grey.withValues(alpha: 0.5);

    return InkWell(
      onTap: () => _goBranch(index),
      borderRadius: BorderRadius.circular(20),
      child: Container(
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
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ).animate().scale(duration: 200.ms, curve: Curves.easeOutBack).fadeIn(),
    );
  }
}
