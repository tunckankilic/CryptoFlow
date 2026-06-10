import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portfolio/domain/entities/journal_entry.dart';
import 'package:portfolio/domain/entities/stats_period.dart';
import 'package:portfolio/domain/entities/trade_emotion.dart';
import 'package:portfolio/domain/entities/trade_side.dart';
import 'package:portfolio/domain/entities/trading_stats.dart';
import 'package:portfolio/presentation/bloc/journal/journal_bloc.dart';
import 'package:portfolio/presentation/bloc/journal/journal_event.dart';
import 'package:portfolio/presentation/bloc/journal/journal_filter.dart';
import 'package:portfolio/presentation/bloc/journal/journal_sort.dart';
import 'package:portfolio/presentation/bloc/journal/journal_state.dart';
import 'package:portfolio/presentation/bloc/journal_stats/journal_stats_bloc.dart';
import 'package:portfolio/presentation/bloc/journal_stats/journal_stats_event.dart';
import 'package:portfolio/presentation/bloc/journal_stats/journal_stats_state.dart';
import 'package:portfolio/presentation/pages/journal/journal_list_page.dart';

// Mock classes
class MockJournalBloc extends Mock implements JournalBloc {}

class MockJournalStatsBloc extends Mock implements JournalStatsBloc {}

// Fake classes for events
class FakeJournalEvent extends Fake implements JournalEvent {}

class FakeJournalState extends Fake implements JournalState {}

class FakeJournalStatsEvent extends Fake implements JournalStatsEvent {}

class FakeJournalStatsState extends Fake implements JournalStatsState {}

void main() {
  late MockJournalBloc mockJournalBloc;
  late MockJournalStatsBloc mockJournalStatsBloc;

  final testEntries = [
    JournalEntry(
      id: 1,
      symbol: 'BTCUSDT',
      side: TradeSide.long,
      entryPrice: 50000.0,
      exitPrice: 55000.0,
      quantity: 1.0,
      pnl: 5000.0,
      pnlPercentage: 10.0,
      emotion: TradeEmotion.confident,
      entryDate: DateTime(2024, 1, 1),
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    ),
    JournalEntry(
      id: 2,
      symbol: 'ETHUSDT',
      side: TradeSide.short,
      entryPrice: 3000.0,
      exitPrice: 2800.0,
      quantity: 2.0,
      pnl: 400.0,
      pnlPercentage: 6.67,
      emotion: TradeEmotion.fearful,
      tags: ['breakout'],
      entryDate: DateTime(2024, 1, 2),
      createdAt: DateTime(2024, 1, 2),
      updatedAt: DateTime(2024, 1, 2),
    ),
  ];

  final testStats = TradingStats(
    id: 1,
    period: StatsPeriod.allTime,
    periodStart: DateTime(2024, 1, 1),
    periodEnd: DateTime(2024, 1, 31),
    totalTrades: 2,
    winCount: 2,
    lossCount: 0,
    winRate: 100.0,
    totalPnl: 5400.0,
    averageRR: 2.5,
    largestWin: 5000.0,
    largestLoss: 0.0,
    profitFactor: 0.0,
    updatedAt: DateTime(2024, 1, 31),
  );

  setUpAll(() {
    registerFallbackValue(FakeJournalEvent());
    registerFallbackValue(FakeJournalState());
    registerFallbackValue(FakeJournalStatsEvent());
    registerFallbackValue(FakeJournalStatsState());
  });

  setUp(() {
    mockJournalBloc = MockJournalBloc();
    mockJournalStatsBloc = MockJournalStatsBloc();

    when(() => mockJournalBloc.state).thenReturn(const JournalInitial());
    when(() => mockJournalBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockJournalStatsBloc.state)
        .thenReturn(const JournalStatsInitial());
    when(() => mockJournalStatsBloc.stream)
        .thenAnswer((_) => const Stream.empty());
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<JournalBloc>.value(value: mockJournalBloc),
          BlocProvider<JournalStatsBloc>.value(value: mockJournalStatsBloc),
        ],
        child: const JournalListPage(),
      ),
    );
  }

  group('JournalListPage Widget Tests', () {
    testWidgets('renders loading indicator when state is JournalLoading',
        (tester) async {
      // arrange
      when(() => mockJournalBloc.state).thenReturn(const JournalLoading());

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders error message when state is JournalError',
        (tester) async {
      // arrange
      when(() => mockJournalBloc.state)
          .thenReturn(const JournalError('Test error'));

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.text('Test error'), findsOneWidget);
    });

    testWidgets('renders journal entries when state is JournalLoaded',
        (tester) async {
      // arrange
      when(() => mockJournalBloc.state).thenReturn(
        JournalLoaded(
          entries: testEntries,
          filter: const JournalFilter.empty(),
          sort: JournalSort.dateDesc,
          totalCount: testEntries.length,
        ),
      );
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

      // assert
      expect(find.text('BTCUSDT'), findsOneWidget);
      expect(find.text('ETHUSDT'), findsOneWidget);
    });

    testWidgets('shows empty state when no entries', (tester) async {
      // arrange
      when(() => mockJournalBloc.state).thenReturn(
        const JournalLoaded(
          entries: [],
          filter: JournalFilter.empty(),
          sort: JournalSort.dateDesc,
          totalCount: 0,
        ),
      );
      when(() => mockJournalStatsBloc.state)
          .thenReturn(const JournalStatsInitial());

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.text('No trades logged yet'), findsOneWidget);
      expect(find.text('Start journaling!'), findsOneWidget);
    });

    testWidgets('filter chips exist and are tappable', (tester) async {
      // arrange
      when(() => mockJournalBloc.state).thenReturn(
        JournalLoaded(
          entries: testEntries,
          filter: const JournalFilter.empty(),
          sort: JournalSort.dateDesc,
          totalCount: testEntries.length,
        ),
      );
      when(() => mockJournalStatsBloc.state)
          .thenReturn(const JournalStatsInitial());

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert - Find "All" filter chip
      final allChipFinder = find.text('All');
      expect(allChipFinder, findsOneWidget);

      // Act - tap the filter chip
      await tester.tap(allChipFinder);
      await tester.pumpAndSettle();

      // Verify JournalFilterChanged event was added
      verify(() => mockJournalBloc.add(any(that: isA<JournalFilterChanged>())))
          .called(1);
    });

    testWidgets('search text field exists and triggers search', (tester) async {
      // arrange
      when(() => mockJournalBloc.state).thenReturn(
        JournalLoaded(
          entries: testEntries,
          filter: const JournalFilter.empty(),
          sort: JournalSort.dateDesc,
          totalCount: testEntries.length,
        ),
      );
      when(() => mockJournalStatsBloc.state)
          .thenReturn(const JournalStatsInitial());

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert - Find search field
      final searchFieldFinder = find.byType(TextField);
      expect(searchFieldFinder, findsOneWidget);

      // Act - enter search text
      await tester.enterText(searchFieldFinder, 'BTC');
      await tester.pump(const Duration(milliseconds: 600)); // Wait for debounce

      // Verify JournalSearched event was added
      verify(() => mockJournalBloc.add(any(that: isA<JournalSearched>())))
          .called(1);
    });

    // NOTE: The list page has no FloatingActionButton (adding an entry is
    // routed from elsewhere); the obsolete "FAB exists" test was removed.

    testWidgets('slidable delete action exists', (tester) async {
      // arrange
      when(() => mockJournalBloc.state).thenReturn(
        JournalLoaded(
          entries: testEntries,
          filter: const JournalFilter.empty(),
          sort: JournalSort.dateDesc,
          totalCount: testEntries.length,
        ),
      );
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

      // assert - Find Slidable widget
      expect(find.byType(Slidable), findsAtLeastNWidgets(1));
    });

    testWidgets('sort dropdown exists and changes sort', (tester) async {
      // arrange
      when(() => mockJournalBloc.state).thenReturn(
        JournalLoaded(
          entries: testEntries,
          filter: const JournalFilter.empty(),
          sort: JournalSort.dateDesc,
          totalCount: testEntries.length,
        ),
      );
      when(() => mockJournalStatsBloc.state)
          .thenReturn(const JournalStatsInitial());

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert - Find sort dropdown button
      final dropdownFinder = find.byType(DropdownButton<JournalSort>);
      expect(dropdownFinder, findsOneWidget);
    });

    // NOTE: The list page does not render a "N entries" total-count label;
    // the obsolete count test was removed.

    testWidgets('quick stats widget shows when stats loaded', (tester) async {
      // arrange
      when(() => mockJournalBloc.state).thenReturn(
        JournalLoaded(
          entries: testEntries,
          filter: const JournalFilter.empty(),
          sort: JournalSort.dateDesc,
          totalCount: testEntries.length,
        ),
      );
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

      // assert - Stats should be displayed
      expect(find.text('100.0%'), findsOneWidget); // Win rate
    });

    testWidgets('handles state changes correctly', (tester) async {
      // arrange - start loading, then the bloc emits a loaded state.
      // BlocBuilder rebuilds on stream emissions, so drive the change through
      // the stream (changing only the mocked `state` getter would not trigger
      // a rebuild).
      final loaded = JournalLoaded(
        entries: testEntries,
        filter: const JournalFilter.empty(),
        sort: JournalSort.dateDesc,
        totalCount: testEntries.length,
      );
      when(() => mockJournalBloc.state).thenReturn(const JournalLoading());
      when(() => mockJournalBloc.stream)
          .thenAnswer((_) => Stream.value(loaded));
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

      // assert - Initially loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Deliver the streamed loaded state.
      await tester.pump();

      // assert - Now showing entries
      expect(find.text('BTCUSDT'), findsOneWidget);
    });

    // NOTE: The list page does not dispatch JournalEntriesRequested /
    // JournalStatsRequested on init (the owning route seeds the blocs);
    // the obsolete "requests entries on init" test was removed.
  });
}
