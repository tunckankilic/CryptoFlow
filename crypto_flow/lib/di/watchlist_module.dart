import 'package:watchlist/watchlist.dart';

import 'injection_container.dart';

/// Register watchlist dependencies
Future<void> registerWatchlistModule() async {
  // Data sources (no Impl suffix - class is named WatchlistLocalDataSource)
  final watchlistDataSource = WatchlistLocalDataSource();
  await watchlistDataSource.init();

  getIt.registerLazySingleton<WatchlistLocalDataSource>(
    () => watchlistDataSource,
  );

  // Repositories
  getIt.registerLazySingleton<WatchlistRepository>(
    () => WatchlistRepositoryImpl(
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
