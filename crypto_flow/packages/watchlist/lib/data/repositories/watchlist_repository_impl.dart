import 'package:core/error/exceptions.dart';
import 'package:core/error/failures.dart';
import 'package:dartz/dartz.dart';
import '../../domain/entities/watchlist_item.dart';
import '../../domain/repositories/watchlist_repository.dart';
import '../datasources/watchlist_local_datasource.dart';

/// Implementation of WatchlistRepository using local Hive storage
class WatchlistRepositoryImpl implements WatchlistRepository {
  final WatchlistLocalDataSource localDataSource;

  WatchlistRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<WatchlistItem>>> getWatchlist() async {
    try {
      final items = await localDataSource.getWatchlist();
      return Right(items);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get watchlist: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addToWatchlist(String symbol) async {
    try {
      await localDataSource.addToWatchlist(symbol);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to add to watchlist: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromWatchlist(String symbol) async {
    try {
      await localDataSource.removeFromWatchlist(symbol);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to remove from watchlist: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isInWatchlist(String symbol) async {
    try {
      final isIn = await localDataSource.isInWatchlist(symbol);
      return Right(isIn);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to check watchlist: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> reorderWatchlist(
      List<WatchlistItem> items) async {
    try {
      await localDataSource.reorderWatchlist(items);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to reorder watchlist: $e'));
    }
  }

  @override
  Stream<List<WatchlistItem>> watchWatchlist() {
    return localDataSource.watchWatchlist();
  }
}
