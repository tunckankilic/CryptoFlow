import 'package:core/error/failures.dart';
import 'package:core/usecases/usecase.dart';
import 'package:dartz/dartz.dart';
import '../entities/price_alert.dart';
import '../repositories/alert_repository.dart';

/// Parameters for CreateAlert use case
class CreateAlertParams {
  final PriceAlert alert;

  CreateAlertParams({required this.alert});
}

/// Use case to create a new alert
class CreateAlert implements UseCase<PriceAlert, CreateAlertParams> {
  final AlertRepository repository;

  CreateAlert(this.repository);

  @override
  Future<Either<Failure, PriceAlert>> call(CreateAlertParams params) async {
    // Validation
    if (params.alert.targetPrice <= 0) {
      return Left(ValidationFailure('Target price must be positive'));
    }

    if (params.alert.type == AlertType.percentUp ||
        params.alert.type == AlertType.percentDown) {
      if (params.alert.percentChange == null ||
          params.alert.percentChange! <= 0) {
        return Left(ValidationFailure(
            'Percent change must be positive for percent alerts'));
      }
      if (params.alert.basePrice == null || params.alert.basePrice! <= 0) {
        return Left(
            ValidationFailure('Base price must be set for percent alerts'));
      }
    }

    return await repository.createAlert(params.alert);
  }
}
