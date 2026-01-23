import 'package:core/error/failures.dart';
import 'package:core/usecases/usecase.dart';
import 'package:dartz/dartz.dart';
import '../entities/transaction.dart';
import '../repositories/portfolio_repository.dart';

/// Parameters for AddTransaction use case
class AddTransactionParams {
  final Transaction transaction;

  AddTransactionParams({required this.transaction});
}

/// Use case to add a new transaction to the portfolio
/// This will automatically recalculate the average buy price for the holding
class AddTransaction implements UseCase<void, AddTransactionParams> {
  final PortfolioRepository repository;

  AddTransaction(this.repository);

  @override
  Future<Either<Failure, void>> call(AddTransactionParams params) async {
    // Validate transaction data
    if (params.transaction.quantity <= 0) {
      return Left(ValidationFailure('Quantity must be positive'));
    }

    if (params.transaction.price <= 0) {
      return Left(ValidationFailure('Price must be positive'));
    }

    // Add transaction to repository
    // The repository implementation will handle recalculating average buy price
    return await repository.addTransaction(params.transaction);
  }
}
