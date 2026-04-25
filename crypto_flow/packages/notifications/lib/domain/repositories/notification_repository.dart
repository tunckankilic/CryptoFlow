import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import '../entities/notification_settings.dart';
import '../entities/app_notification.dart';

/// Repository interface for notification operations
abstract class NotificationRepository {
  /// Initialize APNs bridge and local notifications
  Future<Either<Failure, void>> initialize();

  /// Request notification permission
  Future<Either<Failure, NotificationSettings>> requestPermission();

  /// Get the device push token (APNs on iOS)
  Future<Either<Failure, String>> getToken();

  /// Get current notification settings
  Future<Either<Failure, NotificationSettings>> getSettings();

  /// Update notification settings
  Future<Either<Failure, void>> updateSettings(NotificationSettings settings);

  /// Subscribe to a topic
  Future<Either<Failure, void>> subscribeToTopic(String topic);

  /// Unsubscribe from a topic
  Future<Either<Failure, void>> unsubscribeFromTopic(String topic);

  /// Show a local notification
  Future<Either<Failure, void>> showNotification(AppNotification notification);

  /// Show a price alert notification
  Future<Either<Failure, void>> showPriceAlertNotification({
    required String symbol,
    required double currentPrice,
    required double targetPrice,
    required String alertType,
  });

  /// Cancel a notification by ID
  Future<Either<Failure, void>> cancelNotification(int id);

  /// Cancel all notifications
  Future<Either<Failure, void>> cancelAllNotifications();

  /// Stream of push token changes (APNs token rotation)
  Stream<String> get onTokenRefresh;

  /// Stream of foreground messages
  Stream<AppNotification> get onMessage;

  /// Stream of messages that opened the app
  Stream<AppNotification> get onMessageOpenedApp;
}
