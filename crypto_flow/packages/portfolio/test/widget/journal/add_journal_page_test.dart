import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portfolio/domain/entities/journal_entry.dart';
import 'package:portfolio/domain/entities/trade_emotion.dart';
import 'package:portfolio/domain/entities/trade_side.dart';
import 'package:portfolio/presentation/bloc/journal/journal_bloc.dart';
import 'package:portfolio/presentation/bloc/journal/journal_event.dart';
import 'package:portfolio/presentation/bloc/journal/journal_state.dart';
import 'package:portfolio/presentation/pages/journal/add_edit_journal_page.dart';

// Mock classes
class MockJournalBloc extends Mock implements JournalBloc {}

// Fake classes
class FakeJournalEvent extends Fake implements JournalEvent {}

class FakeJournalState extends Fake implements JournalState {}

void main() {
  late MockJournalBloc mockJournalBloc;

  setUpAll(() {
    registerFallbackValue(FakeJournalEvent());
    registerFallbackValue(FakeJournalState());
  });

  setUp(() {
    mockJournalBloc = MockJournalBloc();

    when(() => mockJournalBloc.state).thenReturn(const JournalInitial());
    when(() => mockJournalBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget createWidgetUnderTest({JournalEntry? entry}) {
    return MaterialApp(
      home: BlocProvider<JournalBloc>.value(
        value: mockJournalBloc,
        child: AddEditJournalPage(entry: entry),
      ),
    );
  }

  group('AddEditJournalPage Widget Tests', () {
    testWidgets('renders form fields correctly for new entry', (tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.text('Add Journal Entry'), findsOneWidget);
      expect(find.byType(TextField), findsWidgets);
      expect(find.text('Symbol *'), findsOneWidget);
      expect(find.text('Entry Price *'), findsOneWidget);
      expect(find.text('Quantity *'), findsOneWidget);
    });

    testWidgets('renders form fields with existing entry data', (tester) async {
      // arrange
      final entry = JournalEntry(
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
      );

      // act
      await tester.pumpWidget(createWidgetUnderTest(entry: entry));
      await tester.pumpAndSettle();

      // assert
      expect(find.text('Edit Journal Entry'), findsOneWidget);
      expect(find.text('BTCUSDT'), findsOneWidget);
    });

    testWidgets('symbol field is required', (tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // Find and tap save button without filling form
      final saveButton = find.text('Save Entry');
      expect(saveButton, findsOneWidget);

      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // assert - Should show validation error
      expect(find.text('Please enter a symbol'), findsOneWidget);
    });

    testWidgets('entry price field is required', (tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // Fill symbol but not entry price
      await tester.enterText(
          find.widgetWithText(TextField, 'Symbol *'), 'BTCUSDT');

      final saveButton = find.text('Save Entry');
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // assert - Should show validation error for entry price
      expect(find.text('Please enter entry price'), findsOneWidget);
    });

    testWidgets('quantity field is required', (tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // Fill symbol and entry price but not quantity
      final symbolField = find.widgetWithText(TextField, 'Symbol *');
      await tester.enterText(symbolField, 'BTCUSDT');

      final entryPriceField = find.widgetWithText(TextField, 'Entry Price *');
      await tester.enterText(entryPriceField, '50000');

      final saveButton = find.text('Save Entry');
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // assert - Should show validation error for quantity
      expect(find.text('Please enter quantity'), findsOneWidget);
    });

    testWidgets('P&L auto-calculates for long position', (tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Fill required fields
      await tester.enterText(
          find.widgetWithText(TextField, 'Symbol *'), 'BTCUSDT');
      await tester.enterText(
          find.widgetWithText(TextField, 'Entry Price *'), '50000');
      await tester.enterText(
          find.widgetWithText(TextField, 'Exit Price'), '55000');
      await tester.enterText(find.widgetWithText(TextField, 'Quantity *'), '1');

      await tester.pumpAndSettle();

      // assert - P&L should be calculated
      // Long: (55000 - 50000) * 1 = 5000
      expect(find.text('5000.0'), findsAtLeastNWidgets(1));
    });

    testWidgets('P&L auto-calculates for short position', (tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Select short side
      final sideSegment = find.text('Short');
      await tester.tap(sideSegment);
      await tester.pumpAndSettle();

      // Fill required fields
      await tester.enterText(
          find.widgetWithText(TextField, 'Symbol *'), 'BTCUSDT');
      await tester.enterText(
          find.widgetWithText(TextField, 'Entry Price *'), '50000');
      await tester.enterText(
          find.widgetWithText(TextField, 'Exit Price'), '45000');
      await tester.enterText(find.widgetWithText(TextField, 'Quantity *'), '1');

      await tester.pumpAndSettle();

      // assert - P&L should be calculated
      // Short: -(45000 - 50000) * 1 = 5000
      expect(find.text('5000.0'), findsAtLeastNWidgets(1));
    });

    testWidgets('trade side selector works', (tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Find and tap short selector
      final shortSegment = find.text('Short');
      expect(shortSegment, findsOneWidget);

      await tester.tap(shortSegment);
      await tester.pumpAndSettle();

      // assert - Short should be selected
      // This would be verified by the UI state, but we can at least verify it's tappable
      expect(shortSegment, findsOneWidget);
    });

    testWidgets('emotion picker exists', (tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert - Emotion dropdown should exist
      expect(find.byType(DropdownButton<TradeEmotion>), findsOneWidget);
    });

    testWidgets('save button calls JournalEntryAdded for new entry',
        (tester) async {
      // arrange
      when(() => mockJournalBloc.state)
          .thenReturn(const JournalEntrySuccess('Entry added'));

      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Fill form
      await tester.enterText(
          find.widgetWithText(TextField, 'Symbol *'), 'BTCUSDT');
      await tester.enterText(
          find.widgetWithText(TextField, 'Entry Price *'), '50000');
      await tester.enterText(find.widgetWithText(TextField, 'Quantity *'), '1');
      await tester.pumpAndSettle();

      // Tap save
      final saveButton = find.text('Save Entry');
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // assert - Should add entry event
      verify(() => mockJournalBloc.add(any(that: isA<JournalEntryAdded>())))
          .called(1);
    });

    testWidgets('save button calls JournalEntryUpdated for existing entry',
        (tester) async {
      // arrange
      final entry = JournalEntry(
        id: 1,
        symbol: 'BTCUSDT',
        side: TradeSide.long,
        entryPrice: 50000.0,
        quantity: 1.0,
        emotion: TradeEmotion.confident,
        entryDate: DateTime(2024, 1, 1),
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );
      when(() => mockJournalBloc.state)
          .thenReturn(const JournalEntrySuccess('Entry updated'));

      // act
      await tester.pumpWidget(createWidgetUnderTest(entry: entry));
      await tester.pumpAndSettle();

      // Modify a field
      final symbolField = find.widgetWithText(TextField, 'Symbol *');
      await tester.enterText(symbolField, 'ETHUSDT');
      await tester.pumpAndSettle();

      // Tap save
      final saveButton = find.text('Save Entry');
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // assert - Should update entry event
      verify(() => mockJournalBloc.add(any(that: isA<JournalEntryUpdated>())))
          .called(1);
    });

    testWidgets('P&L percentage updates automatically', (tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Fill required fields
      await tester.enterText(
          find.widgetWithText(TextField, 'Symbol *'), 'BTCUSDT');
      await tester.enterText(
          find.widgetWithText(TextField, 'Entry Price *'), '50000');
      await tester.enterText(
          find.widgetWithText(TextField, 'Exit Price'), '55000');
      await tester.enterText(find.widgetWithText(TextField, 'Quantity *'), '1');

      await tester.pumpAndSettle();

      // assert - P&L percentage should be calculated
      // (55000 - 50000) / 50000 * 100 = 10%
      expect(find.text('10.0%'), findsAtLeastNWidgets(1));
    });

    testWidgets('entry date picker exists', (tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert - Entry date field should exist
      expect(find.text('Entry Date'), findsOneWidget);
    });

    testWidgets('exit date picker exists', (tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert - Exit date field should exist
      expect(find.text('Exit Date'), findsOneWidget);
    });

    testWidgets('notes field exists', (tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert - Notes field should exist
      expect(find.text('Notes'), findsOneWidget);
    });

    testWidgets('strategy field exists', (tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert - Strategy field should exist
      expect(find.text('Strategy'), findsOneWidget);
    });

    testWidgets('handles negative P&L correctly', (tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Fill required fields for a losing trade
      await tester.enterText(
          find.widgetWithText(TextField, 'Symbol *'), 'BTCUSDT');
      await tester.enterText(
          find.widgetWithText(TextField, 'Entry Price *'), '50000');
      await tester.enterText(
          find.widgetWithText(TextField, 'Exit Price'), '45000');
      await tester.enterText(find.widgetWithText(TextField, 'Quantity *'), '1');

      await tester.pumpAndSettle();

      // assert - P&L should be negative
      // Long: (45000 - 50000) * 1 = -5000
      expect(find.text('-5000.0'), findsAtLeastNWidgets(1));
    });

    testWidgets('handles decimal quantities', (tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Fill required fields with decimal quantity
      await tester.enterText(
          find.widgetWithText(TextField, 'Symbol *'), 'BTCUSDT');
      await tester.enterText(
          find.widgetWithText(TextField, 'Entry Price *'), '50000');
      await tester.enterText(
          find.widgetWithText(TextField, 'Exit Price'), '55000');
      await tester.enterText(
          find.widgetWithText(TextField, 'Quantity *'), '0.5');

      await tester.pumpAndSettle();

      // assert - P&L should account for decimal quantity
      // (55000 - 50000) * 0.5 = 2500
      expect(find.text('2500.0'), findsAtLeastNWidgets(1));
    });
  });
}
