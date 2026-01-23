import 'package:portfolio/portfolio.dart';
import 'package:portfolio/data/datasources/portfolio_database.dart';

import 'injection_container.dart';

/// Register portfolio dependencies
Future<void> registerPortfolioModule() async {
  // Database
  final database = PortfolioDatabase();
  getIt.registerSingleton<PortfolioDatabase>(database);

  // Data sources
  getIt.registerLazySingleton<PortfolioLocalDataSource>(
    () => PortfolioLocalDataSource(getIt<PortfolioDatabase>()),
  );

  // Repositories
  getIt.registerLazySingleton<PortfolioRepository>(
    () => PortfolioRepositoryImpl(
      localDataSource: getIt<PortfolioLocalDataSource>(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton(() => GetHoldings(getIt<PortfolioRepository>()));
  getIt.registerLazySingleton(
      () => AddTransaction(getIt<PortfolioRepository>()));
  getIt.registerLazySingleton(
      () => GetPortfolioValue(getIt<PortfolioRepository>()));
  getIt.registerLazySingleton(() => GetPnL(getIt<PortfolioRepository>()));
  getIt
      .registerLazySingleton(() => GetAllocation(getIt<PortfolioRepository>()));

  // BLoC
  getIt.registerFactory<PortfolioBloc>(
    () => PortfolioBloc(
      getHoldings: getIt<GetHoldings>(),
      addTransaction: getIt<AddTransaction>(),
      getPortfolioValue: getIt<GetPortfolioValue>(),
      repository: getIt<PortfolioRepository>(),
    ),
  );
}
