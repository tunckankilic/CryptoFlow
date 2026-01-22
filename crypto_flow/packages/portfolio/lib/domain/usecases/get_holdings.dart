import 'package:core/error/failures.dart';
import 'package:core/usecases/usecase.dart';
import 'package:dartz/dartz.dart';
import '../entities/holding.dart';
import '../repositories/portfolio_repository.dart';

/// Use case to get all current holdings
class GetHoldings implements UseCase<List<Holding>, NoParams> {
  final PortfolioRepository repository;

  GetHoldings(this.repository);

  @override
  Future<Either<Failure, List<Holding>>> call(NoParams params) async {
    return await repository.getHoldings();
  }
}
