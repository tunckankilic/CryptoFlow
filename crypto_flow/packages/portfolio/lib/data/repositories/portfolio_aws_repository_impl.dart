import 'package:core/error/exceptions.dart';
import 'package:core/error/failures.dart';
import 'package:dartz/dartz.dart';

import '../../domain/entities/holding.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/portfolio_repository.dart';
import '../datasources/portfolio_local_datasource.dart';
import '../datasources/portfolio_remote_datasource.dart';

/// AWS-backed [PortfolioRepository] implementation.
///
/// Strategy: **remote-first, cache-fallback**.
/// - Writes go to the remote API first; on success the local cache is
///   updated.
/// - Reads try the remote API first. If the remote call fails (network /
///   server error) the locally-cached data is returned instead.
/// - Streams (watch*) are always served from the local data source for
///   immediate UI reactivity.
class PortfolioAwsRepositoryImpl implements PortfolioRepository {
  final PortfolioRemoteDataSource remoteDataSource;
  final PortfolioLocalDataSource localDataSource;

  PortfolioAwsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  // ---------------------------------------------------------------- Holdings

  @override
  Future<Either<Failure, List<Holding>>> getHoldings() async {
    try {
      final holdings = await remoteDataSource.getHoldings();
      return Right(holdings);
    } on AuthException {
      return Left(ServerFailure(message: 'Authentication required'));
    } on ServerException catch (e) {
      return _holdingsFallback(e.message);
    } on NetworkException {
      return _holdingsFallback('Network unavailable — showing cached data');
    } catch (e) {
      return _holdingsFallback('$e');
    }
  }

  Future<Either<Failure, List<Holding>>> _holdingsFallback(String reason) async {
    try {
      final cached = await localDataSource.calculateHoldings();
      return Right(cached);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  // ----------------------------------------------------------- Transactions

  @override
  Future<Either<Failure, void>> addTransaction(Transaction transaction) async {
    try {
      await remoteDataSource.createTransaction(transaction);
      // Cache locally
      await localDataSource.addTransaction(transaction);
      return const Right(null);
    } on AuthException {
      return Left(ServerFailure(message: 'Authentication required'));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to add transaction: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Transaction>>> getTransactions({
    String? symbol,
  }) async {
    try {
      final transactions = await remoteDataSource.getTransactions();
      final filtered = symbol != null
          ? transactions.where((t) => t.symbol == symbol).toList()
          : transactions;
      return Right(filtered);
    } on AuthException {
      return Left(ServerFailure(message: 'Authentication required'));
    } on ServerException catch (_) {
      return _transactionsFallback(symbol);
    } on NetworkException {
      return _transactionsFallback(symbol);
    } catch (e) {
      return _transactionsFallback(symbol);
    }
  }

  Future<Either<Failure, List<Transaction>>> _transactionsFallback(
      String? symbol) async {
    try {
      final cached = await localDataSource.getTransactions(symbol: symbol);
      return Right(cached);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(String id) async {
    try {
      // The backend uses the same transaction ID.
      // Note: the backend doesn't have a DELETE /transactions/:id endpoint,
      // so for now we only delete locally. A future backend update can add it.
      await localDataSource.deleteTransaction(id);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to delete transaction: $e'));
    }
  }

  // ----------------------------------------------------------------- Streams

  @override
  Stream<List<Holding>> watchHoldings() {
    return localDataSource.watchHoldings();
  }

  @override
  Stream<List<Transaction>> watchTransactions({String? symbol}) {
    return localDataSource.watchTransactions(symbol: symbol);
  }
}
