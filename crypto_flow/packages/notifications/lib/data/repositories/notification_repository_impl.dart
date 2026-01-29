import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import '../../domain/entities/notification_settings.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/fcm_datasource.dart';
import '../datasources/local_notification_datasource.dart';
import '../datasources/notification_settings_local_datasource.dart';

/// Implementation of NotificationRepository
class NotificationRepositoryImpl implements NotificationRepository {
  final FCMDatasource fcmDatasource;
  final LocalNotificationDatasource localNotificationDatasource;
  final NotificationSettingsLocalDatasource settingsLocalDatasource;

  // Stream controllers for converting datasource streams
  late final StreamController<AppNotification> _messageController;
  late final StreamController<AppNotification> _messageOpenedAppController;
  late final StreamController<String> _tokenRefreshController;

  NotificationRepositoryImpl({
    required this.fcmDatasource,
    required this.localNotificationDatasource,
    required this.settingsLocalDatasource,
  }) {
    _messageController = StreamController<AppNotification>.broadcast();
    _messageOpenedAppController = StreamController<AppNotification>.broadcast();
    _tokenRefreshController = StreamController<String>.broadcast();

    // Forward FCM streams to repository streams
    fcmDatasource.onMessage.listen((fcmMessage) {
      _messageController.add(fcmMessage.toEntity());
    });

    fcmDatasource.onMessageOpenedApp.listen((fcmMessage) {
      _messageOpenedAppController.add(fcmMessage.toEntity());
    });

    fcmDatasource.onTokenRefresh.listen((token) {
      _tokenRefreshController.add(token);
      // Update stored token
      _updateTokenInSettings(token);
    });
  }

  @override
  Future<Either<Failure, void>> initialize() async {
    try {
      await settingsLocalDatasource.initialize();
      await fcmDatasource.initialize();
      await localNotificationDatasource.initialize();
      return const Right(null);
    } catch (e) {
      return Left(
          CacheFailure(message: 'Failed to initialize notifications: $e'));
    }
  }

  @override
  Future<Either<Failure, NotificationSettings>> requestPermission() async {
    try {
      final settings = await fcmDatasource.requestPermission();
      await settingsLocalDatasource.saveSettings(settings);
      return Right(settings);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to request permission: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> getToken() async {
    try {
      final token = await fcmDatasource.getToken();
      if (token == null) {
        return const Left(CacheFailure(message: 'No FCM token available'));
      }
      return Right(token);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get token: $e'));
    }
  }

  @override
  Future<Either<Failure, NotificationSettings>> getSettings() async {
    try {
      final settings = await settingsLocalDatasource.getSettings();
      return Right(settings);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get settings: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateSettings(
      NotificationSettings settings) async {
    try {
      await settingsLocalDatasource.saveSettings(settings);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to update settings: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> subscribeToTopic(String topic) async {
    try {
      await fcmDatasource.subscribeToTopic(topic);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to subscribe to topic: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> unsubscribeFromTopic(String topic) async {
    try {
      await fcmDatasource.unsubscribeFromTopic(topic);
      return const Right(null);
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to unsubscribe from topic: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> showNotification(
      AppNotification notification) async {
    try {
      await localNotificationDatasource.showNotification(notification);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to show notification: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> showPriceAlertNotification({
    required String symbol,
    required double currentPrice,
    required double targetPrice,
    required String alertType,
  }) async {
    try {
      // Check if price alerts are enabled
      final settingsResult = await getSettings();
      final settings = settingsResult.fold(
        (_) => NotificationSettings.defaults(),
        (s) => s,
      );

      if (!settings.priceAlerts) {
        return const Right(null); // Don't show if disabled
      }

      await localNotificationDatasource.showPriceAlertNotification(
        symbol: symbol,
        currentPrice: currentPrice,
        targetPrice: targetPrice,
        alertType: alertType,
      );
      return const Right(null);
    } catch (e) {
      return Left(
          CacheFailure(message: 'Failed to show price alert notification: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelNotification(int id) async {
    try {
      await localNotificationDatasource.cancelNotification(id);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to cancel notification: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelAllNotifications() async {
    try {
      await localNotificationDatasource.cancelAllNotifications();
      return const Right(null);
    } catch (e) {
      return Left(
          CacheFailure(message: 'Failed to cancel all notifications: $e'));
    }
  }

  @override
  Stream<String> get onTokenRefresh => _tokenRefreshController.stream;

  @override
  Stream<AppNotification> get onMessage => _messageController.stream;

  @override
  Stream<AppNotification> get onMessageOpenedApp =>
      _messageOpenedAppController.stream;

  /// Update token in settings when it refreshes
  Future<void> _updateTokenInSettings(String token) async {
    try {
      final settings = await settingsLocalDatasource.getSettings();
      final updated = settings.copyWith(fcmToken: token);
      await settingsLocalDatasource.saveSettings(updated);
    } catch (e) {
      // Log but don't fail
    }
  }

  /// Cleanup
  void dispose() {
    _messageController.close();
    _messageOpenedAppController.close();
    _tokenRefreshController.close();
    fcmDatasource.dispose();
  }
}
