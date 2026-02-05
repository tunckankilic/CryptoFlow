import 'package:portfolio/portfolio.dart';

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

  // DAOs
  getIt.registerLazySingleton<JournalDao>(
    () => JournalDao(getIt<PortfolioDatabase>()),
  );

  getIt.registerLazySingleton<TagDao>(
    () => TagDao(getIt<PortfolioDatabase>()),
  );

  // Repositories
  getIt.registerLazySingleton<PortfolioRepository>(
    () => PortfolioRepositoryImpl(
      localDataSource: getIt<PortfolioLocalDataSource>(),
    ),
  );

  getIt.registerLazySingleton<JournalRepository>(
    () => JournalRepositoryImpl(
      journalDao: getIt<JournalDao>(),
      tagDao: getIt<TagDao>(),
    ),
  );

  // Portfolio Use cases
  getIt.registerLazySingleton(() => GetHoldings(getIt<PortfolioRepository>()));
  getIt.registerLazySingleton(
      () => AddTransaction(getIt<PortfolioRepository>()));
  getIt.registerLazySingleton(
      () => GetPortfolioValue(getIt<PortfolioRepository>()));
  getIt.registerLazySingleton(() => GetPnL(getIt<PortfolioRepository>()));
  getIt
      .registerLazySingleton(() => GetAllocation(getIt<PortfolioRepository>()));

  // Journal Use cases
  getIt.registerLazySingleton(
      () => GetJournalEntries(getIt<JournalRepository>()));
  getIt
      .registerLazySingleton(() => AddJournalEntry(getIt<JournalRepository>()));
  getIt.registerLazySingleton(
      () => UpdateJournalEntry(getIt<JournalRepository>()));
  getIt.registerLazySingleton(
      () => DeleteJournalEntry(getIt<JournalRepository>()));
  getIt
      .registerLazySingleton(() => GetTradingStats(getIt<JournalRepository>()));
  getIt.registerLazySingleton(() => GetEquityCurve(getIt<JournalRepository>()));
  getIt.registerLazySingleton(() => GetPnlAnalysis(getIt<JournalRepository>()));

  // BLoCs
  getIt.registerFactory<PortfolioBloc>(
    () => PortfolioBloc(
      getHoldings: getIt<GetHoldings>(),
      addTransaction: getIt<AddTransaction>(),
      getPortfolioValue: getIt<GetPortfolioValue>(),
      repository: getIt<PortfolioRepository>(),
    ),
  );

  getIt.registerFactory<JournalBloc>(
    () => JournalBloc(
      getJournalEntries: getIt<GetJournalEntries>(),
      addJournalEntry: getIt<AddJournalEntry>(),
      updateJournalEntry: getIt<UpdateJournalEntry>(),
      deleteJournalEntry: getIt<DeleteJournalEntry>(),
      repository: getIt<JournalRepository>(),
    ),
  );

  getIt.registerFactory<JournalStatsBloc>(
    () => JournalStatsBloc(
      getTradingStats: getIt<GetTradingStats>(),
      getEquityCurve: getIt<GetEquityCurve>(),
      getPnlAnalysis: getIt<GetPnlAnalysis>(),
      repository: getIt<JournalRepository>(),
    ),
  );
}
