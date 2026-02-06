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

  group('AnalyticsPage Widget Tests', () {
    testWidgets('renders loading indicator when state is loading',
        (tester) async {
      // arrange
      when(() => mockJournalStatsBloc.state)
          .thenReturn(const JournalStatsLoading());

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders error message when state is error', (tester) async {
      // arrange
      when(() => mockJournalStatsBloc.state)
          .thenReturn(const JournalStatsError('Test error'));

      // act
      await tester.pumpWidget(createWidgetUnderTest());

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
      await tester.pumpWidget(createWidgetUnderTest());

      // assert - All period chips should exist
      expect(find.text('Daily'), findsOneWidget);
      expect(find.text('Weekly'), findsOneWidget);
      expect(find.text('Monthly'), findsOneWidget);
      expect(find.text('All Time'), findsOneWidget);
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
      await tester.pumpWidget(createWidgetUnderTest());

      // Find and tap weekly chip
      final weeklyChip = find.text('Weekly');
      await tester.tap(weeklyChip);
      await tester.pumpAndSettle();

      // assert - Should request stats with weekly period
      verify(() =>
              mockJournalStatsBloc.add(any(that: isA<JournalStatsRequested>())))
          .called(1);
    });

    testWidgets('total P&L card displays correct value', (tester) async {
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
      await tester.pumpWidget(createWidgetUnderTest());

      // assert - Total P&L should be displayed
      expect(find.textContaining('5000'), findsAtLeastNWidgets(1));
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
      await tester.pumpWidget(createWidgetUnderTest());

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
      await tester.pumpWidget(createWidgetUnderTest());

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
      await tester.pumpWidget(createWidgetUnderTest());

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
      await tester.pumpWidget(createWidgetUnderTest());

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
      await tester.pumpWidget(createWidgetUnderTest());

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
      await tester.pumpWidget(createWidgetUnderTest());

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
      await tester.pumpWidget(createWidgetUnderTest());

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
      await tester.pumpWidget(createWidgetUnderTest());

      // assert - Max drawdown should be displayed
      expect(find.textContaining('8.33'), findsAtLeastNWidgets(1));
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
      await tester.pumpWidget(createWidgetUnderTest());

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
      await tester.pumpWidget(createWidgetUnderTest());

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
      await tester.pumpWidget(createWidgetUnderTest());

      // assert - Should find emotion analysis section
      expect(find.text('P&L by Emotion'), findsOneWidget);
    });

    testWidgets('export button exists', (tester) async {
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
      await tester.pumpWidget(createWidgetUnderTest());

      // assert - Export button should exist
      expect(find.byIcon(Icons.download), findsOneWidget);
    });

    testWidgets('tapping export triggers JournalReportRequested',
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
      await tester.pumpWidget(createWidgetUnderTest());

      // Find and tap export button
      final exportButton = find.byIcon(Icons.download);
      await tester.tap(exportButton);
      await tester.pumpAndSettle();

      // assert - Should request report generation
      verify(() => mockJournalStatsBloc
          .add(any(that: isA<JournalReportRequested>()))).called(1);
    });

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
      await tester.pumpWidget(createWidgetUnderTest());

      // assert - Should show empty message for charts
      expect(find.text('No data available'), findsAtLeastNWidgets(1));
    });

    testWidgets('handles initial state and requests stats', (tester) async {
      // arrange
      when(() => mockJournalStatsBloc.state)
          .thenReturn(const JournalStatsInitial());

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert - Should request stats on init
      verify(() =>
              mockJournalStatsBloc.add(any(that: isA<JournalStatsRequested>())))
          .called(1);
    });

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
      await tester.pumpWidget(createWidgetUnderTest());

      // assert - Should have GridView with stats cards
      expect(find.byType(GridView), findsAtLeastNWidgets(1));
    });

    testWidgets('handles state changes correctly', (tester) async {
      // arrange
      when(() => mockJournalStatsBloc.state)
          .thenReturn(const JournalStatsLoading());

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert - Initially loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Change state to loaded
      when(() => mockJournalStatsBloc.state).thenReturn(
        JournalStatsLoaded(
          stats: testStats,
          equityCurve: testEquityCurve,
          emotionPnl: testEmotionPnl,
          symbolPnl: testSymbolPnl,
          maxDrawdown: testMaxDrawdown,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // assert - Now showing stats
      expect(find.textContaining('70.0'), findsAtLeastNWidgets(1));
    });
  });
}
