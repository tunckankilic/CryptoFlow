import 'package:equatable/equatable.dart';
import '../../domain/entities/app_notification.dart';

/// Base class for notification events
abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

/// Initialize notifications
class InitializeNotificationsEvent extends NotificationEvent {
  const InitializeNotificationsEvent();
}

/// Request notification permission
class RequestPermissionEvent extends NotificationEvent {
  const RequestPermissionEvent();
}

/// FCM token refreshed
class TokenRefreshed extends NotificationEvent {
  final String token;

  const TokenRefreshed({required this.token});

  @override
  List<Object?> get props => [token];
}

/// Notification received
class NotificationReceived extends NotificationEvent {
  final AppNotification notification;

  const NotificationReceived({required this.notification});

  @override
  List<Object?> get props => [notification];
}

/// Toggle price alerts
class TogglePriceAlerts extends NotificationEvent {
  final bool enabled;

  const TogglePriceAlerts({required this.enabled});

  @override
  List<Object?> get props => [enabled];
}

/// Toggle portfolio alerts
class TogglePortfolioAlerts extends NotificationEvent {
  final bool enabled;

  const TogglePortfolioAlerts({required this.enabled});

  @override
  List<Object?> get props => [enabled];
}

/// Toggle news alerts
class ToggleNewsAlerts extends NotificationEvent {
  final bool enabled;

  const ToggleNewsAlerts({required this.enabled});

  @override
  List<Object?> get props => [enabled];
}

/// Toggle market updates
class ToggleMarketUpdates extends NotificationEvent {
  final bool enabled;

  const ToggleMarketUpdates({required this.enabled});

  @override
  List<Object?> get props => [enabled];
}

/// Toggle sound
class ToggleSoundEnabled extends NotificationEvent {
  final bool enabled;

  const ToggleSoundEnabled({required this.enabled});

  @override
  List<Object?> get props => [enabled];
}

/// Toggle vibration
class ToggleVibrationEnabled extends NotificationEvent {
  final bool enabled;

  const ToggleVibrationEnabled({required this.enabled});

  @override
  List<Object?> get props => [enabled];
}

/// Subscribe to symbol notifications
class SubscribeToSymbol extends NotificationEvent {
  final String symbol;

  const SubscribeToSymbol({required this.symbol});

  @override
  List<Object?> get props => [symbol];
}

/// Unsubscribe from symbol notifications
class UnsubscribeFromSymbol extends NotificationEvent {
  final String symbol;

  const UnsubscribeFromSymbol({required this.symbol});

  @override
  List<Object?> get props => [symbol];
}

/// Load settings
class LoadSettings extends NotificationEvent {
  const LoadSettings();
}
