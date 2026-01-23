import 'package:alerts/alerts.dart';

import 'injection_container.dart';

/// Register alerts dependencies
Future<void> registerAlertsModule() async {
  // Data sources (no Impl suffix - class is named AlertLocalDataSource)
  final alertDataSource = AlertLocalDataSource();
  await alertDataSource.init();

  getIt.registerLazySingleton<AlertLocalDataSource>(
    () => alertDataSource,
  );

  // Repositories
  getIt.registerLazySingleton<AlertRepository>(
    () => AlertRepositoryImpl(
      localDataSource: getIt<AlertLocalDataSource>(),
    ),
  );

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
    ),
  );
}
