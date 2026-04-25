import 'package:core/core.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Package imports
import 'package:notifications/notifications.dart';

/// Initialize notification dependencies
Future<void> initNotificationModule(GetIt sl) async {
  // Register Hive adapters
  if (!Hive.isAdapterRegistered(13)) {
    Hive.registerAdapter(NotificationSettingsModelAdapter());
  }

  // External dependencies
  sl.registerLazySingleton(() => FlutterLocalNotificationsPlugin());

  // Datasources
  sl.registerLazySingleton<ApnsDatasource>(
    () => ApnsDatasource(sl()),
  );

  sl.registerLazySingleton<LocalNotificationDatasource>(
    () => LocalNotificationDatasource(),
  );

  sl.registerLazySingleton<NotificationSettingsLocalDatasource>(
    () => NotificationSettingsLocalDatasource(),
  );

  // Repository — AWS-only
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(
      apiClient: sl<AwsApiClient>(),
    ),
  );
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationAwsRepositoryImpl(
      apnsDatasource: sl(),
      localNotificationDatasource: sl(),
      settingsLocalDatasource: sl(),
      remoteDataSource: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(
    () => InitializeNotifications(sl()),
  );

  sl.registerLazySingleton(
    () => RequestPermission(sl()),
  );

  sl.registerLazySingleton(
    () => GetPushToken(sl()),
  );

  sl.registerLazySingleton(
    () => SubscribeToTopic(sl()),
  );

  sl.registerLazySingleton(
    () => UnsubscribeFromTopic(sl()),
  );

  sl.registerLazySingleton(
    () => HandleNotification(sl()),
  );

  // BLoC — lazySingleton for global BLoC shared across the app
  sl.registerLazySingleton(
    () => NotificationBloc(
      initializeNotifications: sl(),
      requestPermission: sl(),
      getPushToken: sl(),
      subscribeToTopic: sl(),
      unsubscribeFromTopic: sl(),
      repository: sl(),
    ),
  );
}
