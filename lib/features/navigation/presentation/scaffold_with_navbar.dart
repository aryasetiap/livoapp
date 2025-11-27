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
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
          border: Border(
            top: BorderSide(
              color: Colors.white.withValues(alpha: 0.1),
              width: 0.5,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _goBranch,
          backgroundColor: Colors.transparent,
          indicatorColor: Colors.transparent,
          elevation: 0,
          height: 65,
          destinations: [
            _buildNavItem(
              context,
              icon: Icons.home_outlined,
              selectedIcon: Icons.home_rounded,
              label: 'Home',
              isSelected: navigationShell.currentIndex == 0,
            ),
            _buildNavItem(
              context,
              icon: Icons.explore_outlined,
              selectedIcon: Icons.explore_rounded,
              label: 'Explore',
              isSelected: navigationShell.currentIndex == 1,
            ),
            _buildCenterNavItem(context),
            _buildNavItem(
              context,
              icon: Icons.favorite_border_rounded,
              selectedIcon: Icons.favorite_rounded,
              label: 'Activity',
              isSelected: navigationShell.currentIndex == 3,
            ),
            _buildNavItem(
              context,
              icon: Icons.person_outline_rounded,
              selectedIcon: Icons.person_rounded,
              label: 'Profile',
              isSelected: navigationShell.currentIndex == 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required bool isSelected,
  }) {
    final color = isSelected
        ? Theme.of(context).colorScheme.primary
        : Colors.grey.shade500;

    return NavigationDestination(
      icon: Icon(icon, color: color)
          .animate(target: isSelected ? 1 : 0)
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.1, 1.1),
            duration: 200.ms,
            curve: Curves.easeOutBack,
          ),
      selectedIcon: Icon(
        selectedIcon,
        color: color,
      ).animate().scale(duration: 200.ms, curve: Curves.easeOutBack).fadeIn(),
      label: label,
    );
  }

  Widget _buildCenterNavItem(BuildContext context) {
    return NavigationDestination(
      icon: Container(
        width: 48,
        height: 32,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
      ),
      label: '',
    );
  }
}
