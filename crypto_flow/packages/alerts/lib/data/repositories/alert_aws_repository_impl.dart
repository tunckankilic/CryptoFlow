import 'package:core/error/exceptions.dart';
import 'package:core/error/failures.dart';
import 'package:dartz/dartz.dart';

import '../../domain/entities/price_alert.dart';
import '../../domain/repositories/alert_repository.dart';
import '../datasources/alert_local_datasource.dart';
import '../datasources/alert_remote_datasource.dart';

/// AWS-backed [AlertRepository] implementation.
///
/// Strategy: remote-first CRUD, local Hive cache as fallback for reads.
/// [checkAlerts] is a no-op because the Lambda alert-checker runs
/// server-side on a 1-minute schedule.
class AlertAwsRepositoryImpl implements AlertRepository {
  final AlertRemoteDataSource remoteDataSource;
  final AlertLocalDataSource localDataSource;

  AlertAwsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<PriceAlert>>> getAlerts() async {
    try {
      final alerts = await remoteDataSource.getAlerts();
      // Cache locally
      for (final alert in alerts) {
        await localDataSource.createAlert(alert);
      }
      return Right(alerts);
    } on AuthException {
      return Left(ServerFailure(message: 'Authentication required'));
    } on ServerException catch (_) {
      return _alertsFallback();
    } on NetworkException {
      return _alertsFallback();
    } catch (e) {
      return _alertsFallback();
    }
  }

  Future<Either<Failure, List<PriceAlert>>> _alertsFallback() async {
    try {
      return Right(await localDataSource.getAlerts());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, PriceAlert>> createAlert(PriceAlert alert) async {
    try {
      final created = await remoteDataSource.createAlert(alert);
      await localDataSource.createAlert(created);
      return Right(created);
    } on AuthException {
      return Left(ServerFailure(message: 'Authentication required'));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to create alert: $e'));
    }
  }

  @override
  Future<Either<Failure, PriceAlert>> updateAlert(PriceAlert alert) async {
    try {
      final updated = await remoteDataSource.updateAlert(alert);
      await localDataSource.updateAlert(updated);
      return Right(updated);
    } on AuthException {
      return Left(ServerFailure(message: 'Authentication required'));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to update alert: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAlert(String id) async {
    try {
      await remoteDataSource.deleteAlert(id);
      await localDataSource.deleteAlert(id);
      return const Right(null);
    } on AuthException {
      return Left(ServerFailure(message: 'Authentication required'));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to delete alert: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> toggleAlert(String id, bool isActive) async {
    try {
      // Get the current alert, flip isActive, PUT to remote
      final alerts = await localDataSource.getAlerts();
      final alert = alerts.firstWhere((a) => a.id == id);
      final toggled = alert.copyWith(isActive: isActive);
      await remoteDataSource.updateAlert(toggled);
      await localDataSource.toggleAlert(id, isActive);
      return const Right(null);
    } on AuthException {
      return Left(ServerFailure(message: 'Authentication required'));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to toggle alert: $e'));
    }
  }

  /// Server-side alert checking — the Lambda alert-checker runs on a
  /// 1-minute schedule, so the client doesn't need to poll.
  @override
  Future<Either<Failure, List<PriceAlert>>> checkAlerts(
    Map<String, double> currentPrices,
  ) async {
    return const Right([]);
  }

  @override
  Stream<List<PriceAlert>> watchAlerts() {
    return localDataSource.watchAlerts();
  }
}
