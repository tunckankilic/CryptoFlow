import 'package:core/error/failures.dart';
import 'package:core/usecases/usecase.dart';
import 'package:dartz/dartz.dart';
import '../entities/portfolio_summary.dart';
import '../repositories/portfolio_repository.dart';

/// Parameters for GetPortfolioValue use case
class GetPortfolioValueParams {
  /// Map of symbol to current price
  final Map<String, double> currentPrices;

  /// Optional BTC price for BTC value calculation
  final double? btcPrice;

  GetPortfolioValueParams({
    required this.currentPrices,
    this.btcPrice,
  });
}

/// Use case to calculate portfolio value with current market prices
class GetPortfolioValue
    implements UseCase<PortfolioSummary, GetPortfolioValueParams> {
  final PortfolioRepository repository;

  GetPortfolioValue(this.repository);

  @override
  Future<Either<Failure, PortfolioSummary>> call(
    GetPortfolioValueParams params,
  ) async {
    // Get holdings
    final holdingsResult = await repository.getHoldings();

    return holdingsResult.fold(
      (failure) => Left(failure),
      (holdings) {
        if (holdings.isEmpty) {
          return Right(PortfolioSummary.empty());
        }

        double totalValue = 0;
        double totalInvested = 0;
        final allocation = <String, double>{};

        // Calculate total value and invested amount
        for (final holding in holdings) {
          final currentPrice = params.currentPrices[holding.symbol] ?? 0;
          final value = holding.currentValue(currentPrice);
          final invested = holding.totalCost;

          totalValue += value;
          totalInvested += invested;
          allocation[holding.baseAsset] = value;
        }

        // Calculate PnL
        final totalPnl = totalValue - totalInvested;
        final totalPnlPercent =
            totalInvested > 0 ? (totalPnl / totalInvested) * 100 : 0;

        // Calculate BTC value
        final btcValue = params.btcPrice != null && params.btcPrice! > 0
            ? totalValue / params.btcPrice!
            : 0;

        // Convert allocation to percentages
        final allocationPercent = <String, double>{};
        if (totalValue > 0) {
          allocation.forEach((symbol, value) {
            allocationPercent[symbol] = (value / totalValue) * 100;
          });
        }

        return Right(
          PortfolioSummary(
            totalValue: totalValue,
            totalInvested: totalInvested,
            totalPnl: totalPnl,
            totalPnlPercent: double.parse(totalPnlPercent.toStringAsFixed(2)),
            btcValue: double.parse(btcValue.toStringAsFixed(2)),
            allocation: allocationPercent,
            holdings: holdings,
          ),
        );
      },
    );
  }
}
