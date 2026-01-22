import 'package:core/error/failures.dart';
import 'package:core/usecases/usecase.dart';
import 'package:dartz/dartz.dart';
import '../repositories/portfolio_repository.dart';

/// Parameters for GetAllocation use case
class GetAllocationParams {
  /// Map of symbol to current price
  final Map<String, double> currentPrices;

  GetAllocationParams({required this.currentPrices});
}

/// Result of allocation calculation
class AllocationResult {
  /// Map of baseAsset to allocation percentage
  final Map<String, double> allocationPercent;

  /// Map of baseAsset to value in quote currency
  final Map<String, double> allocationValue;

  /// Total portfolio value
  final double totalValue;

  AllocationResult({
    required this.allocationPercent,
    required this.allocationValue,
    required this.totalValue,
  });
}

/// Use case to calculate asset allocation in portfolio
class GetAllocation implements UseCase<AllocationResult, GetAllocationParams> {
  final PortfolioRepository repository;

  GetAllocation(this.repository);

  @override
  Future<Either<Failure, AllocationResult>> call(
    GetAllocationParams params,
  ) async {
    final holdingsResult = await repository.getHoldings();

    return holdingsResult.fold(
      (failure) => Left(failure),
      (holdings) {
        if (holdings.isEmpty) {
          return Right(
            AllocationResult(
              allocationPercent: {},
              allocationValue: {},
              totalValue: 0,
            ),
          );
        }

        final allocationValue = <String, double>{};
        double totalValue = 0;

        // Calculate value for each asset
        for (final holding in holdings) {
          final currentPrice = params.currentPrices[holding.symbol] ?? 0;
          final value = holding.currentValue(currentPrice);

          allocationValue[holding.baseAsset] =
              (allocationValue[holding.baseAsset] ?? 0) + value;
          totalValue += value;
        }

        // Convert to percentages
        final allocationPercent = <String, double>{};
        if (totalValue > 0) {
          allocationValue.forEach((symbol, value) {
            allocationPercent[symbol] = (value / totalValue) * 100;
          });
        }

        return Right(
          AllocationResult(
            allocationPercent: allocationPercent,
            allocationValue: allocationValue,
            totalValue: totalValue,
          ),
        );
      },
    );
  }
}
