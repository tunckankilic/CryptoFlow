import 'package:settings/settings.dart';

import 'injection_container.dart';

/// Register settings dependencies
Future<void> registerSettingsModule() async {
  // Data sources
  final settingsDataSource = SettingsLocalDataSourceImpl();
  await settingsDataSource.init();

  getIt.registerLazySingleton<SettingsLocalDataSource>(
    () => settingsDataSource,
  );

  // Repositories
  getIt.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(
      localDataSource: getIt<SettingsLocalDataSource>(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton(() => GetSettings(getIt<SettingsRepository>()));
  getIt.registerLazySingleton(() => UpdateTheme(getIt<SettingsRepository>()));
  getIt
      .registerLazySingleton(() => UpdateCurrency(getIt<SettingsRepository>()));

  // BLoC
  getIt.registerFactory<SettingsBloc>(
    () => SettingsBloc(
      getSettings: getIt<GetSettings>(),
      updateTheme: getIt<UpdateTheme>(),
      updateCurrency: getIt<UpdateCurrency>(),
      repository: getIt<SettingsRepository>(),
    ),
  );
}
