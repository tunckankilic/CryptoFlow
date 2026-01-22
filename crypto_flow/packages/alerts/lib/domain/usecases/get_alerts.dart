import 'package:core/error/failures.dart';
import 'package:core/usecases/usecase.dart';
import 'package:dartz/dartz.dart';
import '../entities/price_alert.dart';
import '../repositories/alert_repository.dart';

/// Use case to get all alerts
class GetAlerts implements UseCase<List<PriceAlert>, NoParams> {
  final AlertRepository repository;

  GetAlerts(this.repository);

  @override
  Future<Either<Failure, List<PriceAlert>>> call(NoParams params) async {
    return await repository.getAlerts();
  }
}
