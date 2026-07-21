import 'dart:async';
import 'dart:developer' show log;

import 'package:dartz/dartz.dart';
import 'package:core/core.dart';

import '../../domain/entities/notification_settings.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/apns_datasource.dart';
import '../datasources/local_notification_datasource.dart';
import '../datasources/notification_settings_local_datasource.dart';
import '../datasources/notification_remote_datasource.dart';

/// AWS-backed [NotificationRepository] for iOS / APNs.
///
/// - Receives APNs token + push payloads from [ApnsDatasource] (native bridge).
/// - Registers the device token with the SNS-backed CryptoFlow API.
/// - Syncs notification preferences to the AWS backend.
/// - Local display continues to use [flutter_local_notifications] via
///   [LocalNotificationDatasource].
class NotificationAwsRepositoryImpl implements NotificationRepository {
  final ApnsDatasource apnsDatasource;
  final LocalNotificationDatasource localNotificationDatasource;
  final NotificationSettingsLocalDatasource settingsLocalDatasource;
  final NotificationRemoteDataSource remoteDataSource;

  late final StreamController<AppNotification> _messageController;
  late final StreamController<AppNotification> _messageOpenedAppController;
  late final StreamController<String> _tokenRefreshController;

  NotificationAwsRepositoryImpl({
    required this.apnsDatasource,
    required this.localNotificationDatasource,
    required this.settingsLocalDatasource,
    required this.remoteDataSource,
  }) {
    _messageController = StreamController<AppNotification>.broadcast();
    _messageOpenedAppController = StreamController<AppNotification>.broadcast();
    _tokenRefreshController = StreamController<String>.broadcast();

    apnsDatasource.onMessage
        .listen((m) => _messageController.add(m.toEntity()));
    apnsDatasource.onMessageOpenedApp
        .listen((m) => _messageOpenedAppController.add(m.toEntity()));
    apnsDatasource.onTokenRefresh.listen((token) {
      _tokenRefreshController.add(token);
      _registerTokenRemotely(token);
    });
  }

  // ---------------------------------------------------------------- Init

  @override
  Future<Either<Failure, void>> initialize() async {
    try {
      await settingsLocalDatasource.initialize();
      await apnsDatasource.initialize();
      await localNotificationDatasource.initialize();

      final token = await apnsDatasource.getToken();
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
      final settings = await apnsDatasource.requestPermission();
      await settingsLocalDatasource.saveSettings(settings);
      return Right(settings);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to request permission: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> getToken() async {
    try {
      final token = await apnsDatasource.getToken();
      if (token == null) {
        return const Left(CacheFailure(message: 'No push token available'));
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
      return const Right(null);
    }
  }

  // ----------------------------------------------------------- Topics

  // SNS architecture publishes per-endpoint, not per-topic. Per-symbol
  // subscription is handled server-side via alert rules; these calls are
  // accepted as no-ops so existing UI events keep working.
  @override
  Future<Either<Failure, void>> subscribeToTopic(String topic) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> unsubscribeFromTopic(String topic) async {
    return const Right(null);
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
    apnsDatasource.dispose();
  }
}
