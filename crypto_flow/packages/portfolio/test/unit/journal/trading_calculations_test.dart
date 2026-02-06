import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/domain/entities/journal_entry.dart';
import 'package:portfolio/domain/entities/trade_side.dart';
import 'package:portfolio/domain/entities/trade_emotion.dart';

void main() {
  group('JournalEntry Calculations', () {
    group('P&L Calculation', () {
      test('calculates correct P&L for long position', () {
        // arrange
        final entry = JournalEntry(
          id: 1,
          symbol: 'BTCUSDT',
          side: TradeSide.long,
          entryPrice: 50000.0,
          exitPrice: 55000.0,
          quantity: 2.0,
          emotion: TradeEmotion.confident,
          entryDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // act
        final pnl = entry.calculatePnl();

        // assert
        // Long: (55000 - 50000) * 2 = 10000
        expect(pnl, equals(10000.0));
      });

      test('calculates correct P&L for short position', () {
        // arrange
        final entry = JournalEntry(
          id: 1,
          symbol: 'BTCUSDT',
          side: TradeSide.short,
          entryPrice: 50000.0,
          exitPrice: 45000.0,
          quantity: 2.0,
          emotion: TradeEmotion.confident,
          entryDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // act
        final pnl = entry.calculatePnl();

        // assert
        // Short: -(45000 - 50000) * 2 = 10000
        expect(pnl, equals(10000.0));
      });

      test('calculates negative P&L for losing long position', () {
        // arrange
        final entry = JournalEntry(
          id: 1,
          symbol: 'BTCUSDT',
          side: TradeSide.long,
          entryPrice: 50000.0,
          exitPrice: 45000.0,
          quantity: 1.0,
          emotion: TradeEmotion.fearful,
          entryDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // act
        final pnl = entry.calculatePnl();

        // assert
        // Long: (45000 - 50000) * 1 = -5000
        expect(pnl, equals(-5000.0));
      });

      test('calculates negative P&L for losing short position', () {
        // arrange
        final entry = JournalEntry(
          id: 1,
          symbol: 'BTCUSDT',
          side: TradeSide.short,
          entryPrice: 50000.0,
          exitPrice: 55000.0,
          quantity: 1.0,
          emotion: TradeEmotion.fearful,
          entryDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // act
        final pnl = entry.calculatePnl();

        // assert
        // Short: -(55000 - 50000) * 1 = -5000
        expect(pnl, equals(-5000.0));
      });

      test('returns null for open position (no exit price)', () {
        // arrange
        final entry = JournalEntry(
          id: 1,
          symbol: 'BTCUSDT',
          side: TradeSide.long,
          entryPrice: 50000.0,
          exitPrice: null,
          quantity: 1.0,
          emotion: TradeEmotion.neutral,
          entryDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // act
        final pnl = entry.calculatePnl();

        // assert
        expect(pnl, isNull);
      });
    });

    group('P&L Percentage Calculation', () {
      test('calculates correct P&L percentage for long position', () {
        // arrange
        final entry = JournalEntry(
          id: 1,
          symbol: 'BTCUSDT',
          side: TradeSide.long,
          entryPrice: 50000.0,
          exitPrice: 55000.0,
          quantity: 1.0,
          emotion: TradeEmotion.confident,
          entryDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // act
        final pnlPercentage = entry.calculatePnlPercentage();

        // assert
        // Long: ((55000 - 50000) / 50000) * 100 = 10%
        expect(pnlPercentage, equals(10.0));
      });

      test('calculates correct P&L percentage for short position', () {
        // arrange
        final entry = JournalEntry(
          id: 1,
          symbol: 'BTCUSDT',
          side: TradeSide.short,
          entryPrice: 50000.0,
          exitPrice: 45000.0,
          quantity: 1.0,
          emotion: TradeEmotion.confident,
          entryDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // act
        final pnlPercentage = entry.calculatePnlPercentage();

        // assert
        // Short: -((45000 - 50000) / 50000) * 100 = 10%
        expect(pnlPercentage, equals(10.0));
      });

      test('calculates negative P&L percentage for losing position', () {
        // arrange
        final entry = JournalEntry(
          id: 1,
          symbol: 'BTCUSDT',
          side: TradeSide.long,
          entryPrice: 50000.0,
          exitPrice: 45000.0,
          quantity: 1.0,
          emotion: TradeEmotion.fearful,
          entryDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // act
        final pnlPercentage = entry.calculatePnlPercentage();

        // assert
        // Long: ((45000 - 50000) / 50000) * 100 = -10%
        expect(pnlPercentage, equals(-10.0));
      });

      test('returns null for open position (no exit price)', () {
        // arrange
        final entry = JournalEntry(
          id: 1,
          symbol: 'BTCUSDT',
          side: TradeSide.long,
          entryPrice: 50000.0,
          exitPrice: null,
          quantity: 1.0,
          emotion: TradeEmotion.neutral,
          entryDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // act
        final pnlPercentage = entry.calculatePnlPercentage();

        // assert
        expect(pnlPercentage, isNull);
      });
    });

    group('Trade Duration', () {
      test('calculates duration for closed position', () {
        // arrange
        final entryDate = DateTime(2024, 1, 1, 10, 0);
        final exitDate = DateTime(2024, 1, 1, 14, 30);

        final entry = JournalEntry(
          id: 1,
          symbol: 'BTCUSDT',
          side: TradeSide.long,
          entryPrice: 50000.0,
          exitPrice: 55000.0,
          quantity: 1.0,
          emotion: TradeEmotion.confident,
          entryDate: entryDate,
          exitDate: exitDate,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // act
        final duration = entry.duration;

        // assert
        expect(duration, equals(const Duration(hours: 4, minutes: 30)));
      });

      test('returns null for open position', () {
        // arrange
        final entry = JournalEntry(
          id: 1,
          symbol: 'BTCUSDT',
          side: TradeSide.long,
          entryPrice: 50000.0,
          quantity: 1.0,
          emotion: TradeEmotion.neutral,
          entryDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // act
        final duration = entry.duration;

        // assert
        expect(duration, isNull);
      });
    });

    group('Position Status', () {
      test('isOpen returns true for position without exit date', () {
        // arrange
        final entry = JournalEntry(
          id: 1,
          symbol: 'BTCUSDT',
          side: TradeSide.long,
          entryPrice: 50000.0,
          quantity: 1.0,
          emotion: TradeEmotion.neutral,
          entryDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // act & assert
        expect(entry.isOpen, isTrue);
      });

      test('isOpen returns false for closed position', () {
        // arrange
        final entry = JournalEntry(
          id: 1,
          symbol: 'BTCUSDT',
          side: TradeSide.long,
          entryPrice: 50000.0,
          exitPrice: 55000.0,
          quantity: 1.0,
          emotion: TradeEmotion.confident,
          entryDate: DateTime.now(),
          exitDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // act & assert
        expect(entry.isOpen, isFalse);
      });
    });

    group('Edge Cases', () {
      test('handles zero quantity', () {
        // arrange
        final entry = JournalEntry(
          id: 1,
          symbol: 'BTCUSDT',
          side: TradeSide.long,
          entryPrice: 50000.0,
          exitPrice: 55000.0,
          quantity: 0.0,
          emotion: TradeEmotion.neutral,
          entryDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // act
        final pnl = entry.calculatePnl();

        // assert
        expect(pnl, equals(0.0));
      });

      test('handles very small quantity', () {
        // arrange
        final entry = JournalEntry(
          id: 1,
          symbol: 'BTCUSDT',
          side: TradeSide.long,
          entryPrice: 50000.0,
          exitPrice: 51000.0,
          quantity: 0.001,
          emotion: TradeEmotion.neutral,
          entryDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // act
        final pnl = entry.calculatePnl();

        // assert
        expect(pnl, closeTo(1.0, 0.0001));
      });

      test('handles large price differences', () {
        // arrange
        final entry = JournalEntry(
          id: 1,
          symbol: 'BTCUSDT',
          side: TradeSide.long,
          entryPrice: 10000.0,
          exitPrice: 60000.0,
          quantity: 10.0,
          emotion: TradeEmotion.fearful,
          entryDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // act
        final pnl = entry.calculatePnl();
        final pnlPercentage = entry.calculatePnlPercentage();

        // assert
        expect(pnl, equals(500000.0)); // (60000 - 10000) * 10
        expect(pnlPercentage, equals(500.0)); // ((60000 - 10000) / 10000) * 100
      });
    });
  });
}
