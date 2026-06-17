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

  // Repositories — AWS-only
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

  // BLoC — lazySingleton for global BLoC shared across the app
  getIt.registerLazySingleton<WatchlistBloc>(
    () => WatchlistBloc(
      getWatchlist: getIt<GetWatchlist>(),
      addToWatchlist: getIt<AddToWatchlist>(),
      removeFromWatchlist: getIt<RemoveFromWatchlist>(),
      reorderWatchlist: getIt<ReorderWatchlist>(),
      repository: getIt<WatchlistRepository>(),
    ),
  );
}
