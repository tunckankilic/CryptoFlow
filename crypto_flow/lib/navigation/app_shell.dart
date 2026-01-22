import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// App shell with bottom navigation
class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateSelectedIndex(context),
        onDestinationSelected: (index) =>
            _onDestinationSelected(index, context),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.show_chart),
            selectedIcon: Icon(Icons.show_chart, color: Colors.blue),
            label: 'Markets',
          ),
          NavigationDestination(
            icon: Icon(Icons.star_border),
            selectedIcon: Icon(Icons.star, color: Colors.amber),
            label: 'Watchlist',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon:
                Icon(Icons.account_balance_wallet, color: Colors.green),
            label: 'Portfolio',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon:
                Icon(Icons.notifications_active, color: Colors.orange),
            label: 'Alerts',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings, color: Colors.grey),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    if (location.startsWith('/settings')) return 4;
    if (location.startsWith('/alerts')) return 3;
    if (location.startsWith('/portfolio')) return 2;
    if (location.startsWith('/watchlist')) return 1;
    return 0; // Markets is default
  }

  void _onDestinationSelected(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/watchlist');
        break;
      case 2:
        context.go('/portfolio');
        break;
      case 3:
        context.go('/alerts');
        break;
      case 4:
        context.go('/settings');
        break;
    }
  }
}
