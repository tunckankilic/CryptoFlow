import 'package:core/error/exceptions.dart';
import 'package:core/error/failures.dart';
import 'package:dartz/dartz.dart';

import '../../domain/entities/watchlist_item.dart';
import '../../domain/repositories/watchlist_repository.dart';
import '../datasources/watchlist_local_datasource.dart';
import '../datasources/watchlist_remote_datasource.dart';

/// AWS-backed [WatchlistRepository] implementation.
///
/// Strategy: remote-first CRUD, local Hive cache as fallback for reads.
class WatchlistAwsRepositoryImpl implements WatchlistRepository {
  final WatchlistRemoteDataSource remoteDataSource;
  final WatchlistLocalDataSource localDataSource;

  WatchlistAwsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<WatchlistItem>>> getWatchlist() async {
    try {
      final items = await remoteDataSource.getWatchlist();
      return Right(items);
    } on AuthException {
      return Left(ServerFailure(message: 'Authentication required'));
    } on ServerException catch (_) {
      return _watchlistFallback();
    } on NetworkException {
      return _watchlistFallback();
    } catch (e) {
      return _watchlistFallback();
    }
  }

  Future<Either<Failure, List<WatchlistItem>>> _watchlistFallback() async {
    try {
      return Right(await localDataSource.getWatchlist());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> addToWatchlist(String symbol) async {
    try {
      await remoteDataSource.addToWatchlist(symbol);
      await localDataSource.addToWatchlist(symbol);
      return const Right(null);
    } on AuthException {
      return Left(ServerFailure(message: 'Authentication required'));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to add to watchlist: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromWatchlist(String symbol) async {
    try {
      await remoteDataSource.removeFromWatchlist(symbol);
      await localDataSource.removeFromWatchlist(symbol);
      return const Right(null);
    } on AuthException {
      return Left(ServerFailure(message: 'Authentication required'));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to remove from watchlist: $e'));
    }
  }

  /// Answered from local cache — no API call needed.
  @override
  Future<Either<Failure, bool>> isInWatchlist(String symbol) async {
    try {
      return Right(await localDataSource.isInWatchlist(symbol));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> reorderWatchlist(
      List<WatchlistItem> items) async {
    try {
      await remoteDataSource.reorderWatchlist(items);
      await localDataSource.reorderWatchlist(items);
      return const Right(null);
    } on AuthException {
      return Left(ServerFailure(message: 'Authentication required'));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to reorder watchlist: $e'));
    }
  }

  @override
  Stream<List<WatchlistItem>> watchWatchlist() {
    return localDataSource.watchWatchlist();
  }
}
