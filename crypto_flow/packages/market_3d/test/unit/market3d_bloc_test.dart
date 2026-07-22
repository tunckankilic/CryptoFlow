import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:market/market.dart';
import 'package:market_3d/market_3d.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/candle_fixtures.dart';

class _MockMarketRepository extends Mock implements MarketRepository {}

class _MockWebSocketRepository extends Mock implements WebSocketRepository {}

void main() {
  late _MockMarketRepository mockRepository;
  late _MockWebSocketRepository mockWsRepository;
  late GetCandlesUseCase getCandlesUseCase;
  late GetCandleStreamUseCase getCandleStreamUseCase;
  late GetOrderBookUseCase getOrderBookUseCase;
  late StreamController<Either<Failure, Candle>> candleStreamController;

  setUp(() {
    mockRepository = _MockMarketRepository();
    mockWsRepository = _MockWebSocketRepository();
    getCandlesUseCase = GetCandlesUseCase(mockRepository);
    getCandleStreamUseCase = GetCandleStreamUseCase(mockWsRepository);
    getOrderBookUseCase = GetOrderBookUseCase(mockRepository);

    candleStreamController = StreamController<Either<Failure, Candle>>();
    when(() => mockWsRepository.getCandleStream(any(), any()))
        .thenAnswer((_) => candleStreamController.stream);
  });

  tearDown(() {
    // Not awaited: a single-subscription controller's `close()` future only
    // resolves once something has listened to the stream, which the tests
    // that never subscribe (e.g. the plain load/error cases) never do —
    // awaiting it here would hang every test until the 30s timeout.
    candleStreamController.close();
  });

  List<Candle> threeCandles() => [
        candleAt(0, open: 100, high: 106, low: 98, close: 104),
        candleAt(1, open: 104, high: 112, low: 103, close: 110),
        candleAt(2, open: 110, high: 118, low: 108, close: 109),
      ];

  Market3DBloc buildBloc() => Market3DBloc(
        getCandlesUseCase: getCandlesUseCase,
        getCandleStreamUseCase: getCandleStreamUseCase,
        getOrderBookUseCase: getOrderBookUseCase,
      );

  void mockCandlesSuccess(List<Candle> candles) {
    when(() => mockRepository.getCandles(
          any(),
          any(),
          limit: any(named: 'limit'),
          startTime: any(named: 'startTime'),
          endTime: any(named: 'endTime'),
        )).thenAnswer((_) async => Right(candles));
  }

  OrderBook testBook() => orderBook(
        bids: [
          [99.0, 2.0],
          [98.0, 3.0],
        ],
        asks: [
          [101.0, 1.0],
          [102.0, 4.0],
        ],
      );

  void mockOrderBookSuccess(OrderBook book) {
    when(() => mockRepository.getOrderBook(any(), limit: any(named: 'limit')))
        .thenAnswer((_) async => Right(book));
  }

  test('initial state is Market3DInitial', () {
    expect(buildBloc().state, isA<Market3DInitial>());
  });

  group('LoadMarket3DCandles', () {
    blocTest<Market3DBloc, Market3DState>(
      'emits [Loading, Loaded] with one adapted block per candle on success',
      build: () {
        when(() => mockRepository.getCandles(
              any(),
              any(),
              limit: any(named: 'limit'),
              startTime: any(named: 'startTime'),
              endTime: any(named: 'endTime'),
            )).thenAnswer((_) async => Right(threeCandles()));
        return buildBloc();
      },
      act: (bloc) => bloc.add(
        const LoadMarket3DCandles(symbol: 'BTCUSDT', interval: '1m'),
      ),
      expect: () => [
        isA<Market3DLoading>(),
        isA<Market3DLoaded>()
            .having((s) => s.symbol, 'symbol', 'BTCUSDT')
            .having((s) => s.blockCount, 'block count', 3)
            .having(
              (s) => s.blocks.map((b) => b.index),
              'block indices',
              [0, 1, 2],
            ),
      ],
    );

    blocTest<Market3DBloc, Market3DState>(
      'emits [Loading, Error] when the use case fails',
      build: () {
        when(() => mockRepository.getCandles(
              any(),
              any(),
              limit: any(named: 'limit'),
              startTime: any(named: 'startTime'),
              endTime: any(named: 'endTime'),
            )).thenAnswer(
                (_) async => const Left(ServerFailure(message: 'boom')));
        return buildBloc();
      },
      act: (bloc) => bloc.add(
        const LoadMarket3DCandles(symbol: 'BTCUSDT', interval: '1m'),
      ),
      expect: () => [
        isA<Market3DLoading>(),
        isA<Market3DError>().having((s) => s.message, 'message', 'boom'),
      ],
    );
  });

  group('live updates', () {
    blocTest<Market3DBloc, Market3DState>(
      'still ends up live when Subscribe is dispatched before Load resolves '
      '(Market3DPage fires both from initState with no gap between them)',
      build: () {
        mockCandlesSuccess(threeCandles());
        return buildBloc();
      },
      act: (bloc) {
        // No await between these two adds — this is the exact ordering
        // `Market3DPage.initState` uses, and the bug this regression test
        // guards: the REST call behind LoadMarket3DCandles hasn't resolved
        // yet when SubscribeToMarket3DStream is handled, so there is no
        // Market3DLoaded state yet for `_onSubscribe` to mark live.
        //
        // Exactly how the two handlers interleave from here is an
        // implementation detail of bloc's default concurrent event
        // transformer, not something worth pinning down — either
        // `_onLoadCandles` sees `_isLive` already true and emits it
        // directly, or `_onSubscribe` corrects an already-loaded state
        // afterwards. Only the end state matters, checked in `verify`.
        bloc.add(
          const LoadMarket3DCandles(symbol: 'BTCUSDT', interval: '1m'),
        );
        bloc.add(
          const SubscribeToMarket3DStream(symbol: 'BTCUSDT', interval: '1m'),
        );
      },
      verify: (bloc) {
        expect(
          bloc.state,
          isA<Market3DLoaded>().having((s) => s.isLive, 'isLive', true),
        );
      },
    );

    blocTest<Market3DBloc, Market3DState>(
      'marks the series live once subscribed after a successful load',
      build: () {
        mockCandlesSuccess(threeCandles());
        return buildBloc();
      },
      act: (bloc) async {
        bloc.add(
          const LoadMarket3DCandles(symbol: 'BTCUSDT', interval: '1m'),
        );
        await Future.delayed(Duration.zero);
        bloc.add(
          const SubscribeToMarket3DStream(symbol: 'BTCUSDT', interval: '1m'),
        );
      },
      skip: 2,
      expect: () => [
        isA<Market3DLoaded>().having((s) => s.isLive, 'isLive', true),
      ],
    );

    blocTest<Market3DBloc, Market3DState>(
      'mutates the live block in place when the tick stays inside the scale',
      build: () {
        mockCandlesSuccess(threeCandles());
        return buildBloc();
      },
      act: (bloc) async {
        bloc.add(
          const LoadMarket3DCandles(symbol: 'BTCUSDT', interval: '1m'),
        );
        await Future.delayed(Duration.zero);
        bloc.add(
          const SubscribeToMarket3DStream(symbol: 'BTCUSDT', interval: '1m'),
        );
        await Future.delayed(Duration.zero);
        candleStreamController.add(
          Right(candleAt(2, open: 110, high: 119, low: 108, close: 115)),
        );
      },
      skip: 3, // Loading, Loaded, Loaded(isLive: true)
      expect: () => [
        isA<Market3DLoaded>()
            .having((s) => s.blockCount, 'block count', 3)
            .having((s) => s.candles.last.close, 'last candle close', 115)
            .having(
              (s) => s.scene.blocks.last.isLive,
              'last block still live',
              true,
            ),
      ],
    );

    blocTest<Market3DBloc, Market3DState>(
      'appends a new live block and freezes the previous one when a candle opens',
      build: () {
        mockCandlesSuccess(threeCandles());
        return buildBloc();
      },
      act: (bloc) async {
        bloc.add(
          const LoadMarket3DCandles(symbol: 'BTCUSDT', interval: '1m'),
        );
        await Future.delayed(Duration.zero);
        bloc.add(
          const SubscribeToMarket3DStream(symbol: 'BTCUSDT', interval: '1m'),
        );
        await Future.delayed(Duration.zero);
        candleStreamController.add(
          Right(candleAt(3, open: 109, high: 111, low: 107, close: 110)),
        );
      },
      skip: 3,
      expect: () => [
        isA<Market3DLoaded>()
            .having((s) => s.blockCount, 'block count', 4)
            .having(
              (s) => s.scene.blocks[2].isLive,
              'candle 2 frozen',
              false,
            )
            .having(
              (s) => s.scene.blocks[3].isLive,
              'candle 3 live',
              true,
            ),
      ],
    );

    blocTest<Market3DBloc, Market3DState>(
      'rebuilds the whole scene when a tick escapes the current price scale',
      build: () {
        mockCandlesSuccess(threeCandles());
        return buildBloc();
      },
      act: (bloc) async {
        bloc.add(
          const LoadMarket3DCandles(symbol: 'BTCUSDT', interval: '1m'),
        );
        await Future.delayed(Duration.zero);
        bloc.add(
          const SubscribeToMarket3DStream(symbol: 'BTCUSDT', interval: '1m'),
        );
        await Future.delayed(Duration.zero);
        candleStreamController.add(
          Right(candleAt(2, open: 110, high: 130, low: 108, close: 128)),
        );
      },
      skip: 3,
      expect: () => [
        isA<Market3DLoaded>()
            .having((s) => s.blockCount, 'block count', 3)
            .having(
              (s) => s.scene.scale.maxPrice,
              'scale grew to cover the new high',
              greaterThan(119.6),
            ),
      ],
    );

    blocTest<Market3DBloc, Market3DState>(
      'keeps the selected block across a live tick',
      build: () {
        mockCandlesSuccess(threeCandles());
        return buildBloc();
      },
      act: (bloc) async {
        bloc.add(
          const LoadMarket3DCandles(symbol: 'BTCUSDT', interval: '1m'),
        );
        await Future.delayed(Duration.zero);
        bloc.add(
          const SubscribeToMarket3DStream(symbol: 'BTCUSDT', interval: '1m'),
        );
        await Future.delayed(Duration.zero);
        bloc.add(const Market3DBlockSelected(0));
        await Future.delayed(Duration.zero);
        candleStreamController.add(
          Right(candleAt(2, open: 110, high: 119, low: 108, close: 115)),
        );
      },
      skip: 4, // Loading, Loaded, Loaded(live), Loaded(selected)
      expect: () => [
        isA<Market3DLoaded>()
            .having((s) => s.selectedBlockIndex, 'selection survives', 0)
            .having((s) => s.candles.last.close, 'tick applied', 115),
      ],
    );

    blocTest<Market3DBloc, Market3DState>(
      'drops isLive without discarding the rendered city on a stream error',
      build: () {
        mockCandlesSuccess(threeCandles());
        return buildBloc();
      },
      act: (bloc) async {
        bloc.add(
          const LoadMarket3DCandles(symbol: 'BTCUSDT', interval: '1m'),
        );
        await Future.delayed(Duration.zero);
        bloc.add(
          const SubscribeToMarket3DStream(symbol: 'BTCUSDT', interval: '1m'),
        );
        await Future.delayed(Duration.zero);
        candleStreamController.add(const Left(NetworkFailure()));
      },
      skip: 3,
      expect: () => [
        isA<Market3DLoaded>()
            .having((s) => s.isLive, 'isLive', false)
            .having((s) => s.blockCount, 'block count', 3),
      ],
    );
  });

  group('Market3DBlockSelected', () {
    Future<void> loadThen(
      Market3DBloc bloc,
      List<Market3DEvent> events,
    ) async {
      bloc.add(const LoadMarket3DCandles(symbol: 'BTCUSDT', interval: '1m'));
      await Future.delayed(Duration.zero);
      for (final event in events) {
        bloc.add(event);
        await Future.delayed(Duration.zero);
      }
    }

    blocTest<Market3DBloc, Market3DState>(
      'selects the tapped block and exposes its candle',
      build: () {
        mockCandlesSuccess(threeCandles());
        return buildBloc();
      },
      act: (bloc) => loadThen(bloc, [const Market3DBlockSelected(1)]),
      skip: 2,
      expect: () => [
        isA<Market3DLoaded>()
            .having((s) => s.selectedBlockIndex, 'selected index', 1)
            .having((s) => s.selectedCandle?.close, 'selected close', 110),
      ],
    );

    blocTest<Market3DBloc, Market3DState>(
      'clears the selection when the tap misses every candle',
      build: () {
        mockCandlesSuccess(threeCandles());
        return buildBloc();
      },
      act: (bloc) => loadThen(bloc, [
        const Market3DBlockSelected(1),
        const Market3DBlockSelected(null),
      ]),
      skip: 3,
      expect: () => [
        isA<Market3DLoaded>()
            .having((s) => s.selectedBlockIndex, 'selection cleared', null)
            .having((s) => s.selectedCandle, 'no candle', null),
      ],
    );

    blocTest<Market3DBloc, Market3DState>(
      'tapping the selected block again dismisses it',
      build: () {
        mockCandlesSuccess(threeCandles());
        return buildBloc();
      },
      act: (bloc) => loadThen(bloc, [
        const Market3DBlockSelected(2),
        const Market3DBlockSelected(2),
      ]),
      skip: 3,
      expect: () => [
        isA<Market3DLoaded>()
            .having((s) => s.selectedBlockIndex, 'selection cleared', null),
      ],
    );

    blocTest<Market3DBloc, Market3DState>(
      'ignores an index the loaded series does not contain',
      build: () {
        mockCandlesSuccess(threeCandles());
        return buildBloc();
      },
      act: (bloc) => loadThen(bloc, [const Market3DBlockSelected(9)]),
      skip: 2,
      // No emit at all: a stale index with nothing selected changes nothing.
      expect: () => <Market3DState>[],
    );
  });

  group('LoadMarket3DDepth', () {
    blocTest<Market3DBloc, Market3DState>(
      'attaches an adapted depth surface to the loaded state',
      build: () {
        mockCandlesSuccess(threeCandles());
        mockOrderBookSuccess(testBook());
        return buildBloc();
      },
      act: (bloc) async {
        bloc.add(const LoadMarket3DCandles(symbol: 'BTCUSDT', interval: '1m'));
        await Future.delayed(Duration.zero);
        bloc.add(const LoadMarket3DDepth(symbol: 'BTCUSDT'));
      },
      skip: 2,
      expect: () => [
        isA<Market3DLoaded>()
            .having((s) => s.depthSurface?.bids.length, 'bid levels', 2)
            .having((s) => s.depthSurface?.asks.length, 'ask levels', 2)
            .having(
              (s) => s.depthSurface?.maxCumulativeQuantity,
              'deepest side',
              5.0,
            )
            // The city is untouched by an order book fetch.
            .having((s) => s.blockCount, 'block count', 3),
      ],
    );

    blocTest<Market3DBloc, Market3DState>(
      'carries a surface that arrived before the city into the first '
      'loaded state',
      // The session-6 dispatch-order trap, again: `Market3DPage.initState`
      // fires the candle load and the depth load with no gap, and whichever
      // REST call answers first wins. When it is the order book, there is no
      // `Market3DLoaded` to attach the surface to — so it must be held on the
      // bloc and picked up when the city finally loads, not dropped.
      build: () {
        mockOrderBookSuccess(testBook());
        when(() => mockRepository.getCandles(
              any(),
              any(),
              limit: any(named: 'limit'),
              startTime: any(named: 'startTime'),
              endTime: any(named: 'endTime'),
            )).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 20));
          return Right(threeCandles());
        });
        return buildBloc();
      },
      act: (bloc) {
        bloc.add(const LoadMarket3DCandles(symbol: 'BTCUSDT', interval: '1m'));
        bloc.add(const LoadMarket3DDepth(symbol: 'BTCUSDT'));
      },
      wait: const Duration(milliseconds: 50),
      skip: 1,
      expect: () => [
        isA<Market3DLoaded>()
            .having((s) => s.depthSurface, 'surface present', isNotNull)
            .having((s) => s.blockCount, 'block count', 3),
      ],
    );

    blocTest<Market3DBloc, Market3DState>(
      'leaves the city standing when the order book fetch fails',
      build: () {
        mockCandlesSuccess(threeCandles());
        when(() =>
                mockRepository.getOrderBook(any(), limit: any(named: 'limit')))
            .thenAnswer(
                (_) async => const Left(ServerFailure(message: 'book down')));
        return buildBloc();
      },
      act: (bloc) async {
        bloc.add(const LoadMarket3DCandles(symbol: 'BTCUSDT', interval: '1m'));
        await Future.delayed(Duration.zero);
        bloc.add(const LoadMarket3DDepth(symbol: 'BTCUSDT'));
      },
      skip: 2,
      // No emit: the terrain is an addition to the city, so its failure is
      // logged and dropped rather than turned into a Market3DError that would
      // replace a perfectly good city with an error screen.
      expect: () => <Market3DState>[],
    );

    blocTest<Market3DBloc, Market3DState>(
      'keeps the terrain across a live candle tick',
      build: () {
        mockCandlesSuccess(threeCandles());
        mockOrderBookSuccess(testBook());
        return buildBloc();
      },
      act: (bloc) async {
        bloc.add(const LoadMarket3DCandles(symbol: 'BTCUSDT', interval: '1m'));
        await Future.delayed(Duration.zero);
        bloc.add(const LoadMarket3DDepth(symbol: 'BTCUSDT'));
        await Future.delayed(Duration.zero);
        bloc.add(Market3DCandleReceived(
          candleAt(2, open: 110, high: 118, low: 108, close: 117),
        ));
      },
      skip: 3,
      expect: () => [
        isA<Market3DLoaded>()
            .having((s) => s.depthSurface, 'surface survived', isNotNull)
            .having((s) => s.candles.last.close, 'live close', 117),
      ],
    );
  });
}
