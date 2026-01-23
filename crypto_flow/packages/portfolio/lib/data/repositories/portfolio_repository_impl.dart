import 'package:core/error/exceptions.dart';
import 'package:core/error/failures.dart';
import 'package:dartz/dartz.dart';
import '../../domain/entities/holding.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/portfolio_repository.dart';
import '../datasources/portfolio_local_datasource.dart';

/// Implementation of PortfolioRepository using local database
class PortfolioRepositoryImpl implements PortfolioRepository {
  final PortfolioLocalDataSource localDataSource;

  PortfolioRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<Holding>>> getHoldings() async {
    try {
      final holdings = await localDataSource.calculateHoldings();
      return Right(holdings);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get holdings: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addTransaction(Transaction transaction) async {
    try {
      await localDataSource.addTransaction(transaction);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to add transaction: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Transaction>>> getTransactions({
    String? symbol,
  }) async {
    try {
      final transactions = await localDataSource.getTransactions(
        symbol: symbol,
      );
      return Right(transactions);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get transactions: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(String id) async {
    try {
      await localDataSource.deleteTransaction(id);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to delete transaction: $e'));
    }
  }

  @override
  Stream<List<Holding>> watchHoldings() {
    return localDataSource.watchHoldings();
  }

  @override
  Stream<List<Transaction>> watchTransactions({String? symbol}) {
    return localDataSource.watchTransactions(symbol: symbol);
  }
}
