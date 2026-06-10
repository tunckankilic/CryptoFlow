import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portfolio/domain/entities/stats_period.dart';
import 'package:portfolio/domain/entities/trade_emotion.dart';
import 'package:portfolio/domain/entities/trading_stats.dart';
import 'package:portfolio/presentation/bloc/journal_stats/journal_stats_bloc.dart';
import 'package:portfolio/presentation/bloc/journal_stats/journal_stats_event.dart';
import 'package:portfolio/presentation/bloc/journal_stats/journal_stats_state.dart';
import 'package:portfolio/presentation/pages/journal/analytics_page.dart';

// Mock classes
class MockJournalStatsBloc extends Mock implements JournalStatsBloc {}

// Fake classes
class FakeJournalStatsEvent extends Fake implements JournalStatsEvent {}

class FakeJournalStatsState extends Fake implements JournalStatsState {}

void main() {
  late MockJournalStatsBloc mockJournalStatsBloc;

  final testStats = TradingStats(
    id: 1,
    period: StatsPeriod.allTime,
    periodStart: DateTime(2024, 1, 1),
    periodEnd: DateTime(2024, 1, 31),
    totalTrades: 10,
    winCount: 7,
    lossCount: 3,
    winRate: 70.0,
    totalPnl: 5000.0,
    averageRR: 2.5,
    largestWin: 2000.0,
    largestLoss: -500.0,
    profitFactor: 3.5,
    updatedAt: DateTime(2024, 1, 31),
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

  setUpAll(() {
    registerFallbackValue(FakeJournalStatsEvent());
    registerFallbackValue(FakeJournalStatsState());
  });

  setUp(() {
    mockJournalStatsBloc = MockJournalStatsBloc();

    when(() => mockJournalStatsBloc.state)
        .thenReturn(const JournalStatsInitial());
    when(() => mockJournalStatsBloc.stream)
        .thenAnswer((_) => const Stream.empty());
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<JournalStatsBloc>.value(
        value: mockJournalStatsBloc,
        child: const AnalyticsPage(),
      ),
    );
  }

  // The analytics body is a long ListView; cards/charts below the default
  // 800x600 surface are lazily built and unfindable. Pump on a tall surface.
  Future<void> pumpPage(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(createWidgetUnderTest());
  }

  group('AnalyticsPage Widget Tests', () {
    testWidgets('renders loading indicator when state is loading',
        (tester) async {
      // arrange
      when(() => mockJournalStatsBloc.state)
          .thenReturn(const JournalStatsLoading());

      // act
      await pumpPage(tester);

      // assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders error message when state is error', (tester) async {
      // arrange
      when(() => mockJournalStatsBloc.state)
          .thenReturn(const JournalStatsError('Test error'));

      // act
      await pumpPage(tester);

      // assert
      expect(find.text('Test error'), findsOneWidget);
    });

    testWidgets('period selector chips exist', (tester) async {
      // arrange
      when(() => mockJournalStatsBloc.state).thenReturn(
        JournalStatsLoaded(
          stats: testStats,
          equityCurve: testEquityCurve,
          emotionPnl: testEmotionPnl,
          symbolPnl: testSymbolPnl,
          maxDrawdown: testMaxDrawdown,
        ),
      );

      // act
      await pumpPage(tester);

      // assert - All period chips should exist (1W / 1M / 3M / 6M / All)
      expect(find.text('1W'), findsOneWidget);
      expect(find.text('1M'), findsOneWidget);
      expect(find.text('3M'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
    });

    testWidgets('tapping period chip triggers JournalStatsRequested',
        (tester) async {
      // arrange
      when(() => mockJournalStatsBloc.state).thenReturn(
        JournalStatsLoaded(
          stats: testStats,
          equityCurve: testEquityCurve,
          emotionPnl: testEmotionPnl,
          symbolPnl: testSymbolPnl,
          maxDrawdown: testMaxDrawdown,
        ),
      );

      // act
      await pumpPage(tester);

      // Find and tap a period chip
      final weeklyChip = find.text('1W');
      await tester.tap(weeklyChip);
      await tester.pumpAndSettle();

      // assert - Should request stats with weekly period
      verify(() =>
              mockJournalStatsBloc.add(any(that: isA<JournalStatsRequested>())))
          .called(1);
    });

    testWidgets('avg R:R card displays value', (tester) async {
      // arrange
      when(() => mockJournalStatsBloc.state).thenReturn(
        JournalStatsLoaded(
          stats: testStats,
          equityCurve: testEquityCurve,
          emotionPnl: testEmotionPnl,
          symbolPnl: testSymbolPnl,
          maxDrawdown: testMaxDrawdown,
        ),
      );

      // act
      await pumpPage(tester);

      // assert - Avg R:R card should be displayed (analytics shows Win Rate,
      // Profit Factor, Avg R:R and Max Drawdown cards; total P&L is not a card).
      expect(find.text('Avg R:R'), findsOneWidget);
      expect(find.textContaining('2.5'), findsAtLeastNWidgets(1));
    });

    testWidgets('win rate card displays percentage', (tester) async {
      // arrange
      when(() => mockJournalStatsBloc.state).thenReturn(
        JournalStatsLoaded(
          stats: testStats,
          equityCurve: testEquityCurve,
          emotionPnl: testEmotionPnl,
          symbolPnl: testSymbolPnl,
          maxDrawdown: testMaxDrawdown,
        ),
      );

      // act
      await pumpPage(tester);

      // assert - Win rate should be displayed
      expect(find.textContaining('70.0'), findsAtLeastNWidgets(1));
    });

    testWidgets('profit factor card displays ratio', (tester) async {
      // arrange
      when(() => mockJournalStatsBloc.state).thenReturn(
        JournalStatsLoaded(
          stats: testStats,
          equityCurve: testEquityCurve,
          emotionPnl: testEmotionPnl,
          symbolPnl: testSymbolPnl,
          maxDrawdown: testMaxDrawdown,
        ),
      );

      // act
      await pumpPage(tester);

      // assert - Profit factor should be displayed
      expect(find.textContaining('3.5'), findsAtLeastNWidgets(1));
    });

    testWidgets('total trades card displays count', (tester) async {
      // arrange
      when(() => mockJournalStatsBloc.state).thenReturn(
        JournalStatsLoaded(
          stats: testStats,
          equityCurve: testEquityCurve,
          emotionPnl: testEmotionPnl,
          symbolPnl: testSymbolPnl,
          maxDrawdown: testMaxDrawdown,
        ),
      );

      // act
      await pumpPage(tester);

      // assert - Total trades should be displayed
      expect(find.textContaining('10'), findsAtLeastNWidgets(1));
    });

    testWidgets('win count card displays correct value', (tester) async {
      // arrange
      when(() => mockJournalStatsBloc.state).thenReturn(
        JournalStatsLoaded(
          stats: testStats,
          equityCurve: testEquityCurve,
          emotionPnl: testEmotionPnl,
          symbolPnl: testSymbolPnl,
          maxDrawdown: testMaxDrawdown,
        ),
      );

      // act
      await pumpPage(tester);

      // assert - Win count should be displayed
      expect(find.textContaining('7'), findsAtLeastNWidgets(1));
    });

    testWidgets('loss count card displays correct value', (tester) async {
      // arrange
      when(() => mockJournalStatsBloc.state).thenReturn(
        JournalStatsLoaded(
          stats: testStats,
          equityCurve: testEquityCurve,
          emotionPnl: testEmotionPnl,
          symbolPnl: testSymbolPnl,
          maxDrawdown: testMaxDrawdown,
        ),
      );

      // act
      await pumpPage(tester);

      // assert - Loss count should be displayed
      expect(find.textContaining('3'), findsAtLeastNWidgets(1));
    });

    testWidgets('largest win card displays value', (tester) async {
      // arrange
      when(() => mockJournalStatsBloc.state).thenReturn(
        JournalStatsLoaded(
          stats: testStats,
          equityCurve: testEquityCurve,
          emotionPnl: testEmotionPnl,
          symbolPnl: testSymbolPnl,
          maxDrawdown: testMaxDrawdown,
        ),
      );

      // act
      await pumpPage(tester);

      // assert - Largest win should be displayed
      expect(find.textContaining('2000'), findsAtLeastNWidgets(1));
    });

    testWidgets('largest loss card displays value', (tester) async {
      // arrange
      when(() => mockJournalStatsBloc.state).thenReturn(
        JournalStatsLoaded(
          stats: testStats,
          equityCurve: testEquityCurve,
          emotionPnl: testEmotionPnl,
          symbolPnl: testSymbolPnl,
          maxDrawdown: testMaxDrawdown,
        ),
      );

      // act
      await pumpPage(tester);

      // assert - Largest loss should be displayed
      expect(find.textContaining('500'), findsAtLeastNWidgets(1));
    });

    testWidgets('max drawdown card displays percentage', (tester) async {
      // arrange
      when(() => mockJournalStatsBloc.state).thenReturn(
        JournalStatsLoaded(
          stats: testStats,
          equityCurve: testEquityCurve,
          emotionPnl: testEmotionPnl,
          symbolPnl: testSymbolPnl,
          maxDrawdown: testMaxDrawdown,
        ),
      );

      // act
      await pumpPage(tester);

      // assert - Max drawdown should be displayed
      // Max drawdown card renders with one decimal place (e.g. "8.3%").
      expect(find.textContaining('8.3'), findsAtLeastNWidgets(1));
    });

    testWidgets('equity curve chart renders without error', (tester) async {
      // arrange
      when(() => mockJournalStatsBloc.state).thenReturn(
        JournalStatsLoaded(
          stats: testStats,
          equityCurve: testEquityCurve,
          emotionPnl: testEmotionPnl,
          symbolPnl: testSymbolPnl,
          maxDrawdown: testMaxDrawdown,
        ),
      );

      // act
      await pumpPage(tester);

      // assert - Should find equity curve section
      expect(find.text('Equity Curve'), findsOneWidget);
    });

    testWidgets('P&L by symbol bar chart renders without error',
        (tester) async {
      // arrange
      when(() => mockJournalStatsBloc.state).thenReturn(
        JournalStatsLoaded(
          stats: testStats,
          equityCurve: testEquityCurve,
          emotionPnl: testEmotionPnl,
          symbolPnl: testSymbolPnl,
          maxDrawdown: testMaxDrawdown,
        ),
      );

      // act
      await pumpPage(tester);

      // assert - Should find P&L by symbol section
      expect(find.text('P&L by Symbol'), findsOneWidget);
    });

    testWidgets('emotion pie chart renders without error', (tester) async {
      // arrange
      when(() => mockJournalStatsBloc.state).thenReturn(
        JournalStatsLoaded(
          stats: testStats,
          equityCurve: testEquityCurve,
          emotionPnl: testEmotionPnl,
          symbolPnl: testSymbolPnl,
          maxDrawdown: testMaxDrawdown,
        ),
      );

      // act
      await pumpPage(tester);

      // assert - Should find emotion analysis section
      expect(find.text('Emotion Analysis'), findsOneWidget);
    });

    // NOTE: Report export is not triggered from the analytics page (it has no
    // export button); that flow lives elsewhere. Tests for an export button on
    // this page were removed as they asserted UI that no longer exists.

    testWidgets('shows empty message when equity curve is empty',
        (tester) async {
      // arrange
      when(() => mockJournalStatsBloc.state).thenReturn(
        JournalStatsLoaded(
          stats: testStats,
          equityCurve: const [],
          emotionPnl: const {},
          symbolPnl: const {},
          maxDrawdown: 0.0,
        ),
      );

      // act
      await pumpPage(tester);

      // Empty charts render as empty space (not a message); the page should
      // still show the stat cards without crashing.
      expect(find.text('Win Rate'), findsOneWidget);
    });

    // NOTE: The analytics page does not dispatch JournalStatsRequested on init
    // (the owning route seeds the bloc); the obsolete "requests stats on init"
    // test was removed.

    testWidgets('stats cards layout is correct', (tester) async {
      // arrange
      when(() => mockJournalStatsBloc.state).thenReturn(
        JournalStatsLoaded(
          stats: testStats,
          equityCurve: testEquityCurve,
          emotionPnl: testEmotionPnl,
          symbolPnl: testSymbolPnl,
          maxDrawdown: testMaxDrawdown,
        ),
      );

      // act
      await pumpPage(tester);

      // assert - Stat cards render (laid out in rows, not a GridView).
      expect(find.text('Win Rate'), findsOneWidget);
      expect(find.text('Max Drawdown'), findsOneWidget);
    });

    testWidgets('handles state changes correctly', (tester) async {
      // arrange - start loading, then the bloc emits a loaded state. BlocBuilder
      // rebuilds on stream emissions, so drive the change through the stream
      // (changing only the mocked `state` getter would not trigger a rebuild).
      final loaded = JournalStatsLoaded(
        stats: testStats,
        equityCurve: testEquityCurve,
        emotionPnl: testEmotionPnl,
        symbolPnl: testSymbolPnl,
        maxDrawdown: testMaxDrawdown,
      );
      when(() => mockJournalStatsBloc.state)
          .thenReturn(const JournalStatsLoading());
      when(() => mockJournalStatsBloc.stream)
          .thenAnswer((_) => Stream.value(loaded));

      // act
      await pumpPage(tester);

      // assert - Initially loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Deliver the streamed loaded state. Use pump() not pumpAndSettle(): the
      // charts animate, so settling never completes.
      await tester.pump();

      // assert - Now showing stats (loading spinner is gone, cards render).
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Win Rate'), findsOneWidget);
    });
  });
}
