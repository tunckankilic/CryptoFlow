import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
  sl.registerLazySingleton(() => FirebaseMessaging.instance);
  sl.registerLazySingleton(() => FlutterLocalNotificationsPlugin());

  // Datasources
  sl.registerLazySingleton<FCMDatasource>(
    () => FCMDatasource(sl()),
  );

  sl.registerLazySingleton<LocalNotificationDatasource>(
    () => LocalNotificationDatasource(),
  );

  sl.registerLazySingleton<NotificationSettingsLocalDatasource>(
    () => NotificationSettingsLocalDatasource(),
  );

  // Repository
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(
      fcmDatasource: sl(),
      localNotificationDatasource: sl(),
      settingsLocalDatasource: sl(),
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
    () => GetFCMToken(sl()),
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

  // BLoC
  sl.registerFactory(
    () => NotificationBloc(
      initializeNotifications: sl(),
      requestPermission: sl(),
      getFCMToken: sl(),
      subscribeToTopic: sl(),
      unsubscribeFromTopic: sl(),
      repository: sl(),
    ),
  );
}
