import 'package:bloc_test/bloc_test.dart';
import 'package:core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portfolio/domain/entities/journal_entry.dart';
import 'package:portfolio/domain/entities/trade_emotion.dart';
import 'package:portfolio/domain/entities/trade_side.dart';
import 'package:portfolio/domain/repositories/journal_repository.dart';
import 'package:portfolio/domain/usecases/add_journal_entry.dart';
import 'package:portfolio/domain/usecases/delete_journal_entry.dart';
import 'package:portfolio/domain/usecases/get_journal_entries.dart';
import 'package:portfolio/domain/usecases/update_journal_entry.dart';
import 'package:portfolio/presentation/bloc/journal/journal_bloc.dart';
import 'package:portfolio/presentation/bloc/journal/journal_event.dart';
import 'package:portfolio/presentation/bloc/journal/journal_filter.dart';
import 'package:portfolio/presentation/bloc/journal/journal_sort.dart';
import 'package:portfolio/presentation/bloc/journal/journal_state.dart';

// Mock classes
class MockGetJournalEntries extends Mock implements GetJournalEntries {}

class MockAddJournalEntry extends Mock implements AddJournalEntry {}

class MockUpdateJournalEntry extends Mock implements UpdateJournalEntry {}

class MockDeleteJournalEntry extends Mock implements DeleteJournalEntry {}

class MockJournalRepository extends Mock implements JournalRepository {}

// Fake classes for non-primitive arguments
class FakeGetJournalEntriesParams extends Fake
    implements GetJournalEntriesParams {}

class FakeAddJournalEntryParams extends Fake implements AddJournalEntryParams {}

class FakeUpdateJournalEntryParams extends Fake
    implements UpdateJournalEntryParams {}

class FakeDeleteJournalEntryParams extends Fake
    implements DeleteJournalEntryParams {}

void main() {
  late JournalBloc bloc;
  late MockGetJournalEntries mockGetJournalEntries;
  late MockAddJournalEntry mockAddJournalEntry;
  late MockUpdateJournalEntry mockUpdateJournalEntry;
  late MockDeleteJournalEntry mockDeleteJournalEntry;
  late MockJournalRepository mockRepository;

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

  setUpAll(() {
    registerFallbackValue(FakeGetJournalEntriesParams());
    registerFallbackValue(FakeAddJournalEntryParams());
    registerFallbackValue(FakeUpdateJournalEntryParams());
    registerFallbackValue(FakeDeleteJournalEntryParams());
  });

  setUp(() {
    mockGetJournalEntries = MockGetJournalEntries();
    mockAddJournalEntry = MockAddJournalEntry();
    mockUpdateJournalEntry = MockUpdateJournalEntry();
    mockDeleteJournalEntry = MockDeleteJournalEntry();
    mockRepository = MockJournalRepository();

    // Mock the stream to prevent errors
    when(() => mockRepository.watchEntries())
        .thenAnswer((_) => Stream.value(testEntries));

    bloc = JournalBloc(
      getJournalEntries: mockGetJournalEntries,
      addJournalEntry: mockAddJournalEntry,
      updateJournalEntry: mockUpdateJournalEntry,
      deleteJournalEntry: mockDeleteJournalEntry,
      repository: mockRepository,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('JournalBloc', () {
    test('initial state is JournalInitial', () {
      expect(bloc.state, equals(const JournalInitial()));
    });

    group('JournalEntriesRequested', () {
      blocTest<JournalBloc, JournalState>(
        'emits [JournalLoading, JournalLoaded] when entries are loaded successfully',
        build: () {
          when(() => mockGetJournalEntries(any()))
              .thenAnswer((_) async => Right(testEntries));
          return bloc;
        },
        act: (bloc) => bloc.add(const JournalEntriesRequested()),
        expect: () => [
          const JournalLoading(),
          isA<JournalLoaded>()
              .having((s) => s.entries.length, 'entries length', 2)
              .having((s) => s.totalCount, 'total count', 2),
        ],
        verify: (_) {
          verify(() => mockGetJournalEntries(any())).called(1);
        },
      );

      blocTest<JournalBloc, JournalState>(
        'emits [JournalLoading, JournalError] when loading fails',
        build: () {
          when(() => mockGetJournalEntries(any())).thenAnswer(
              (_) async => const Left(CacheFailure(message: 'Error')));
          return bloc;
        },
        act: (bloc) => bloc.add(const JournalEntriesRequested()),
        expect: () => [
          const JournalLoading(),
          const JournalError('Error'),
        ],
      );

      blocTest<JournalBloc, JournalState>(
        'filters entries by symbol',
        build: () {
          when(() => mockGetJournalEntries(any()))
              .thenAnswer((_) async => Right(testEntries));
          return bloc;
        },
        act: (bloc) =>
            bloc.add(const JournalEntriesRequested(symbol: 'BTCUSDT')),
        verify: (_) {
          verify(() => mockGetJournalEntries(
                any(
                    that: predicate<GetJournalEntriesParams>(
                        (p) => p.symbol == 'BTCUSDT')),
              )).called(1);
        },
      );

      blocTest<JournalBloc, JournalState>(
        'filters entries by side',
        build: () {
          when(() => mockGetJournalEntries(any()))
              .thenAnswer((_) async => Right(testEntries));
          return bloc;
        },
        act: (bloc) =>
            bloc.add(const JournalEntriesRequested(side: TradeSide.long)),
        verify: (_) {
          verify(() => mockGetJournalEntries(
                any(
                    that: predicate<GetJournalEntriesParams>(
                        (p) => p.side == TradeSide.long)),
              )).called(1);
        },
      );
    });

    group('JournalEntryAdded', () {
      blocTest<JournalBloc, JournalState>(
        'emits [JournalEntrySuccess] and reloads entries on success',
        build: () {
          when(() => mockAddJournalEntry(any()))
              .thenAnswer((_) async => const Right(1));
          when(() => mockGetJournalEntries(any()))
              .thenAnswer((_) async => Right(testEntries));
          return bloc;
        },
        act: (bloc) => bloc.add(JournalEntryAdded(testEntries[0])),
        expect: () => [
          const JournalEntrySuccess('Entry added successfully'),
          const JournalLoading(),
          isA<JournalLoaded>(),
        ],
        verify: (_) {
          verify(() => mockAddJournalEntry(any())).called(1);
          verify(() => mockGetJournalEntries(any())).called(1);
        },
      );

      blocTest<JournalBloc, JournalState>(
        'emits [JournalError] when add fails',
        build: () {
          when(() => mockAddJournalEntry(any())).thenAnswer(
              (_) async => const Left(CacheFailure(message: 'Failed to add')));
          return bloc;
        },
        act: (bloc) => bloc.add(JournalEntryAdded(testEntries[0])),
        expect: () => [
          const JournalError('Failed to add'),
        ],
      );
    });

    group('JournalEntryUpdated', () {
      blocTest<JournalBloc, JournalState>(
        'emits [JournalEntrySuccess] and reloads entries on success',
        build: () {
          when(() => mockUpdateJournalEntry(any()))
              .thenAnswer((_) async => const Right(null));
          when(() => mockGetJournalEntries(any()))
              .thenAnswer((_) async => Right(testEntries));
          return bloc;
        },
        act: (bloc) => bloc.add(JournalEntryUpdated(testEntries[0])),
        expect: () => [
          const JournalEntrySuccess('Entry updated successfully'),
          const JournalLoading(),
          isA<JournalLoaded>(),
        ],
        verify: (_) {
          verify(() => mockUpdateJournalEntry(any())).called(1);
          verify(() => mockGetJournalEntries(any())).called(1);
        },
      );

      blocTest<JournalBloc, JournalState>(
        'emits [JournalError] when update fails',
        build: () {
          when(() => mockUpdateJournalEntry(any())).thenAnswer((_) async =>
              const Left(CacheFailure(message: 'Failed to update')));
          return bloc;
        },
        act: (bloc) => bloc.add(JournalEntryUpdated(testEntries[0])),
        expect: () => [
          const JournalError('Failed to update'),
        ],
      );
    });

    group('JournalEntryDeleted', () {
      blocTest<JournalBloc, JournalState>(
        'emits [JournalEntrySuccess] and reloads entries on success',
        build: () {
          when(() => mockDeleteJournalEntry(any()))
              .thenAnswer((_) async => const Right(null));
          when(() => mockGetJournalEntries(any()))
              .thenAnswer((_) async => Right(testEntries));
          return bloc;
        },
        act: (bloc) => bloc.add(const JournalEntryDeleted(1)),
        expect: () => [
          const JournalEntrySuccess('Entry deleted successfully'),
          const JournalLoading(),
          isA<JournalLoaded>(),
        ],
        verify: (_) {
          verify(() => mockDeleteJournalEntry(any())).called(1);
          verify(() => mockGetJournalEntries(any())).called(1);
        },
      );
    });

    group('JournalSearched', () {
      blocTest<JournalBloc, JournalState>(
        'emits [JournalLoading, JournalLoaded] with search results',
        build: () {
          when(() => mockRepository.searchEntries(any()))
              .thenAnswer((_) async => Right(testEntries));
          return bloc;
        },
        act: (bloc) => bloc.add(const JournalSearched('BTC')),
        expect: () => [
          const JournalLoading(),
          isA<JournalLoaded>(),
        ],
        verify: (_) {
          verify(() => mockRepository.searchEntries('BTC')).called(1);
        },
      );

      blocTest<JournalBloc, JournalState>(
        'triggers JournalEntriesRequested when query is empty',
        build: () {
          when(() => mockGetJournalEntries(any()))
              .thenAnswer((_) async => Right(testEntries));
          return bloc;
        },
        act: (bloc) => bloc.add(const JournalSearched('')),
        expect: () => [
          const JournalLoading(),
          isA<JournalLoaded>(),
        ],
        verify: (_) {
          verify(() => mockGetJournalEntries(any())).called(1);
        },
      );
    });

    group('JournalFilterChanged', () {
      blocTest<JournalBloc, JournalState>(
        'emits [JournalLoading, JournalLoaded] with filtered entries',
        build: () {
          when(() => mockGetJournalEntries(any()))
              .thenAnswer((_) async => Right(testEntries));
          return bloc;
        },
        act: (bloc) => bloc.add(
          JournalFilterChanged(
            JournalFilter(symbol: 'BTCUSDT'),
          ),
        ),
        expect: () => [
          const JournalLoading(),
          isA<JournalLoaded>(),
        ],
      );

      blocTest<JournalBloc, JournalState>(
        'filters by emotion (client-side)',
        build: () {
          when(() => mockGetJournalEntries(any()))
              .thenAnswer((_) async => Right(testEntries));
          return bloc;
        },
        act: (bloc) => bloc.add(
          JournalFilterChanged(
            JournalFilter(emotion: TradeEmotion.confident),
          ),
        ),
        expect: () => [
          const JournalLoading(),
          isA<JournalLoaded>()
              .having((s) => s.entries.length, 'entries length', 1)
              .having(
                (s) => s.entries.first.emotion,
                'first entry emotion',
                TradeEmotion.confident,
              ),
        ],
      );

      blocTest<JournalBloc, JournalState>(
        'filters by tags (client-side)',
        build: () {
          when(() => mockGetJournalEntries(any()))
              .thenAnswer((_) async => Right(testEntries));
          return bloc;
        },
        act: (bloc) => bloc.add(
          JournalFilterChanged(
            JournalFilter(tags: ['breakout']),
          ),
        ),
        expect: () => [
          const JournalLoading(),
          isA<JournalLoaded>()
              .having((s) => s.entries.length, 'entries length', 1)
              .having(
                (s) => s.entries.first.tags,
                'first entry tags',
                contains('breakout'),
              ),
        ],
      );

      blocTest<JournalBloc, JournalState>(
        'filters wins only',
        build: () {
          when(() => mockGetJournalEntries(any()))
              .thenAnswer((_) async => Right(testEntries));
          return bloc;
        },
        act: (bloc) => bloc.add(
          JournalFilterChanged(
            JournalFilter(onlyWins: true),
          ),
        ),
        expect: () => [
          const JournalLoading(),
          isA<JournalLoaded>().having(
            (s) => s.entries.every((e) => (e.pnl ?? 0) > 0),
            'all entries are wins',
            isTrue,
          ),
        ],
      );

      blocTest<JournalBloc, JournalState>(
        'filters losses only',
        build: () {
          when(() => mockGetJournalEntries(any()))
              .thenAnswer((_) async => Right(testEntries));
          return bloc;
        },
        act: (bloc) => bloc.add(
          JournalFilterChanged(
            JournalFilter(onlyLosses: true),
          ),
        ),
        expect: () => [
          const JournalLoading(),
          isA<JournalLoaded>().having(
            (s) => s.entries.isEmpty,
            'no losses in test data',
            isTrue,
          ),
        ],
      );
    });

    group('JournalSortChanged', () {
      blocTest<JournalBloc, JournalState>(
        'sorts by date descending',
        build: () {
          when(() => mockGetJournalEntries(any()))
              .thenAnswer((_) async => Right(testEntries));
          return bloc;
        },
        seed: () => JournalLoaded(
          entries: testEntries,
          filter: const JournalFilter.empty(),
          sort: JournalSort.dateAsc,
          totalCount: testEntries.length,
        ),
        act: (bloc) => bloc.add(const JournalSortChanged(JournalSort.dateDesc)),
        expect: () => [
          isA<JournalLoaded>()
              .having((s) => s.sort, 'sort', JournalSort.dateDesc)
              .having(
                (s) => s.entries.first.id,
                'first entry id',
                2, // Newer entry first
              ),
        ],
      );

      blocTest<JournalBloc, JournalState>(
        'sorts by P&L descending',
        build: () {
          when(() => mockGetJournalEntries(any()))
              .thenAnswer((_) async => Right(testEntries));
          return bloc;
        },
        seed: () => JournalLoaded(
          entries: testEntries,
          filter: const JournalFilter.empty(),
          sort: JournalSort.dateDesc,
          totalCount: testEntries.length,
        ),
        act: (bloc) => bloc.add(const JournalSortChanged(JournalSort.pnlDesc)),
        expect: () => [
          isA<JournalLoaded>()
              .having((s) => s.sort, 'sort', JournalSort.pnlDesc)
              .having(
                (s) => s.entries.first.pnl,
                'first entry pnl',
                5000.0, // Highest P&L first
              ),
        ],
      );

      blocTest<JournalBloc, JournalState>(
        'sorts by P&L ascending',
        build: () {
          when(() => mockGetJournalEntries(any()))
              .thenAnswer((_) async => Right(testEntries));
          return bloc;
        },
        seed: () => JournalLoaded(
          entries: testEntries,
          filter: const JournalFilter.empty(),
          sort: JournalSort.dateDesc,
          totalCount: testEntries.length,
        ),
        act: (bloc) => bloc.add(const JournalSortChanged(JournalSort.pnlAsc)),
        expect: () => [
          isA<JournalLoaded>()
              .having((s) => s.sort, 'sort', JournalSort.pnlAsc)
              .having(
                (s) => s.entries.first.pnl,
                'first entry pnl',
                400.0, // Lowest P&L first
              ),
        ],
      );
    });

    group('Error Scenarios', () {
      blocTest<JournalBloc, JournalState>(
        'handles repository failures gracefully',
        build: () {
          when(() => mockGetJournalEntries(any())).thenAnswer(
            (_) async => const Left(CacheFailure(message: 'Database error')),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(const JournalEntriesRequested()),
        expect: () => [
          const JournalLoading(),
          const JournalError('Database error'),
        ],
      );

      blocTest<JournalBloc, JournalState>(
        'handles search failures',
        build: () {
          when(() => mockRepository.searchEntries(any())).thenAnswer(
            (_) async => const Left(CacheFailure(message: 'Search failed')),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(const JournalSearched('BTC')),
        expect: () => [
          const JournalLoading(),
          const JournalError('Search failed'),
        ],
      );
    });

    group('Stream Updates', () {
      blocTest<JournalBloc, JournalState>(
        'reloads entries when stream emits update',
        build: () {
          when(() => mockGetJournalEntries(any()))
              .thenAnswer((_) async => Right(testEntries));
          return bloc;
        },
        act: (bloc) => bloc.add(const JournalEntriesUpdated()),
        expect: () => [
          const JournalLoading(),
          isA<JournalLoaded>(),
        ],
      );
    });
  });
}
