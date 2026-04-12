import 'package:alerts/alerts.dart';
import 'package:core/core.dart';
import 'package:notifications/notifications.dart';

import 'injection_container.dart';

/// Register alerts dependencies
Future<void> registerAlertsModule() async {
  // Local data source (always registered — used as cache even in AWS mode)
  final alertDataSource = AlertLocalDataSource();
  await alertDataSource.init();

  getIt.registerLazySingleton<AlertLocalDataSource>(
    () => alertDataSource,
  );

  // Repositories — feature-flag conditional
  if (FeatureFlags.useAwsBackend) {
    getIt.registerLazySingleton<AlertRemoteDataSource>(
      () => AlertRemoteDataSourceImpl(
        apiClient: getIt<AwsApiClient>(),
      ),
    );
    getIt.registerLazySingleton<AlertRepository>(
      () => AlertAwsRepositoryImpl(
        remoteDataSource: getIt<AlertRemoteDataSource>(),
        localDataSource: getIt<AlertLocalDataSource>(),
      ),
    );
  } else {
    getIt.registerLazySingleton<AlertRepository>(
      () => AlertRepositoryImpl(
        localDataSource: getIt<AlertLocalDataSource>(),
      ),
    );
  }

  // Use cases
  getIt.registerLazySingleton(() => GetAlerts(getIt<AlertRepository>()));
  getIt.registerLazySingleton(() => CreateAlert(getIt<AlertRepository>()));
  getIt.registerLazySingleton(() => DeleteAlert(getIt<AlertRepository>()));
  getIt.registerLazySingleton(() => ToggleAlert(getIt<AlertRepository>()));
  getIt.registerLazySingleton(() => CheckAlerts(getIt<AlertRepository>()));

  // BLoC
  getIt.registerFactory<AlertBloc>(
    () => AlertBloc(
      getAlerts: getIt<GetAlerts>(),
      createAlert: getIt<CreateAlert>(),
      deleteAlert: getIt<DeleteAlert>(),
      toggleAlert: getIt<ToggleAlert>(),
      checkAlerts: getIt<CheckAlerts>(),
      repository: getIt<AlertRepository>(),
      widgetDataService: getIt<WidgetDataService>(),
      notificationRepository: getIt.isRegistered<NotificationRepository>()
          ? getIt<NotificationRepository>()
          : null,
    ),
  );
}
