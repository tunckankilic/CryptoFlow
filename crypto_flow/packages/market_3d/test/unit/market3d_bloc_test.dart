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
  late StreamController<Either<Failure, Candle>> candleStreamController;

  setUp(() {
    mockRepository = _MockMarketRepository();
    mockWsRepository = _MockWebSocketRepository();
    getCandlesUseCase = GetCandlesUseCase(mockRepository);
    getCandleStreamUseCase = GetCandleStreamUseCase(mockWsRepository);

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
}
