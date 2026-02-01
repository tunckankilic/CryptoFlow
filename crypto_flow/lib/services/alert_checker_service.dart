import 'dart:async';
import 'package:market/market.dart';
import 'package:alerts/alerts.dart';
import 'package:notifications/notifications.dart';

/// Service to check price alerts in background
class AlertCheckerService {
  final MarketRepository _marketRepository;
  final AlertRepository _alertRepository;
  final NotificationRepository _notificationRepository;

  Timer? _timer;
  bool _isChecking = false;

  AlertCheckerService({
    required MarketRepository marketRepository,
    required AlertRepository alertRepository,
    required NotificationRepository notificationRepository,
  })  : _marketRepository = marketRepository,
        _alertRepository = alertRepository,
        _notificationRepository = notificationRepository;

  /// Start checking alerts periodically
  void startChecking({Duration interval = const Duration(seconds: 30)}) {
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) => checkAlerts());
  }

  /// Stop checking alerts
  void stopChecking() {
    _timer?.cancel();
    _timer = null;
  }

  /// Check all alerts against current prices
  Future<void> checkAlerts() async {
    if (_isChecking) return; // Prevent concurrent checks
    _isChecking = true;

    try {
      // Get all active alerts
      final alertsResult = await _alertRepository.getAlerts();
      await alertsResult.fold(
        (failure) async {
          // Log error but don't stop service
        },
        (alerts) async {
          if (alerts.isEmpty) return;

          // Get unique symbols from active alerts
          final symbols = alerts
              .where((alert) => alert.isActive && !alert.isTriggered)
              .map((alert) => alert.symbol)
              .toSet()
              .toList();

          if (symbols.isEmpty) return;

          // Get current prices for all symbols
          final currentPrices = <String, double>{};
          for (final symbol in symbols) {
            final priceResult = await _marketRepository.getTicker(symbol);
            priceResult.fold(
              (failure) {
                // Skip this symbol if price fetch fails
              },
              (ticker) {
                currentPrices[symbol] = ticker.price;
              },
            );
          }

          // Check each alert
          for (final alert in alerts) {
            if (!alert.isActive || alert.isTriggered) continue;

            final currentPrice = currentPrices[alert.symbol];
            if (currentPrice == null) continue;

            // Check if alert should trigger
            if (alert.shouldTrigger(currentPrice)) {
              // Send notification if enabled
              if (alert.notificationEnabled && alert.pushEnabled) {
                await _notificationRepository.showPriceAlertNotification(
                  symbol: alert.symbol,
                  currentPrice: currentPrice,
                  targetPrice: alert.targetPrice,
                  alertType: alert.type.displayName,
                );
              }

              // Mark alert as triggered
              final triggeredAlert = alert.trigger();
              await _alertRepository.updateAlert(triggeredAlert);
            }
          }
        },
      );
    } finally {
      _isChecking = false;
    }
  }

  /// Dispose resources
  void dispose() {
    stopChecking();
  }
}
