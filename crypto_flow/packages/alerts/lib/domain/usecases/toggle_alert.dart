import 'package:core/error/failures.dart';
import 'package:core/usecases/usecase.dart';
import 'package:dartz/dartz.dart';
import '../repositories/alert_repository.dart';

/// Parameters for ToggleAlert use case
class ToggleAlertParams {
  final String id;
  final bool isActive;

  ToggleAlertParams({
    required this.id,
    required this.isActive,
  });
}

/// Use case to toggle alert active status
class ToggleAlert implements UseCase<void, ToggleAlertParams> {
  final AlertRepository repository;

  ToggleAlert(this.repository);

  @override
  Future<Either<Failure, void>> call(ToggleAlertParams params) async {
    return await repository.toggleAlert(params.id, params.isActive);
  }
}
