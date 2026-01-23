import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:core/core.dart';

import 'injection_container.dart';

/// Register core dependencies
Future<void> registerCoreModule() async {
  // Dio HTTP client
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

  // WebSocket client
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
}
