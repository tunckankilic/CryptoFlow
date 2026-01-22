import 'package:core/error/failures.dart';
import 'package:core/usecases/usecase.dart';
import 'package:dartz/dartz.dart';
import '../entities/price_alert.dart';
import '../repositories/alert_repository.dart';

/// Parameters for CheckAlerts use case
class CheckAlertsParams {
  /// Map of symbol to current price
  final Map<String, double> currentPrices;

  CheckAlertsParams({required this.currentPrices});
}

/// Use case to check alerts against current prices
/// Returns list of triggered alerts
class CheckAlerts implements UseCase<List<PriceAlert>, CheckAlertsParams> {
  final AlertRepository repository;

  CheckAlerts(this.repository);

  @override
  Future<Either<Failure, List<PriceAlert>>> call(
    CheckAlertsParams params,
  ) async {
    return await repository.checkAlerts(params.currentPrices);
  }
}
