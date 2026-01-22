import 'package:core/error/failures.dart';
import 'package:core/usecases/usecase.dart';
import 'package:dartz/dartz.dart';
import '../repositories/alert_repository.dart';

/// Parameters for DeleteAlert use case
class DeleteAlertParams {
  final String id;

  DeleteAlertParams({required this.id});
}

/// Use case to delete an alert
class DeleteAlert implements UseCase<void, DeleteAlertParams> {
  final AlertRepository repository;

  DeleteAlert(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteAlertParams params) async {
    return await repository.deleteAlert(params.id);
  }
}
