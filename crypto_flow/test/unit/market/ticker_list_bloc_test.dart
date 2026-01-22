import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:core/error/failures.dart';
import 'package:core/network/websocket_client.dart';
import 'package:market/presentation/bloc/ticker_list/ticker_list_bloc.dart';
import 'package:market/presentation/bloc/ticker_list/ticker_list_event.dart';
import 'package:market/presentation/bloc/ticker_list/ticker_list_state.dart';

import '../../fixtures/ticker_fixtures.dart';
import '../../mocks/mocks.dart';

void main() {
  late TickerListBloc bloc;
  late MockMarketRepository mockMarketRepository;
  late MockWebSocketRepository mockWsRepository;

  setUp(() {
    mockMarketRepository = MockMarketRepository();
    mockWsRepository = MockWebSocketRepository();
    bloc = TickerListBloc(
      marketRepository: mockMarketRepository,
      wsRepository: mockWsRepository,
    );

    // Register fallback values
    registerFallbackValues();
  });

  tearDown(() {
    bloc.close();
  });

  group('TickerListBloc', () {
    test('initial state is TickerListInitial', () {
      expect(bloc.state, isA<TickerListInitial>());
    });

    group('LoadTickers', () {
      blocTest<TickerListBloc, TickerListState>(
        'emits [Loading, Loaded] when LoadTickers succeeds',
        build: () {
          when(() => mockMarketRepository.getAllTickers()).thenAnswer(
              (_) async => const Right(TickerFixtures.mockTickerList));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadTickers()),
        expect: () => [
          isA<TickerListLoading>(),
          isA<TickerListLoaded>()
              .having((s) => s.tickers.length, 'ticker count', 4),
        ],
      );

      blocTest<TickerListBloc, TickerListState>(
        'emits [Loading, Error] when LoadTickers fails',
        build: () {
          when(() => mockMarketRepository.getAllTickers()).thenAnswer(
              (_) async => const Left(ServerFailure(message: 'Server error')));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadTickers()),
        expect: () => [
          isA<TickerListLoading>(),
          isA<TickerListError>()
              .having((s) => s.message, 'error message', 'Server error'),
        ],
      );
    });

    group('SubscribeToTickers', () {
      blocTest<TickerListBloc, TickerListState>(
        'updates tickers when WebSocket stream emits',
        build: () {
          when(() => mockWsRepository.getAllMiniTickersStream()).thenAnswer(
              (_) => Stream.value(const Right(TickerFixtures.mockTickerList)));
          when(() => mockWsRepository.statusStream)
              .thenAnswer((_) => Stream.value(WebSocketStatus.connected));
          return bloc;
        },
        act: (bloc) => bloc.add(const SubscribeToTickers()),
        wait: const Duration(milliseconds: 200), // Increased for batching
        expect: () => [
          isA<TickerListLoaded>()
              .having((s) => s.tickers.length, 'ticker count', 4),
        ],
      );

      blocTest<TickerListBloc, TickerListState>(
        'handles WebSocket errors gracefully',
        build: () {
          when(() => mockWsRepository.getAllMiniTickersStream())
              .thenAnswer((_) => Stream.value(Left(WebSocketFailure(
                    type: WebSocketFailureType.connectionLost,
                    message: 'Connection lost',
                  ))));
          when(() => mockWsRepository.statusStream)
              .thenAnswer((_) => Stream.value(WebSocketStatus.error));
          return bloc;
        },
        act: (bloc) => bloc.add(const SubscribeToTickers()),
        wait: const Duration(milliseconds: 100),
        expect: () => [
          isA<TickerListError>()
              .having((s) => s.message, 'error', 'Connection lost'),
        ],
      );
    });

    group('FilterTickers', () {
      blocTest<TickerListBloc, TickerListState>(
        'filters tickers by USDT quote asset',
        build: () {
          when(() => mockMarketRepository.getAllTickers()).thenAnswer(
              (_) async => const Right(TickerFixtures.mockTickerList));
          return bloc;
        },
        act: (bloc) async {
          bloc.add(const LoadTickers());
          await Future.delayed(const Duration(milliseconds: 100));
          bloc.add(const FilterTickers(quoteAsset: 'USDT'));
        },
        wait: const Duration(milliseconds: 200),
        expect: () => [
          isA<TickerListLoading>(),
          isA<TickerListLoaded>(),
          isA<TickerListLoaded>().having(
            (s) => s.filteredTickers.every((t) => t.quoteAsset == 'USDT'),
            'all USDT pairs',
            true,
          ),
        ],
      );

      blocTest<TickerListBloc, TickerListState>(
        'sorts tickers by price',
        build: () {
          when(() => mockMarketRepository.getAllTickers()).thenAnswer(
              (_) async => const Right(TickerFixtures.mockTickerList));
          return bloc;
        },
        act: (bloc) async {
          bloc.add(const LoadTickers());
          await Future.delayed(const Duration(milliseconds: 100));
          bloc.add(
              const FilterTickers(sortBy: TickerSortBy.price, ascending: true));
        },
        wait: const Duration(milliseconds: 200),
        expect: () => [
          isA<TickerListLoading>(),
          isA<TickerListLoaded>(),
          isA<TickerListLoaded>().having(
            (s) => s.sortBy,
            'sort by',
            TickerSortBy.price,
          ),
        ],
      );
    });

    group('SearchTickers', () {
      blocTest<TickerListBloc, TickerListState>(
        'filters tickers by search query',
        build: () {
          when(() => mockMarketRepository.getAllTickers()).thenAnswer(
              (_) async => const Right(TickerFixtures.mockTickerList));
          return bloc;
        },
        act: (bloc) async {
          bloc.add(const LoadTickers());
          await Future.delayed(const Duration(milliseconds: 100));
          bloc.add(const SearchTickers('BTC'));
        },
        wait: const Duration(milliseconds: 200),
        expect: () => [
          isA<TickerListLoading>(),
          isA<TickerListLoaded>(),
          isA<TickerListLoaded>().having(
            (s) => s.filteredTickers.every(
                (t) => t.symbol.contains('BTC') || t.baseAsset.contains('BTC')),
            'all contain BTC',
            true,
          ),
        ],
      );
    });

    group('ClearSearch', () {
      blocTest<TickerListBloc, TickerListState>(
        'restores all tickers when search is cleared',
        build: () {
          when(() => mockMarketRepository.getAllTickers()).thenAnswer(
              (_) async => const Right(TickerFixtures.mockTickerList));
          return bloc;
        },
        act: (bloc) async {
          bloc.add(const LoadTickers());
          await Future.delayed(const Duration(milliseconds: 100));
          bloc.add(const SearchTickers('BTC'));
          await Future.delayed(const Duration(milliseconds: 100));
          bloc.add(const ClearSearch());
        },
        wait: const Duration(milliseconds: 300),
        expect: () => [
          isA<TickerListLoading>(),
          isA<TickerListLoaded>(),
          isA<TickerListLoaded>(), // After search
          isA<TickerListLoaded>().having(
            (s) => s.searchQuery,
            'search query cleared',
            isNull,
          ),
        ],
      );
    });

    group('TickerConnectionError', () {
      blocTest<TickerListBloc, TickerListState>(
        'keeps cached data when error occurs in loaded state',
        build: () {
          when(() => mockMarketRepository.getAllTickers()).thenAnswer(
              (_) async => const Right(TickerFixtures.mockTickerList));
          return bloc;
        },
        seed: () => const TickerListLoaded(
          tickers: TickerFixtures.mockTickerList,
          filteredTickers: TickerFixtures.mockTickerList,
        ),
        act: (bloc) => bloc.add(const TickerConnectionError('Connection lost')),
        expect: () => [
          isA<TickerListLoaded>().having(
            (s) => s.connectionStatus,
            'connection status',
            WebSocketStatus.error,
          ),
        ],
      );

      blocTest<TickerListBloc, TickerListState>(
        'emits error state when not loaded',
        build: () => bloc,
        act: (bloc) =>
            bloc.add(const TickerConnectionError('Connection failed')),
        expect: () => [
          isA<TickerListError>()
              .having((s) => s.message, 'message', 'Connection failed'),
        ],
      );
    });
  });
}
