import 'package:core/error/failures.dart';
import 'package:core/usecases/usecase.dart';
import 'package:dartz/dartz.dart';

import '../repositories/journal_repository.dart';

/// Parameters for GetEquityCurve use case
class GetEquityCurveParams {
  final int? days;

  GetEquityCurveParams({this.days});
}

/// Use case to get equity curve (cumulative P&L over time)
/// Returns an array of cumulative P&L values
class GetEquityCurve implements UseCase<List<double>, GetEquityCurveParams> {
  final JournalRepository repository;

  GetEquityCurve(this.repository);

  @override
  Future<Either<Failure, List<double>>> call(
      GetEquityCurveParams params) async {
    // Validate days if provided
    if (params.days != null && params.days! <= 0) {
      return Left(ValidationFailure('Days must be positive'));
    }

    // Get equity curve from repository
    return await repository.getEquityCurve(days: params.days);
  }
}
