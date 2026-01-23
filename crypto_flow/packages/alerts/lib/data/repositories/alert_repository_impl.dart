import 'package:core/error/exceptions.dart';
import 'package:core/error/failures.dart';
import 'package:dartz/dartz.dart';
import '../../domain/entities/price_alert.dart';
import '../../domain/repositories/alert_repository.dart';
import '../datasources/alert_local_datasource.dart';

/// Implementation of AlertRepository using local Hive storage
class AlertRepositoryImpl implements AlertRepository {
  final AlertLocalDataSource localDataSource;

  AlertRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<PriceAlert>>> getAlerts() async {
    try {
      final alerts = await localDataSource.getAlerts();
      return Right(alerts);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get alerts: $e'));
    }
  }

  @override
  Future<Either<Failure, PriceAlert>> createAlert(PriceAlert alert) async {
    try {
      final created = await localDataSource.createAlert(alert);
      return Right(created);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to create alert: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAlert(String id) async {
    try {
      await localDataSource.deleteAlert(id);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to delete alert: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> toggleAlert(String id, bool isActive) async {
    try {
      await localDataSource.toggleAlert(id, isActive);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to toggle alert: $e'));
    }
  }

  @override
  Future<Either<Failure, PriceAlert>> updateAlert(PriceAlert alert) async {
    try {
      final updated = await localDataSource.updateAlert(alert);
      return Right(updated);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to update alert: $e'));
    }
  }

  @override
  Future<Either<Failure, List<PriceAlert>>> checkAlerts(
    Map<String, double> currentPrices,
  ) async {
    try {
      final triggered = await localDataSource.checkAlerts(currentPrices);
      return Right(triggered);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to check alerts: $e'));
    }
  }

  @override
  Stream<List<PriceAlert>> watchAlerts() {
    return localDataSource.watchAlerts();
  }
}
