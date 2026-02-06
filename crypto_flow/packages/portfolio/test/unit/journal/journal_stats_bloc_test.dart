import 'package:bloc_test/bloc_test.dart';
import 'package:core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portfolio/data/services/pdf_report_service.dart';
import 'package:portfolio/domain/entities/journal_entry.dart';
import 'package:portfolio/domain/entities/stats_period.dart';
import 'package:portfolio/domain/entities/trade_emotion.dart';
import 'package:portfolio/domain/entities/trade_side.dart';
import 'package:portfolio/domain/entities/trading_stats.dart';
import 'package:portfolio/domain/repositories/journal_repository.dart';
import 'package:portfolio/domain/usecases/get_equity_curve.dart';
import 'package:portfolio/domain/usecases/get_journal_entries.dart';
import 'package:portfolio/domain/usecases/get_pnl_analysis.dart';
import 'package:portfolio/domain/usecases/get_trading_stats.dart';
import 'package:portfolio/portfolio.dart';
import 'package:portfolio/presentation/bloc/journal_stats/journal_stats_bloc.dart';
import 'package:portfolio/presentation/bloc/journal_stats/journal_stats_event.dart';
import 'package:portfolio/presentation/bloc/journal_stats/journal_stats_state.dart';
import 'dart:typed_data';

// Mock classes
class MockGetTradingStats extends Mock implements GetTradingStats {}

class MockGetEquityCurve extends Mock implements GetEquityCurve {}

class MockGetPnlAnalysis extends Mock implements GetPnlAnalysis {}

class MockGetJournalEntries extends Mock implements GetJournalEntries {}

class MockJournalRepository extends Mock implements JournalRepository {}

class MockPdfReportService extends Mock implements PdfReportService {}

// Fake classes for non-primitive arguments
class FakeGetTradingStatsParams extends Fake implements GetTradingStatsParams {}

class FakeGetEquityCurveParams extends Fake implements GetEquityCurveParams {}

class FakeGetPnlAnalysisParams extends Fake implements GetPnlAnalysisParams {}

class FakeGetJournalEntriesParams extends Fake
    implements GetJournalEntriesParams {}

// Don't create Fake for enums like StatsPeriod

void main() {
  late JournalStatsBloc bloc;
  late MockGetTradingStats mockGetTradingStats;
  late MockGetEquityCurve mockGetEquityCurve;
  late MockGetPnlAnalysis mockGetPnlAnalysis;
  late MockGetJournalEntries mockGetJournalEntries;
  late MockJournalRepository mockRepository;
  late MockPdfReportService mockPdfReportService;

  final testStats = TradingStats(
    id: 1,
    period: StatsPeriod.weekly,
    periodStart: DateTime(2024, 1, 1),
    periodEnd: DateTime(2024, 1, 7),
    totalTrades: 10,
    winCount: 7,
    lossCount: 3,
    winRate: 70.0,
    totalPnl: 5000.0,
    averageRR: 2.5,
    largestWin: 2000.0,
    largestLoss: -500.0,
    profitFactor: 3.5,
    updatedAt: DateTime(2024, 1, 7),
  );

  final testEquityCurve = [100.0, 250.0, 400.0, 600.0, 550.0];
  final testEmotionPnl = {
    TradeEmotion.confident: 3000.0,
    TradeEmotion.fearful: -500.0,
    TradeEmotion.neutral: 1000.0,
  };
  final testSymbolPnl = {
    'BTCUSDT': 3500.0,
    'ETHUSDT': 1500.0,
  };
  const testMaxDrawdown = 8.33;

  final testEntries = [
    JournalEntry(
      id: 1,
      symbol: 'BTCUSDT',
      side: TradeSide.long,
      entryPrice: 50000.0,
      exitPrice: 55000.0,
      quantity: 1.0,
      pnl: 5000.0,
      emotion: TradeEmotion.confident,
      entryDate: DateTime(2024, 1, 1),
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    ),
  ];

  setUpAll(() {
    registerFallbackValue(FakeGetTradingStatsParams());
    registerFallbackValue(FakeGetEquityCurveParams());
    registerFallbackValue(FakeGetPnlAnalysisParams());
    registerFallbackValue(FakeGetJournalEntriesParams());
    // StatsPeriod is an enum, no fake needed
  });

  setUp(() {
    mockGetTradingStats = MockGetTradingStats();
    mockGetEquityCurve = MockGetEquityCurve();
    mockGetPnlAnalysis = MockGetPnlAnalysis();
    mockGetJournalEntries = MockGetJournalEntries();
    mockRepository = MockJournalRepository();
    mockPdfReportService = MockPdfReportService();

    bloc = JournalStatsBloc(
      getTradingStats: mockGetTradingStats,
      getEquityCurve: mockGetEquityCurve,
      getPnlAnalysis: mockGetPnlAnalysis,
      getJournalEntries: mockGetJournalEntries,
      repository: mockRepository,
      pdfReportService: mockPdfReportService,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('JournalStatsBloc', () {
    test('initial state is JournalStatsInitial', () {
      expect(bloc.state, equals(const JournalStatsInitial()));
    });

    group('JournalStatsRequested', () {
      blocTest<JournalStatsBloc, JournalStatsState>(
        'emits [JournalStatsLoading, JournalStatsLoaded] when stats are loaded successfully',
        build: () {
          when(() => mockGetTradingStats(any()))
              .thenAnswer((_) async => Right(testStats));
          when(() => mockGetEquityCurve(any()))
              .thenAnswer((_) async => Right(testEquityCurve));
          when(() => mockGetPnlAnalysis(any())).thenAnswer(
            (_) async => Right({
              TradeEmotion.confident: 3000.0,
              TradeEmotion.fearful: -500.0,
              TradeEmotion.neutral: 1000.0,
            }),
          );
          when(() => mockRepository.getMaxDrawdown(days: any(named: 'days')))
              .thenAnswer((_) async => const Right(testMaxDrawdown));
          return bloc;
        },
        act: (bloc) =>
            bloc.add(const JournalStatsRequested(StatsPeriod.weekly)),
        expect: () => [
          const JournalStatsLoading(),
          isA<JournalStatsLoaded>()
              .having((s) => s.stats.totalTrades, 'total trades', 10)
              .having((s) => s.stats.winRate, 'win rate', 70.0)
              .having((s) => s.equityCurve.length, 'equity curve length', 5)
              .having((s) => s.maxDrawdown, 'max drawdown', testMaxDrawdown),
        ],
        verify: (_) {
          verify(() => mockGetTradingStats(any())).called(1);
          verify(() => mockGetEquityCurve(any())).called(1);
        },
      );

      blocTest<JournalStatsBloc, JournalStatsState>(
        'emits [JournalStatsLoading, JournalStatsError] when loading fails',
        build: () {
          when(() => mockGetTradingStats(any())).thenAnswer(
              (_) async => const Left(CacheFailure(message: 'Error')));
          return bloc;
        },
        act: (bloc) =>
            bloc.add(const JournalStatsRequested(StatsPeriod.weekly)),
        expect: () => [
          const JournalStatsLoading(),
          const JournalStatsError('Error'),
        ],
      );

      blocTest<JournalStatsBloc, JournalStatsState>(
        'handles daily period',
        build: () {
          when(() => mockGetTradingStats(any()))
              .thenAnswer((_) async => Right(testStats));
          when(() => mockGetEquityCurve(any()))
              .thenAnswer((_) async => Right(testEquityCurve));
          when(() => mockGetPnlAnalysis(any())).thenAnswer(
            (_) async => Right(testEmotionPnl),
          );
          when(() => mockRepository.getMaxDrawdown(days: any(named: 'days')))
              .thenAnswer((_) async => const Right(testMaxDrawdown));
          return bloc;
        },
        act: (bloc) => bloc.add(const JournalStatsRequested(StatsPeriod.daily)),
        verify: (_) {
          verify(() => mockGetTradingStats(
                any(
                    that: predicate<GetTradingStatsParams>(
                        (p) => p.period == StatsPeriod.daily)),
              )).called(1);
        },
      );

      blocTest<JournalStatsBloc, JournalStatsState>(
        'handles monthly period',
        build: () {
          when(() => mockGetTradingStats(any()))
              .thenAnswer((_) async => Right(testStats));
          when(() => mockGetEquityCurve(any()))
              .thenAnswer((_) async => Right(testEquityCurve));
          when(() => mockGetPnlAnalysis(any())).thenAnswer(
            (_) async => Right(testEmotionPnl),
          );
          when(() => mockRepository.getMaxDrawdown(days: any(named: 'days')))
              .thenAnswer((_) async => const Right(testMaxDrawdown));
          return bloc;
        },
        act: (bloc) =>
            bloc.add(const JournalStatsRequested(StatsPeriod.monthly)),
        verify: (_) {
          verify(() => mockGetTradingStats(
                any(
                    that: predicate<GetTradingStatsParams>(
                        (p) => p.period == StatsPeriod.monthly)),
              )).called(1);
        },
      );

      blocTest<JournalStatsBloc, JournalStatsState>(
        'handles all-time period',
        build: () {
          when(() => mockGetTradingStats(any()))
              .thenAnswer((_) async => Right(testStats));
          when(() => mockGetEquityCurve(any()))
              .thenAnswer((_) async => Right(testEquityCurve));
          when(() => mockGetPnlAnalysis(any())).thenAnswer(
            (_) async => Right(testEmotionPnl),
          );
          when(() => mockRepository.getMaxDrawdown(days: any(named: 'days')))
              .thenAnswer((_) async => const Right(testMaxDrawdown));
          return bloc;
        },
        act: (bloc) =>
            bloc.add(const JournalStatsRequested(StatsPeriod.allTime)),
        verify: (_) {
          verify(() => mockGetTradingStats(
                any(
                    that: predicate<GetTradingStatsParams>(
                        (p) => p.period == StatsPeriod.allTime)),
              )).called(1);
        },
      );

      blocTest<JournalStatsBloc, JournalStatsState>(
        'loads all data in parallel',
        build: () {
          when(() => mockGetTradingStats(any()))
              .thenAnswer((_) async => Right(testStats));
          when(() => mockGetEquityCurve(any()))
              .thenAnswer((_) async => Right(testEquityCurve));
          when(() => mockGetPnlAnalysis(any())).thenAnswer(
            (_) async => Right(testEmotionPnl),
          );
          when(() => mockRepository.getMaxDrawdown(days: any(named: 'days')))
              .thenAnswer((_) async => const Right(testMaxDrawdown));
          return bloc;
        },
        act: (bloc) =>
            bloc.add(const JournalStatsRequested(StatsPeriod.weekly)),
        expect: () => [
          const JournalStatsLoading(),
          isA<JournalStatsLoaded>()
              .having((s) => s.stats, 'stats', isNotNull)
              .having((s) => s.equityCurve, 'equity curve', isNotEmpty)
              .having((s) => s.emotionPnl, 'emotion pnl', isNotEmpty)
              .having((s) => s.symbolPnl, 'symbol pnl', isNotEmpty)
              .having((s) => s.maxDrawdown, 'max drawdown', greaterThan(0)),
        ],
      );

      blocTest<JournalStatsBloc, JournalStatsState>(
        'handles partial failures gracefully',
        build: () {
          when(() => mockGetTradingStats(any()))
              .thenAnswer((_) async => Right(testStats));
          when(() => mockGetEquityCurve(any())).thenAnswer(
              (_) async => const Left(CacheFailure(message: 'Error')));
          when(() => mockGetPnlAnalysis(any())).thenAnswer(
            (_) async => Right(testEmotionPnl),
          );
          when(() => mockRepository.getMaxDrawdown(days: any(named: 'days')))
              .thenAnswer((_) async => const Right(testMaxDrawdown));
          return bloc;
        },
        act: (bloc) =>
            bloc.add(const JournalStatsRequested(StatsPeriod.weekly)),
        expect: () => [
          const JournalStatsLoading(),
          isA<JournalStatsLoaded>()
              .having((s) => s.equityCurve, 'equity curve', isEmpty),
        ],
      );
    });

    group('JournalEquityCurveRequested', () {
      blocTest<JournalStatsBloc, JournalStatsState>(
        'updates equity curve in loaded state',
        build: () {
          when(() => mockGetEquityCurve(any()))
              .thenAnswer((_) async => Right(testEquityCurve));
          return bloc;
        },
        seed: () => JournalStatsLoaded(
          stats: testStats,
          equityCurve: const [],
          emotionPnl: testEmotionPnl,
          symbolPnl: testSymbolPnl,
          maxDrawdown: testMaxDrawdown,
        ),
        act: (bloc) => bloc.add(const JournalEquityCurveRequested(days: 30)),
        expect: () => [
          isA<JournalStatsLoaded>()
              .having((s) => s.equityCurve.length, 'equity curve length', 5),
        ],
        verify: (_) {
          verify(() => mockGetEquityCurve(
                any(that: predicate<GetEquityCurveParams>((p) => p.days == 30)),
              )).called(1);
        },
      );

      blocTest<JournalStatsBloc, JournalStatsState>(
        'does nothing when not in loaded state',
        build: () => bloc,
        act: (bloc) => bloc.add(const JournalEquityCurveRequested(days: 30)),
        expect: () => [],
      );

      blocTest<JournalStatsBloc, JournalStatsState>(
        'emits error when equity curve request fails',
        build: () {
          when(() => mockGetEquityCurve(any())).thenAnswer(
              (_) async => const Left(CacheFailure(message: 'Error')));
          return bloc;
        },
        seed: () => JournalStatsLoaded(
          stats: testStats,
          equityCurve: const [],
          emotionPnl: testEmotionPnl,
          symbolPnl: testSymbolPnl,
          maxDrawdown: testMaxDrawdown,
        ),
        act: (bloc) => bloc.add(const JournalEquityCurveRequested(days: 30)),
        expect: () => [
          const JournalStatsError('Error'),
        ],
      );
    });

    group('JournalEmotionAnalysisRequested', () {
      blocTest<JournalStatsBloc, JournalStatsState>(
        'updates emotion P&L in loaded state',
        build: () {
          when(() => mockGetPnlAnalysis(any())).thenAnswer(
            (_) async => Right(testEmotionPnl),
          );
          return bloc;
        },
        seed: () => JournalStatsLoaded(
          stats: testStats,
          equityCurve: testEquityCurve,
          emotionPnl: const {},
          symbolPnl: testSymbolPnl,
          maxDrawdown: testMaxDrawdown,
        ),
        act: (bloc) =>
            bloc.add(const JournalEmotionAnalysisRequested(days: 30)),
        expect: () => [
          isA<JournalStatsLoaded>()
              .having((s) => s.emotionPnl.length, 'emotion pnl length', 3),
        ],
        verify: (_) {
          verify(() => mockGetPnlAnalysis(
                any(
                    that: predicate<GetPnlAnalysisParams>(
                  (p) => p.type == PnlAnalysisType.byEmotion && p.days == 30,
                )),
              )).called(1);
        },
      );

      blocTest<JournalStatsBloc, JournalStatsState>(
        'does nothing when not in loaded state',
        build: () => bloc,
        act: (bloc) =>
            bloc.add(const JournalEmotionAnalysisRequested(days: 30)),
        expect: () => [],
      );
    });

    group('JournalReportRequested', () {
      final mockPdfBytes = Uint8List.fromList([1, 2, 3, 4]);

      blocTest<JournalStatsBloc, JournalStatsState>(
        'emits [JournalReportGenerating, JournalReportGenerated] on success',
        build: () {
          when(() => mockGetJournalEntries(any()))
              .thenAnswer((_) async => Right(testEntries));
          when(() => mockGetTradingStats(any()))
              .thenAnswer((_) async => Right(testStats));
          when(() => mockGetEquityCurve(any()))
              .thenAnswer((_) async => Right(testEquityCurve));
          when(() => mockGetPnlAnalysis(any())).thenAnswer(
            (_) async => Right(testEmotionPnl),
          );
          when(() => mockRepository.getMaxDrawdown(days: any(named: 'days')))
              .thenAnswer((_) async => const Right(testMaxDrawdown));
          when(() => mockPdfReportService.generateTradingReport(
                period: any(named: 'period'),
                entries: any(named: 'entries'),
                stats: any(named: 'stats'),
                emotionPnl: any(named: 'emotionPnl'),
                symbolPnl: any(named: 'symbolPnl'),
                equityCurve: any(named: 'equityCurve'),
                maxDrawdown: any(named: 'maxDrawdown'),
              )).thenAnswer((_) async => mockPdfBytes);
          return bloc;
        },
        act: (bloc) =>
            bloc.add(const JournalReportRequested(StatsPeriod.weekly)),
        expect: () => [
          const JournalReportGenerating(),
          isA<JournalReportGenerated>()
              .having((s) => s.pdfBytes, 'pdf bytes', isNotEmpty),
        ],
        verify: (_) {
          verify(() => mockPdfReportService.generateTradingReport(
                period: any(named: 'period'),
                entries: any(named: 'entries'),
                stats: any(named: 'stats'),
                emotionPnl: any(named: 'emotionPnl'),
                symbolPnl: any(named: 'symbolPnl'),
                equityCurve: any(named: 'equityCurve'),
                maxDrawdown: any(named: 'maxDrawdown'),
              )).called(1);
        },
      );

      blocTest<JournalStatsBloc, JournalStatsState>(
        'emits [JournalReportGenerating, JournalReportError] on failure',
        build: () {
          when(() => mockGetJournalEntries(any())).thenAnswer(
              (_) async => const Left(CacheFailure(message: 'Error')));
          return bloc;
        },
        act: (bloc) =>
            bloc.add(const JournalReportRequested(StatsPeriod.weekly)),
        expect: () => [
          const JournalReportGenerating(),
          isA<JournalReportError>().having(
              (s) => s.message, 'message', contains('Failed to generate')),
        ],
      );

      blocTest<JournalStatsBloc, JournalStatsState>(
        'calculates correct date range for daily period',
        build: () {
          when(() => mockGetJournalEntries(any()))
              .thenAnswer((_) async => Right(testEntries));
          when(() => mockGetTradingStats(any()))
              .thenAnswer((_) async => Right(testStats));
          when(() => mockGetEquityCurve(any()))
              .thenAnswer((_) async => Right(testEquityCurve));
          when(() => mockGetPnlAnalysis(any())).thenAnswer(
            (_) async => Right(testEmotionPnl),
          );
          when(() => mockRepository.getMaxDrawdown(days: any(named: 'days')))
              .thenAnswer((_) async => const Right(testMaxDrawdown));
          when(() => mockPdfReportService.generateTradingReport(
                period: any(named: 'period'),
                entries: any(named: 'entries'),
                stats: any(named: 'stats'),
                emotionPnl: any(named: 'emotionPnl'),
                symbolPnl: any(named: 'symbolPnl'),
                equityCurve: any(named: 'equityCurve'),
                maxDrawdown: any(named: 'maxDrawdown'),
              )).thenAnswer((_) async => mockPdfBytes);
          return bloc;
        },
        act: (bloc) =>
            bloc.add(const JournalReportRequested(StatsPeriod.daily)),
        verify: (_) {
          verify(() => mockGetJournalEntries(
                any(
                    that: predicate<GetJournalEntriesParams>(
                  (p) => p.range != null,
                )),
              )).called(1);
        },
      );
    });

    group('Period Change Scenarios', () {
      blocTest<JournalStatsBloc, JournalStatsState>(
        'recalculates stats when period changes from weekly to monthly',
        build: () {
          when(() => mockGetTradingStats(any()))
              .thenAnswer((_) async => Right(testStats));
          when(() => mockGetEquityCurve(any()))
              .thenAnswer((_) async => Right(testEquityCurve));
          when(() => mockGetPnlAnalysis(any())).thenAnswer(
            (_) async => Right(testEmotionPnl),
          );
          when(() => mockRepository.getMaxDrawdown(days: any(named: 'days')))
              .thenAnswer((_) async => const Right(testMaxDrawdown));
          return bloc;
        },
        act: (bloc) {
          bloc.add(const JournalStatsRequested(StatsPeriod.weekly));
          bloc.add(const JournalStatsRequested(StatsPeriod.monthly));
        },
        expect: () => [
          const JournalStatsLoading(),
          isA<JournalStatsLoaded>(),
          const JournalStatsLoading(),
          isA<JournalStatsLoaded>(),
        ],
      );
    });
  });
}
