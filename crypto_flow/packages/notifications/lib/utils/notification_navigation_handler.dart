import '../domain/entities/app_notification.dart';

/// Navigation action to be performed
class NavigationAction {
  final String route;
  final bool isPush; // true for push, false for go/replace

  const NavigationAction({
    required this.route,
    this.isPush = false,
  });
}

/// Handles navigation when a notification is tapped
class NotificationNavigationHandler {
  /// Get the navigation action based on notification type and data
  static NavigationAction? getNavigationAction(AppNotification notification) {
    final data = notification.data ?? {};

    switch (notification.type) {
      case NotificationType.priceAlert:
        return _getPriceAlertAction(data);
      case NotificationType.portfolioChange:
        return _getPortfolioChangeAction(data);
      case NotificationType.news:
        return _getNewsAction(data);
      case NotificationType.marketUpdate:
        return _getMarketUpdateAction(data);
      case NotificationType.system:
        return _getSystemAction(data);
    }
  }

  /// Handle price alert notification - navigate to ticker detail
  static NavigationAction? _getPriceAlertAction(Map<String, dynamic> data) {
    final symbol = data['symbol'] as String?;
    if (symbol != null && symbol.isNotEmpty) {
      return NavigationAction(route: '/ticker/$symbol', isPush: true);
    } else {
      // If no symbol, navigate to alerts page
      return const NavigationAction(route: '/alerts', isPush: false);
    }
  }

  /// Handle portfolio change notification - navigate to portfolio
  static NavigationAction? _getPortfolioChangeAction(
      Map<String, dynamic> data) {
    final symbol = data['symbol'] as String?;

    if (symbol != null && symbol.isNotEmpty) {
      // Navigate to ticker detail for the specific asset
      return NavigationAction(route: '/ticker/$symbol', isPush: true);
    } else {
      // Navigate to portfolio page
      return const NavigationAction(route: '/portfolio', isPush: false);
    }
  }

  /// Handle news notification - navigate to ticker detail or markets
  static NavigationAction? _getNewsAction(Map<String, dynamic> data) {
    final symbol = data['symbol'] as String?;
    final url = data['url'] as String?;

    if (symbol != null && symbol.isNotEmpty) {
      // Navigate to ticker detail where news might be displayed
      return NavigationAction(route: '/ticker/$symbol', isPush: true);
    } else if (url != null && url.isNotEmpty) {
      // Could open external URL in the future
      // For now, navigate to markets page
      return const NavigationAction(route: '/', isPush: false);
    } else {
      // Default to markets page
      return const NavigationAction(route: '/', isPush: false);
    }
  }

  /// Handle market update notification - navigate to markets or specific ticker
  static NavigationAction? _getMarketUpdateAction(Map<String, dynamic> data) {
    final symbol = data['symbol'] as String?;

    if (symbol != null && symbol.isNotEmpty) {
      return NavigationAction(route: '/ticker/$symbol', isPush: true);
    } else {
      // Navigate to markets page
      return const NavigationAction(route: '/', isPush: false);
    }
  }

  /// Handle system notification - navigate to settings
  static NavigationAction? _getSystemAction(Map<String, dynamic> data) {
    final route = data['route'] as String?;

    if (route != null && route.isNotEmpty) {
      // Navigate to specific route if provided
      return NavigationAction(route: route, isPush: false);
    } else {
      // Default to settings page
      return const NavigationAction(route: '/settings', isPush: false);
    }
  }
}
