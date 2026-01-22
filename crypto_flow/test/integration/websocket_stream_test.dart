import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:core/error/failures.dart';
import 'package:core/network/websocket_client.dart';
import 'package:market/domain/entities/ticker.dart';

import '../fixtures/ticker_fixtures.dart';
import '../mocks/mocks.dart';

void main() {
  group('WebSocket Stream Integration', () {
    late MockWebSocketRepository mockWsRepository;

    setUp(() {
      mockWsRepository = MockWebSocketRepository();
      registerFallbackValues();
    });

    test('receives ticker updates from stream', () async {
      // Arrange
      final controller = StreamController<Either<Failure, List<Ticker>>>();
      when(() => mockWsRepository.getAllMiniTickersStream())
          .thenAnswer((_) => controller.stream);

      // Act
      final stream = mockWsRepository.getAllMiniTickersStream();
      final results = <Either<Failure, List<Ticker>>>[];
      final subscription = stream.listen(results.add);

      // Emit test data
      controller.add(const Right(TickerFixtures.mockTickerList));
      await Future.delayed(const Duration(milliseconds: 50));

      // Assert
      expect(results.length, 1);
      results.first.fold(
        (failure) => fail('Expected success'),
        (tickers) {
          expect(tickers.length, 4);
          expect(tickers.first.symbol, 'BTCUSDT');
        },
      );

      // Cleanup
      await subscription.cancel();
      await controller.close();
    });

    test('handles multiple emissions correctly', () async {
      // Arrange
      final controller = StreamController<Either<Failure, List<Ticker>>>();
      when(() => mockWsRepository.getAllMiniTickersStream())
          .thenAnswer((_) => controller.stream);

      // Act
      final stream = mockWsRepository.getAllMiniTickersStream();
      final results = <Either<Failure, List<Ticker>>>[];
      final subscription = stream.listen(results.add);

      // Emit multiple updates
      controller.add(const Right([TickerFixtures.mockTicker]));
      await Future.delayed(const Duration(milliseconds: 20));
      controller.add(const Right([TickerFixtures.mockEthTicker]));
      await Future.delayed(const Duration(milliseconds: 20));
      controller.add(const Right(TickerFixtures.mockTickerList));
      await Future.delayed(const Duration(milliseconds: 20));

      // Assert
      expect(results.length, 3);

      // Cleanup
      await subscription.cancel();
      await controller.close();
    });

    test('handles stream errors gracefully', () async {
      // Arrange
      final controller = StreamController<Either<Failure, List<Ticker>>>();
      when(() => mockWsRepository.getAllMiniTickersStream())
          .thenAnswer((_) => controller.stream);

      // Act
      final stream = mockWsRepository.getAllMiniTickersStream();
      final results = <Either<Failure, List<Ticker>>>[];
      final subscription = stream.listen(results.add);

      // Emit success then error
      controller.add(const Right(TickerFixtures.mockTickerList));
      await Future.delayed(const Duration(milliseconds: 20));
      controller.add(Left(WebSocketFailure(
        type: WebSocketFailureType.connectionLost,
        message: 'Connection lost',
      )));
      await Future.delayed(const Duration(milliseconds: 20));

      // Assert
      expect(results.length, 2);
      expect(results.first.isRight(), true);
      expect(results.last.isLeft(), true);

      results.last.fold(
        (failure) => expect(failure.message, 'Connection lost'),
        (_) => fail('Expected failure'),
      );

      // Cleanup
      await subscription.cancel();
      await controller.close();
    });

    test('multiple subscriptions receive same data', () async {
      // Arrange
      final controller =
          StreamController<Either<Failure, List<Ticker>>>.broadcast();
      when(() => mockWsRepository.getAllMiniTickersStream())
          .thenAnswer((_) => controller.stream);

      // Act
      final stream = mockWsRepository.getAllMiniTickersStream();
      final results1 = <Either<Failure, List<Ticker>>>[];
      final results2 = <Either<Failure, List<Ticker>>>[];

      final sub1 = stream.listen(results1.add);
      final sub2 = stream.listen(results2.add);

      controller.add(const Right(TickerFixtures.mockTickerList));
      await Future.delayed(const Duration(milliseconds: 50));

      // Assert
      expect(results1.length, 1);
      expect(results2.length, 1);

      // Cleanup
      await sub1.cancel();
      await sub2.cancel();
      await controller.close();
    });

    group('status stream', () {
      test('emits connection status changes', () async {
        // Arrange
        final statusController = StreamController<WebSocketStatus>();
        when(() => mockWsRepository.statusStream)
            .thenAnswer((_) => statusController.stream);

        // Act
        final statuses = <WebSocketStatus>[];
        final subscription = mockWsRepository.statusStream.listen(statuses.add);

        statusController.add(WebSocketStatus.connecting);
        await Future.delayed(const Duration(milliseconds: 20));
        statusController.add(WebSocketStatus.connected);
        await Future.delayed(const Duration(milliseconds: 20));
        statusController.add(WebSocketStatus.disconnected);
        await Future.delayed(const Duration(milliseconds: 20));

        // Assert
        expect(statuses, [
          WebSocketStatus.connecting,
          WebSocketStatus.connected,
          WebSocketStatus.disconnected,
        ]);

        // Cleanup
        await subscription.cancel();
        await statusController.close();
      });
    });
  });
}
