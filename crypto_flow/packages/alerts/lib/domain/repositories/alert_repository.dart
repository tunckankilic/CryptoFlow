import 'package:core/error/failures.dart';
import 'package:dartz/dartz.dart';
import '../entities/price_alert.dart';

/// Abstract repository interface for alert operations
abstract class AlertRepository {
  /// Get all alerts
  Future<Either<Failure, List<PriceAlert>>> getAlerts();

  /// Create a new alert
  Future<Either<Failure, PriceAlert>> createAlert(PriceAlert alert);

  /// Delete an alert by ID
  Future<Either<Failure, void>> deleteAlert(String id);

  /// Toggle alert active status
  Future<Either<Failure, void>> toggleAlert(String id, bool isActive);

  /// Update an alert
  Future<Either<Failure, PriceAlert>> updateAlert(PriceAlert alert);

  /// Check alerts against current prices and trigger if needed
  Future<Either<Failure, List<PriceAlert>>> checkAlerts(
    Map<String, double> currentPrices,
  );

  /// Watch alerts for real-time updates
  Stream<List<PriceAlert>> watchAlerts();
}
