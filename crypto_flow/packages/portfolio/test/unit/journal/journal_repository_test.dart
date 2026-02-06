import 'package:core/error/exceptions.dart';
import 'package:core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portfolio/data/local/daos/journal_dao.dart';
import 'package:portfolio/data/local/daos/tag_dao.dart';
import 'package:portfolio/data/models/journal_entry_model.dart';
import 'package:portfolio/data/models/journal_tag_model.dart';
import 'package:portfolio/data/repositories/journal_repository_impl.dart';
import 'package:portfolio/domain/entities/journal_entry.dart';
import 'package:portfolio/domain/entities/journal_tag.dart';
import 'package:portfolio/domain/entities/stats_period.dart';
import 'package:portfolio/domain/entities/trade_emotion.dart';
import 'package:portfolio/domain/entities/trade_side.dart';

// Mock classes
class MockJournalDao extends Mock implements JournalDao {}

class MockTagDao extends Mock implements TagDao {}

// Fake classes for non-primitive arguments
class FakeJournalEntryModel extends Fake implements JournalEntryModel {}

class FakeJournalTagModel extends Fake implements JournalTagModel {}

void main() {
  late JournalRepositoryImpl repository;
  late MockJournalDao mockJournalDao;
  late MockTagDao mockTagDao;

  setUpAll(() {
    registerFallbackValue(FakeJournalEntryModel());
    registerFallbackValue(FakeJournalTagModel());
  });

  setUp(() {
    mockJournalDao = MockJournalDao();
    mockTagDao = MockTagDao();
    repository = JournalRepositoryImpl(
      journalDao: mockJournalDao,
      tagDao: mockTagDao,
    );
  });

  group('JournalRepository - CRUD Operations', () {
    final testEntry = JournalEntry(
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
    );

    final testModel = JournalEntryModel(
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
    );

    test('addEntry - returns Right with entry ID on success', () async {
      // arrange
      when(() => mockJournalDao.insertEntry(any())).thenAnswer((_) async => 1);

      // act
      final result = await repository.addEntry(testEntry);

      // assert
      expect(result, equals(const Right(1)));
      verify(() => mockJournalDao.insertEntry(any())).called(1);
    });

    test('addEntry - returns Left with CacheFailure on exception', () async {
      // arrange
      when(() => mockJournalDao.insertEntry(any()))
          .thenThrow(CacheException(message: 'Database error'));

      // act
      final result = await repository.addEntry(testEntry);

      // assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<CacheFailure>()),
        (_) => fail('Should return failure'),
      );
    });

    test('updateEntry - returns Right on success', () async {
      // arrange
      when(() => mockJournalDao.updateEntry(any()))
          .thenAnswer((_) async => true);

      // act
      final result = await repository.updateEntry(testEntry);

      // assert
      expect(result, equals(const Right(null)));
      verify(() => mockJournalDao.updateEntry(any())).called(1);
    });

    test('deleteEntry - returns Right on success', () async {
      // arrange
      when(() => mockJournalDao.deleteEntry(1)).thenAnswer((_) async => 1);

      // act
      final result = await repository.deleteEntry(1);

      // assert
      expect(result, equals(const Right(null)));
      verify(() => mockJournalDao.deleteEntry(1)).called(1);
    });

    test('getEntryById - returns Right with entry on success', () async {
      // arrange
      when(() => mockJournalDao.getEntryById(1))
          .thenAnswer((_) async => testModel);

      // act
      final result = await repository.getEntryById(1);

      // assert
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should return entry'),
        (entry) => expect(entry.id, equals(1)),
      );
    });

    test('getEntryById - returns Left when entry not found', () async {
      // arrange
      when(() => mockJournalDao.getEntryById(1))
          .thenThrow(CacheException(message: 'Entry not found'));

      // act
      final result = await repository.getEntryById(1);

      // assert
      expect(result.isLeft(), isTrue);
    });

    test('getEntries - returns all entries when no filters', () async {
      // arrange
      final entries = [testModel];
      when(() => mockJournalDao.getAllEntries())
          .thenAnswer((_) async => entries);

      // act
      final result = await repository.getEntries();

      // assert
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should return entries'),
        (entries) => expect(entries.length, equals(1)),
      );
    });

    test('getEntries - filters by symbol', () async {
      // arrange
      final entries = [testModel];
      when(() => mockJournalDao.getAllEntries(symbol: 'BTCUSDT'))
          .thenAnswer((_) async => entries);

      // act
      final result = await repository.getEntries(symbol: 'BTCUSDT');

      // assert
      expect(result.isRight(), isTrue);
      verify(() => mockJournalDao.getAllEntries(symbol: 'BTCUSDT')).called(1);
    });

    test('getEntries - filters by side', () async {
      // arrange
      final entries = [testModel];
      when(() => mockJournalDao.getAllEntries(side: TradeSide.long))
          .thenAnswer((_) async => entries);

      // act
      final result = await repository.getEntries(side: TradeSide.long);

      // assert
      expect(result.isRight(), isTrue);
      verify(() => mockJournalDao.getAllEntries(side: TradeSide.long))
          .called(1);
    });

    test('getEntries - filters by date range', () async {
      // arrange
      final entries = [testModel];
      final range = DateTimeRange(
        start: DateTime(2024, 1, 1),
        end: DateTime(2024, 1, 31),
      );
      when(() => mockJournalDao.getAllEntries(range: range))
          .thenAnswer((_) async => entries);

      // act
      final result = await repository.getEntries(range: range);

      // assert
      expect(result.isRight(), isTrue);
      verify(() => mockJournalDao.getAllEntries(range: range)).called(1);
    });

    test('searchEntries - returns matching entries', () async {
      // arrange
      final entries = [testModel];
      when(() => mockJournalDao.searchEntries('BTC'))
          .thenAnswer((_) async => entries);

      // act
      final result = await repository.searchEntries('BTC');

      // assert
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should return entries'),
        (entries) => expect(entries.length, equals(1)),
      );
    });
  });

  group('JournalRepository - Statistics', () {
    final now = DateTime(2024, 2, 1, 12, 0);
    final entries = [
      JournalEntryModel(
        id: 1,
        symbol: 'BTCUSDT',
        side: TradeSide.long,
        entryPrice: 50000.0,
        exitPrice: 55000.0,
        quantity: 1.0,
        pnl: 5000.0,
        riskRewardRatio: 2.0,
        emotion: TradeEmotion.confident,
        entryDate: now.subtract(const Duration(days: 5)),
        exitDate: now.subtract(const Duration(days: 4)),
        createdAt: now,
        updatedAt: now,
      ),
      JournalEntryModel(
        id: 2,
        symbol: 'ETHUSDT',
        side: TradeSide.long,
        entryPrice: 3000.0,
        exitPrice: 2800.0,
        quantity: 2.0,
        pnl: -400.0,
        riskRewardRatio: 1.5,
        emotion: TradeEmotion.fearful,
        entryDate: now.subtract(const Duration(days: 3)),
        exitDate: now.subtract(const Duration(days: 2)),
        createdAt: now,
        updatedAt: now,
      ),
      JournalEntryModel(
        id: 3,
        symbol: 'BTCUSDT',
        side: TradeSide.short,
        entryPrice: 56000.0,
        exitPrice: 54000.0,
        quantity: 1.0,
        pnl: 2000.0,
        riskRewardRatio: 3.0,
        emotion: TradeEmotion.confident,
        entryDate: now.subtract(const Duration(days: 1)),
        exitDate: now,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    test('calculateStats - returns correct win rate', () async {
      // arrange
      when(() => mockJournalDao.getAllEntries())
          .thenAnswer((_) async => entries);
      when(() => mockJournalDao.getTotalPnl(days: any(named: 'days')))
          .thenAnswer((_) async => 6600.0);
      when(() => mockJournalDao.getGrossProfit(days: any(named: 'days')))
          .thenAnswer((_) async => 7000.0);
      when(() => mockJournalDao.getGrossLoss(days: any(named: 'days')))
          .thenAnswer((_) async => -400.0);
      when(() => mockJournalDao.getAverageRR(days: any(named: 'days')))
          .thenAnswer((_) async => 2.17);
      when(() => mockJournalDao.getLargestWin(days: any(named: 'days')))
          .thenAnswer((_) async => 5000.0);
      when(() => mockJournalDao.getLargestLoss(days: any(named: 'days')))
          .thenAnswer((_) async => -400.0);

      // act
      final result = await repository.calculateStats(StatsPeriod.allTime);

      // assert
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should return stats'),
        (stats) {
          expect(stats.totalTrades, equals(3));
          expect(stats.winCount, equals(2));
          expect(stats.lossCount, equals(1));
          // Win rate: 2/3 = 66.67%
          expect(stats.winRate, closeTo(66.67, 0.01));
        },
      );
    });

    test('calculateStats - returns correct profit factor', () async {
      // arrange
      when(() => mockJournalDao.getAllEntries())
          .thenAnswer((_) async => entries);
      when(() => mockJournalDao.getTotalPnl(days: any(named: 'days')))
          .thenAnswer((_) async => 6600.0);
      when(() => mockJournalDao.getGrossProfit(days: any(named: 'days')))
          .thenAnswer((_) async => 7000.0);
      when(() => mockJournalDao.getGrossLoss(days: any(named: 'days')))
          .thenAnswer((_) async => -400.0);
      when(() => mockJournalDao.getAverageRR(days: any(named: 'days')))
          .thenAnswer((_) async => 2.17);
      when(() => mockJournalDao.getLargestWin(days: any(named: 'days')))
          .thenAnswer((_) async => 5000.0);
      when(() => mockJournalDao.getLargestLoss(days: any(named: 'days')))
          .thenAnswer((_) async => -400.0);

      // act
      final result = await repository.calculateStats(StatsPeriod.allTime);

      // assert
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should return stats'),
        (stats) {
          // Profit factor: 7000 / |-400| = 17.5
          expect(stats.profitFactor, closeTo(17.5, 0.01));
        },
      );
    });

    test('calculateStats - handles daily period', () async {
      // arrange
      when(() => mockJournalDao.getAllEntries())
          .thenAnswer((_) async => entries);
      when(() => mockJournalDao.getTotalPnl(days: 1))
          .thenAnswer((_) async => 2000.0);
      when(() => mockJournalDao.getGrossProfit(days: 1))
          .thenAnswer((_) async => 2000.0);
      when(() => mockJournalDao.getGrossLoss(days: 1))
          .thenAnswer((_) async => 0.0);
      when(() => mockJournalDao.getAverageRR(days: 1))
          .thenAnswer((_) async => 3.0);
      when(() => mockJournalDao.getLargestWin(days: 1))
          .thenAnswer((_) async => 2000.0);
      when(() => mockJournalDao.getLargestLoss(days: 1))
          .thenAnswer((_) async => 0.0);

      // act
      final result = await repository.calculateStats(StatsPeriod.daily);

      // assert
      expect(result.isRight(), isTrue);
      verify(() => mockJournalDao.getTotalPnl(days: 1)).called(1);
    });

    test('calculateStats - handles empty entries', () async {
      // arrange
      when(() => mockJournalDao.getAllEntries()).thenAnswer((_) async => []);

      // act
      final result = await repository.calculateStats(StatsPeriod.allTime);

      // assert
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should return empty stats'),
        (stats) {
          expect(stats.totalTrades, equals(0));
          expect(stats.winRate, equals(0.0));
          expect(stats.totalPnl, equals(0.0));
        },
      );
    });
  });

  group('JournalRepository - Equity Curve', () {
    test('getEquityCurve - returns cumulative P&L correctly', () async {
      // arrange
      final entries = [
        JournalEntryModel(
          id: 1,
          symbol: 'BTCUSDT',
          side: TradeSide.long,
          entryPrice: 50000.0,
          quantity: 1.0,
          pnl: 1000.0,
          emotion: TradeEmotion.confident,
          entryDate: DateTime(2024, 1, 1),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        JournalEntryModel(
          id: 2,
          symbol: 'ETHUSDT',
          side: TradeSide.long,
          entryPrice: 3000.0,
          quantity: 1.0,
          pnl: 500.0,
          emotion: TradeEmotion.confident,
          entryDate: DateTime(2024, 1, 2),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        JournalEntryModel(
          id: 3,
          symbol: 'BTCUSDT',
          side: TradeSide.short,
          entryPrice: 55000.0,
          quantity: 1.0,
          pnl: -200.0,
          emotion: TradeEmotion.fearful,
          entryDate: DateTime(2024, 1, 3),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      when(() => mockJournalDao.getAllEntries())
          .thenAnswer((_) async => entries);

      // act
      final result = await repository.getEquityCurve();

      // assert
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should return equity curve'),
        (curve) {
          expect(curve.length, equals(3));
          expect(curve[0], equals(1000.0)); // First trade
          expect(curve[1], equals(1500.0)); // Cumulative: 1000 + 500
          expect(curve[2], equals(1300.0)); // Cumulative: 1500 - 200
        },
      );
    });

    test('getEquityCurve - filters by days', () async {
      // arrange
      final now = DateTime.now();
      final entries = [
        JournalEntryModel(
          id: 1,
          symbol: 'BTCUSDT',
          side: TradeSide.long,
          entryPrice: 50000.0,
          quantity: 1.0,
          pnl: 1000.0,
          emotion: TradeEmotion.confident,
          entryDate: now.subtract(const Duration(days: 2)),
          createdAt: now,
          updatedAt: now,
        ),
      ];
      when(() => mockJournalDao.getAllEntries())
          .thenAnswer((_) async => entries);

      // act
      final result = await repository.getEquityCurve(days: 7);

      // assert
      expect(result.isRight(), isTrue);
    });

    test('getEquityCurve - returns empty list for no entries', () async {
      // arrange
      when(() => mockJournalDao.getAllEntries()).thenAnswer((_) async => []);

      // act
      final result = await repository.getEquityCurve();

      // assert
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should return empty curve'),
        (curve) => expect(curve, isEmpty),
      );
    });
  });

  group('JournalRepository - Max Drawdown', () {
    test('getMaxDrawdown - calculates peak-to-trough correctly', () async {
      // arrange
      final entries = [
        JournalEntryModel(
          id: 1,
          symbol: 'BTCUSDT',
          side: TradeSide.long,
          entryPrice: 50000.0,
          quantity: 1.0,
          pnl: 1000.0,
          emotion: TradeEmotion.confident,
          entryDate: DateTime(2024, 1, 1),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        JournalEntryModel(
          id: 2,
          symbol: 'ETHUSDT',
          side: TradeSide.long,
          entryPrice: 3000.0,
          quantity: 1.0,
          pnl: 2000.0,
          emotion: TradeEmotion.confident,
          entryDate: DateTime(2024, 1, 2),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        JournalEntryModel(
          id: 3,
          symbol: 'BTCUSDT',
          side: TradeSide.short,
          entryPrice: 55000.0,
          quantity: 1.0,
          pnl: -1500.0, // Drawdown from 3000 to 1500
          emotion: TradeEmotion.fearful,
          entryDate: DateTime(2024, 1, 3),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      when(() => mockJournalDao.getAllEntries())
          .thenAnswer((_) async => entries);

      // act
      final result = await repository.getMaxDrawdown();

      // assert
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should return max drawdown'),
        (drawdown) {
          // Peak is 3000 (after second trade)
          // Trough is 1500 (after third trade)
          // Drawdown: (3000 - 1500) / 3000 * 100 = 50%
          expect(drawdown, closeTo(50.0, 0.01));
        },
      );
    });

    test('getMaxDrawdown - returns 0 for empty entries', () async {
      // arrange
      when(() => mockJournalDao.getAllEntries()).thenAnswer((_) async => []);

      // act
      final result = await repository.getMaxDrawdown();

      // assert
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should return 0'),
        (drawdown) => expect(drawdown, equals(0.0)),
      );
    });
  });

  group('JournalRepository - P&L Analysis', () {
    test('getPnlBySymbol - aggregates correctly', () async {
      // arrange
      final pnlMap = {'BTCUSDT': 5000.0, 'ETHUSDT': -400.0};
      when(() => mockJournalDao.getPnlBySymbol(days: any(named: 'days')))
          .thenAnswer((_) async => pnlMap);

      // act
      final result = await repository.getPnlBySymbol();

      // assert
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should return P&L map'),
        (map) {
          expect(map['BTCUSDT'], equals(5000.0));
          expect(map['ETHUSDT'], equals(-400.0));
        },
      );
    });

    test('getPnlByEmotion - aggregates by emotion correctly', () async {
      // arrange
      final pnlMap = {'confident': 7000.0, 'fearful': -400.0};
      when(() => mockJournalDao.getPnlByEmotion(days: any(named: 'days')))
          .thenAnswer((_) async => pnlMap);

      // act
      final result = await repository.getPnlByEmotion();

      // assert
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should return P&L map'),
        (map) {
          expect(map[TradeEmotion.confident], equals(7000.0));
          expect(map[TradeEmotion.fearful], equals(-400.0));
        },
      );
    });
  });

  group('JournalRepository - Edge Cases', () {
    test('handles single trade correctly', () async {
      // arrange
      final entries = [
        JournalEntryModel(
          id: 1,
          symbol: 'BTCUSDT',
          side: TradeSide.long,
          entryPrice: 50000.0,
          exitPrice: 55000.0,
          quantity: 1.0,
          pnl: 5000.0,
          emotion: TradeEmotion.confident,
          entryDate: DateTime.now(),
          exitDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      when(() => mockJournalDao.getAllEntries())
          .thenAnswer((_) async => entries);
      when(() => mockJournalDao.getTotalPnl(days: any(named: 'days')))
          .thenAnswer((_) async => 5000.0);
      when(() => mockJournalDao.getGrossProfit(days: any(named: 'days')))
          .thenAnswer((_) async => 5000.0);
      when(() => mockJournalDao.getGrossLoss(days: any(named: 'days')))
          .thenAnswer((_) async => 0.0);
      when(() => mockJournalDao.getAverageRR(days: any(named: 'days')))
          .thenAnswer((_) async => 2.0);
      when(() => mockJournalDao.getLargestWin(days: any(named: 'days')))
          .thenAnswer((_) async => 5000.0);
      when(() => mockJournalDao.getLargestLoss(days: any(named: 'days')))
          .thenAnswer((_) async => 0.0);

      // act
      final result = await repository.calculateStats(StatsPeriod.allTime);

      // assert
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should return stats'),
        (stats) {
          expect(stats.totalTrades, equals(1));
          expect(stats.winRate, equals(100.0));
        },
      );
    });

    test('handles all wins scenario', () async {
      // arrange
      final entries = [
        JournalEntryModel(
          id: 1,
          symbol: 'BTCUSDT',
          side: TradeSide.long,
          entryPrice: 50000.0,
          exitPrice: 55000.0,
          quantity: 1.0,
          pnl: 5000.0,
          emotion: TradeEmotion.confident,
          entryDate: DateTime.now(),
          exitDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        JournalEntryModel(
          id: 2,
          symbol: 'ETHUSDT',
          side: TradeSide.long,
          entryPrice: 3000.0,
          exitPrice: 3200.0,
          quantity: 1.0,
          pnl: 200.0,
          emotion: TradeEmotion.confident,
          entryDate: DateTime.now(),
          exitDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      when(() => mockJournalDao.getAllEntries())
          .thenAnswer((_) async => entries);
      when(() => mockJournalDao.getTotalPnl(days: any(named: 'days')))
          .thenAnswer((_) async => 5200.0);
      when(() => mockJournalDao.getGrossProfit(days: any(named: 'days')))
          .thenAnswer((_) async => 5200.0);
      when(() => mockJournalDao.getGrossLoss(days: any(named: 'days')))
          .thenAnswer((_) async => 0.0);
      when(() => mockJournalDao.getAverageRR(days: any(named: 'days')))
          .thenAnswer((_) async => 2.0);
      when(() => mockJournalDao.getLargestWin(days: any(named: 'days')))
          .thenAnswer((_) async => 5000.0);
      when(() => mockJournalDao.getLargestLoss(days: any(named: 'days')))
          .thenAnswer((_) async => 0.0);

      // act
      final result = await repository.calculateStats(StatsPeriod.allTime);

      // assert
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should return stats'),
        (stats) {
          expect(stats.totalTrades, equals(2));
          expect(stats.winCount, equals(2));
          expect(stats.lossCount, equals(0));
          expect(stats.winRate, equals(100.0));
          expect(stats.profitFactor, equals(0.0)); // No losses
        },
      );
    });

    test('handles all losses scenario', () async {
      // arrange
      final entries = [
        JournalEntryModel(
          id: 1,
          symbol: 'BTCUSDT',
          side: TradeSide.long,
          entryPrice: 50000.0,
          exitPrice: 48000.0,
          quantity: 1.0,
          pnl: -2000.0,
          emotion: TradeEmotion.fearful,
          entryDate: DateTime.now(),
          exitDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        JournalEntryModel(
          id: 2,
          symbol: 'ETHUSDT',
          side: TradeSide.long,
          entryPrice: 3000.0,
          exitPrice: 2800.0,
          quantity: 1.0,
          pnl: -200.0,
          emotion: TradeEmotion.fearful,
          entryDate: DateTime.now(),
          exitDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      when(() => mockJournalDao.getAllEntries())
          .thenAnswer((_) async => entries);
      when(() => mockJournalDao.getTotalPnl(days: any(named: 'days')))
          .thenAnswer((_) async => -2200.0);
      when(() => mockJournalDao.getGrossProfit(days: any(named: 'days')))
          .thenAnswer((_) async => 0.0);
      when(() => mockJournalDao.getGrossLoss(days: any(named: 'days')))
          .thenAnswer((_) async => -2200.0);
      when(() => mockJournalDao.getAverageRR(days: any(named: 'days')))
          .thenAnswer((_) async => 0.0);
      when(() => mockJournalDao.getLargestWin(days: any(named: 'days')))
          .thenAnswer((_) async => 0.0);
      when(() => mockJournalDao.getLargestLoss(days: any(named: 'days')))
          .thenAnswer((_) async => -2000.0);

      // act
      final result = await repository.calculateStats(StatsPeriod.allTime);

      // assert
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should return stats'),
        (stats) {
          expect(stats.totalTrades, equals(2));
          expect(stats.winCount, equals(0));
          expect(stats.lossCount, equals(2));
          expect(stats.winRate, equals(0.0));
        },
      );
    });
  });

  group('JournalRepository - Tag Operations', () {
    test('getTags - returns all tags', () async {
      // arrange
      final tags = [
        JournalTagModel(
          id: 1,
          name: 'Breakout',
          color: 0xFFFF5733,
          usageCount: 5,
        ),
      ];
      when(() => mockTagDao.getAllTags()).thenAnswer((_) async => tags);

      // act
      final result = await repository.getTags();

      // assert
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should return tags'),
        (tags) => expect(tags.length, equals(1)),
      );
    });

    test('addTag - adds tag successfully', () async {
      // arrange
      final tag = JournalTag(
        id: 0,
        name: 'Breakout',
        color: 0xFFFF5733,
        usageCount: 0,
      );
      when(() => mockTagDao.insertTag(any())).thenAnswer((_) async => 1);

      // act
      final result = await repository.addTag(tag);

      // assert
      expect(result, equals(const Right(1)));
      verify(() => mockTagDao.insertTag(any())).called(1);
    });

    test('deleteTag - deletes tag successfully', () async {
      // arrange
      when(() => mockTagDao.deleteTag(1)).thenAnswer((_) async => 1);

      // act
      final result = await repository.deleteTag(1);

      // assert
      expect(result, equals(const Right(null)));
      verify(() => mockTagDao.deleteTag(1)).called(1);
    });

    test('incrementTagUsage - increments usage count', () async {
      // arrange
      when(() => mockTagDao.incrementUsage(1)).thenAnswer((_) async => 1);

      // act
      final result = await repository.incrementTagUsage(1);

      // assert
      expect(result, equals(const Right(null)));
      verify(() => mockTagDao.incrementUsage(1)).called(1);
    });
  });
}
