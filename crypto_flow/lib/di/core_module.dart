import 'package:auth/auth.dart';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:core/core.dart';

import 'injection_container.dart';

/// Register core dependencies
Future<void> registerCoreModule() async {
  // ---------------------------------------------------------------- Binance
  // Dio HTTP client (Binance — market data, unchanged)
  getIt.registerLazySingleton<Dio>(() {
    return Dio(BaseOptions(
      baseUrl: BinanceEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));
  });

  // Network info
  getIt.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(Connectivity()),
  );

  // WebSocket client (Binance price streams)
  getIt.registerLazySingleton<WebSocketClient>(() => BinanceWebSocketClient());

  // API client (BinanceApiClient)
  getIt.registerLazySingleton<BinanceApiClient>(
    () => BinanceApiClient(
      dio: getIt<Dio>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );

  // Cloud Sync Service
  getIt.registerLazySingleton<CloudSyncService>(
    () => CloudSyncService(),
  );

  // Widget Data Service (Flutter ↔ iOS WidgetKit bridge)
  getIt.registerLazySingleton<WidgetDataService>(
    () => WidgetDataService(),
  );

  // ---------------------------------------------------------------- AWS
  if (FeatureFlags.useAwsBackend) {
    // Token provider (Cognito)
    getIt.registerLazySingleton<TokenProvider>(
      () => CognitoTokenProvider(),
    );

    // Separate Dio instance for AWS API Gateway
    getIt.registerLazySingleton<Dio>(
      () => Dio(BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      )),
      instanceName: 'awsDio',
    );

    // AWS API client (authenticated)
    getIt.registerLazySingleton<AwsApiClient>(
      () => AwsApiClient(
        dio: getIt<Dio>(instanceName: 'awsDio'),
        networkInfo: getIt<NetworkInfo>(),
        tokenProvider: getIt<TokenProvider>(),
      ),
    );

    // AWS WebSocket client (alert push notifications)
    getIt.registerLazySingleton<AwsWebSocketClient>(
      () => AwsWebSocketClient(
        tokenProvider: getIt<TokenProvider>(),
      ),
    );
  }
}
