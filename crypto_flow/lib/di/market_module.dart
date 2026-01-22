import 'package:core/core.dart';
import 'package:market/market.dart';

import 'injection_container.dart';

/// Register market dependencies
Future<void> registerMarketModule() async {
  // Data sources
  getIt.registerLazySingleton<BinanceWebSocketDataSource>(
    () => BinanceWebSocketDataSource(wsClient: getIt<WebSocketClient>()),
  );

  getIt.registerLazySingleton<MarketRemoteDataSource>(
    () => MarketRemoteDataSourceImpl(apiClient: getIt<BinanceApiClient>()),
  );

  getIt.registerLazySingleton<MarketLocalDataSource>(
    () => MarketLocalDataSourceImpl(),
  );

  // Repositories
  getIt.registerLazySingleton<MarketRepository>(
    () => MarketRepositoryImpl(
      remoteDataSource: getIt<MarketRemoteDataSource>(),
      localDataSource: getIt<MarketLocalDataSource>(),
    ),
  );

  getIt.registerLazySingleton<WebSocketRepository>(
    () => WebSocketRepositoryImpl(
      wsDataSource: getIt<BinanceWebSocketDataSource>(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton(
      () => GetAllTickersUseCase(getIt<MarketRepository>()));
  getIt.registerLazySingleton(
      () => GetCandlesUseCase(getIt<MarketRepository>()));
  getIt.registerLazySingleton(
      () => GetOrderBookUseCase(getIt<MarketRepository>()));
  getIt.registerLazySingleton(
      () => SearchSymbolsUseCase(getIt<MarketRepository>()));
  getIt.registerLazySingleton(
      () => GetTickerStreamUseCase(getIt<WebSocketRepository>()));
  getIt.registerLazySingleton(
      () => GetCandleStreamUseCase(getIt<WebSocketRepository>()));
  getIt.registerLazySingleton(
      () => GetOrderBookStreamUseCase(getIt<WebSocketRepository>()));

  // BLoCs
  getIt.registerFactory<TickerListBloc>(
    () => TickerListBloc(
      marketRepository: getIt<MarketRepository>(),
      wsRepository: getIt<WebSocketRepository>(),
    ),
  );

  getIt.registerFactory<TickerDetailBloc>(
    () => TickerDetailBloc(
      marketRepository: getIt<MarketRepository>(),
      wsRepository: getIt<WebSocketRepository>(),
    ),
  );

  getIt.registerFactory<CandleBloc>(
    () => CandleBloc(
      marketRepository: getIt<MarketRepository>(),
      wsRepository: getIt<WebSocketRepository>(),
    ),
  );

  getIt.registerFactory<OrderBookBloc>(
    () => OrderBookBloc(
      marketRepository: getIt<MarketRepository>(),
      wsRepository: getIt<WebSocketRepository>(),
    ),
  );
}
