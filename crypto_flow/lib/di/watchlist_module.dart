import 'package:core/core.dart';
import 'package:watchlist/watchlist.dart';

import 'injection_container.dart';

/// Register watchlist dependencies
Future<void> registerWatchlistModule() async {
  // Local data source (always registered — used as cache even in AWS mode)
  final watchlistDataSource = WatchlistLocalDataSource();
  await watchlistDataSource.init();

  getIt.registerLazySingleton<WatchlistLocalDataSource>(
    () => watchlistDataSource,
  );

  // Repositories — feature-flag conditional
  if (FeatureFlags.useAwsBackend) {
    getIt.registerLazySingleton<WatchlistRemoteDataSource>(
      () => WatchlistRemoteDataSourceImpl(
        apiClient: getIt<AwsApiClient>(),
      ),
    );
    getIt.registerLazySingleton<WatchlistRepository>(
      () => WatchlistAwsRepositoryImpl(
        remoteDataSource: getIt<WatchlistRemoteDataSource>(),
        localDataSource: getIt<WatchlistLocalDataSource>(),
      ),
    );
  } else {
    getIt.registerLazySingleton<WatchlistRepository>(
      () => WatchlistRepositoryImpl(
        localDataSource: getIt<WatchlistLocalDataSource>(),
      ),
    );
  }

  // Use cases
  getIt.registerLazySingleton(() => GetWatchlist(getIt<WatchlistRepository>()));
  getIt.registerLazySingleton(
      () => AddToWatchlist(getIt<WatchlistRepository>()));
  getIt.registerLazySingleton(
      () => RemoveFromWatchlist(getIt<WatchlistRepository>()));
  getIt
      .registerLazySingleton(() => IsInWatchlist(getIt<WatchlistRepository>()));
  getIt.registerLazySingleton(
      () => ReorderWatchlist(getIt<WatchlistRepository>()));

  // BLoC
  getIt.registerFactory<WatchlistBloc>(
    () => WatchlistBloc(
      getWatchlist: getIt<GetWatchlist>(),
      addToWatchlist: getIt<AddToWatchlist>(),
      removeFromWatchlist: getIt<RemoveFromWatchlist>(),
      reorderWatchlist: getIt<ReorderWatchlist>(),
      repository: getIt<WatchlistRepository>(),
    ),
  );
}
