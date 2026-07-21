import 'package:bloc_test/bloc_test.dart';
import 'package:core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:market/market.dart';
import 'package:market_3d/market_3d.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/candle_fixtures.dart';

class _MockMarketRepository extends Mock implements MarketRepository {}

void main() {
  late _MockMarketRepository mockRepository;
  late GetCandlesUseCase getCandlesUseCase;

  setUp(() {
    mockRepository = _MockMarketRepository();
    getCandlesUseCase = GetCandlesUseCase(mockRepository);
  });

  List<Candle> threeCandles() => [
        candleAt(0, open: 100, high: 106, low: 98, close: 104),
        candleAt(1, open: 104, high: 112, low: 103, close: 110),
        candleAt(2, open: 110, high: 118, low: 108, close: 109),
      ];

  Market3DBloc buildBloc() =>
      Market3DBloc(getCandlesUseCase: getCandlesUseCase);

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
}
