import 'dart:async';
import 'dart:developer' show log;

import 'package:dartz/dartz.dart';
import 'package:core/core.dart';

import '../../domain/entities/notification_settings.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/fcm_datasource.dart';
import '../datasources/local_notification_datasource.dart';
import '../datasources/notification_settings_local_datasource.dart';
import '../datasources/notification_remote_datasource.dart';

/// AWS-enhanced [NotificationRepository] implementation.
///
/// Extends the behaviour of [NotificationRepositoryImpl] by:
/// - Registering the FCM token with the AWS backend (SNS) on initialise.
/// - Syncing notification preferences to the AWS backend.
///
/// Local notification display (FCM + flutter_local_notifications) remains
/// unchanged — we still need it for foreground messages.
class NotificationAwsRepositoryImpl implements NotificationRepository {
  final FCMDatasource fcmDatasource;
  final LocalNotificationDatasource localNotificationDatasource;
  final NotificationSettingsLocalDatasource settingsLocalDatasource;
  final NotificationRemoteDataSource remoteDataSource;

  late final StreamController<AppNotification> _messageController;
  late final StreamController<AppNotification> _messageOpenedAppController;
  late final StreamController<String> _tokenRefreshController;

  NotificationAwsRepositoryImpl({
    required this.fcmDatasource,
    required this.localNotificationDatasource,
    required this.settingsLocalDatasource,
    required this.remoteDataSource,
  }) {
    _messageController = StreamController<AppNotification>.broadcast();
    _messageOpenedAppController = StreamController<AppNotification>.broadcast();
    _tokenRefreshController = StreamController<String>.broadcast();

    fcmDatasource.onMessage.listen((m) => _messageController.add(m.toEntity()));
    fcmDatasource.onMessageOpenedApp
        .listen((m) => _messageOpenedAppController.add(m.toEntity()));
    fcmDatasource.onTokenRefresh.listen((token) {
      _tokenRefreshController.add(token);
      _registerTokenRemotely(token);
    });
  }

  // ---------------------------------------------------------------- Init

  @override
  Future<Either<Failure, void>> initialize() async {
    try {
      await settingsLocalDatasource.initialize();
      await fcmDatasource.initialize();
      await localNotificationDatasource.initialize();

      // Register token with AWS backend
      final token = await fcmDatasource.getToken();
      if (token != null) {
        await _registerTokenRemotely(token);
      }

      return const Right(null);
    } catch (e) {
      return Left(
          CacheFailure(message: 'Failed to initialize notifications: $e'));
    }
  }

  Future<void> _registerTokenRemotely(String token) async {
    try {
      await remoteDataSource.registerDevice(
        deviceId: token.hashCode.toRadixString(16),
        token: token,
      );
    } catch (e) {
      log('NotificationAwsRepo: failed to register device — $e');
    }
  }

  // ---------------------------------------------------------------- Perms

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

  // ----------------------------------------------------------- Settings

  @override
  Future<Either<Failure, NotificationSettings>> getSettings() async {
    try {
      // Try remote first
      final prefs = await remoteDataSource.getPreferences();
      final settings = await settingsLocalDatasource.getSettings();
      final merged = settings.copyWith(
        priceAlerts: prefs['priceAlerts'] ?? settings.priceAlerts,
        portfolioAlerts: prefs['portfolioAlerts'] ?? settings.portfolioAlerts,
        newsAlerts: prefs['newsAlerts'] ?? settings.newsAlerts,
        marketUpdates: prefs['marketUpdates'] ?? settings.marketUpdates,
        soundEnabled: prefs['soundEnabled'] ?? settings.soundEnabled,
        vibrationEnabled:
            prefs['vibrationEnabled'] ?? settings.vibrationEnabled,
      );
      await settingsLocalDatasource.saveSettings(merged);
      return Right(merged);
    } catch (_) {
      // Fallback to local
      try {
        return Right(await settingsLocalDatasource.getSettings());
      } catch (e) {
        return Left(CacheFailure(message: 'Failed to get settings: $e'));
      }
    }
  }

  @override
  Future<Either<Failure, void>> updateSettings(
      NotificationSettings settings) async {
    try {
      await settingsLocalDatasource.saveSettings(settings);
      // Sync to remote
      await remoteDataSource.updatePreferences({
        'priceAlerts': settings.priceAlerts,
        'portfolioAlerts': settings.portfolioAlerts,
        'newsAlerts': settings.newsAlerts,
        'marketUpdates': settings.marketUpdates,
        'soundEnabled': settings.soundEnabled,
        'vibrationEnabled': settings.vibrationEnabled,
      });
      return const Right(null);
    } catch (e) {
      // Local save succeeded; remote failure is non-fatal.
      return const Right(null);
    }
  }

  // ----------------------------------------------------------- Topics

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

  // ------------------------------------------------------- Notifications

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
      final settingsResult = await getSettings();
      final settings = settingsResult.fold(
        (_) => NotificationSettings.defaults(),
        (s) => s,
      );
      if (!settings.priceAlerts) return const Right(null);

      await localNotificationDatasource.showPriceAlertNotification(
        symbol: symbol,
        currentPrice: currentPrice,
        targetPrice: targetPrice,
        alertType: alertType,
      );
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(
          message: 'Failed to show price alert notification: $e'));
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

  // ---------------------------------------------------------------- Streams

  @override
  Stream<String> get onTokenRefresh => _tokenRefreshController.stream;

  @override
  Stream<AppNotification> get onMessage => _messageController.stream;

  @override
  Stream<AppNotification> get onMessageOpenedApp =>
      _messageOpenedAppController.stream;

  void dispose() {
    _messageController.close();
    _messageOpenedAppController.close();
    _tokenRefreshController.close();
    fcmDatasource.dispose();
  }
}
