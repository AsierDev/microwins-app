import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({required this.navigationShell, Key? key})
    : super(key: key ?? const ValueKey<String>('ScaffoldWithNavBar'));

  void _goBranch(int index) {
    navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        destinations: const [
          NavigationDestination(
            label: 'Home',
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
          ),
          NavigationDestination(
            label: 'Progress',
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
          ),
          NavigationDestination(
            label: 'Discover',
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
          ),
          NavigationDestination(
            label: 'Profile',
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
          ),
        ],
        onDestinationSelected: _goBranch,
      ),
    );
  }
}
