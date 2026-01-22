import 'package:core/error/failures.dart';
import 'package:core/usecases/usecase.dart';
import 'package:dartz/dartz.dart';
import '../repositories/portfolio_repository.dart';

/// Parameters for GetPnL use case
class GetPnLParams {
  /// Map of symbol to current price
  final Map<String, double> currentPrices;

  /// Optional symbol to filter by
  final String? symbol;

  GetPnLParams({
    required this.currentPrices,
    this.symbol,
  });
}

/// Result of PnL calculation
class PnLResult {
  final double totalPnl;
  final double totalPnlPercent;
  final Map<String, double> pnlBySymbol;
  final Map<String, double> pnlPercentBySymbol;

  PnLResult({
    required this.totalPnl,
    required this.totalPnlPercent,
    required this.pnlBySymbol,
    required this.pnlPercentBySymbol,
  });
}

/// Use case to calculate profit/loss for portfolio or specific holding
class GetPnL implements UseCase<PnLResult, GetPnLParams> {
  final PortfolioRepository repository;

  GetPnL(this.repository);

  @override
  Future<Either<Failure, PnLResult>> call(GetPnLParams params) async {
    final holdingsResult = await repository.getHoldings();

    return holdingsResult.fold(
      (failure) => Left(failure),
      (holdings) {
        // Filter by symbol if specified
        var filteredHoldings = holdings;
        if (params.symbol != null) {
          filteredHoldings =
              holdings.where((h) => h.symbol == params.symbol).toList();
        }

        double totalPnl = 0;
        double totalInvested = 0;
        final pnlBySymbol = <String, double>{};
        final pnlPercentBySymbol = <String, double>{};

        for (final holding in filteredHoldings) {
          final currentPrice = params.currentPrices[holding.symbol] ?? 0;
          final pnl = holding.pnl(currentPrice);
          final pnlPercent = holding.pnlPercent(currentPrice);

          totalPnl += pnl;
          totalInvested += holding.totalCost;

          pnlBySymbol[holding.symbol] = pnl;
          pnlPercentBySymbol[holding.symbol] = pnlPercent;
        }

        final totalPnlPercent =
            totalInvested > 0 ? (totalPnl / totalInvested) * 100 : 0;

        return Right(
          PnLResult(
            totalPnl: totalPnl,
            totalPnlPercent: double.parse(totalPnlPercent.toStringAsFixed(2)),
            pnlBySymbol: pnlBySymbol,
            pnlPercentBySymbol: pnlPercentBySymbol,
          ),
        );
      },
    );
  }
}
