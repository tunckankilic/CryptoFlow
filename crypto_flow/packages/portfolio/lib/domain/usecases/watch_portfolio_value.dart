import 'package:core/error/failures.dart';
import 'package:dartz/dartz.dart';
import '../entities/portfolio_summary.dart';
import '../repositories/portfolio_repository.dart';

/// Parameters for WatchPortfolioValue use case
class WatchPortfolioValueParams {
  /// Stream of current prices (symbol -> price)
  final Stream<Map<String, double>> priceStream;

  /// Optional BTC price stream for BTC value calculation
  final Stream<double>? btcPriceStream;

  WatchPortfolioValueParams({
    required this.priceStream,
    this.btcPriceStream,
  });
}

/// Use case to watch portfolio value with real-time price updates
class WatchPortfolioValue {
  final PortfolioRepository repository;

  WatchPortfolioValue(this.repository);

  /// Watch portfolio value with real-time price updates
  Stream<Either<Failure, PortfolioSummary>> call(
    WatchPortfolioValueParams params,
  ) async* {
    // Watch holdings
    await for (final holdings in repository.watchHoldings()) {
      // For each holding update, also listen to price updates
      await for (final prices in params.priceStream) {
        if (holdings.isEmpty) {
          yield Right(PortfolioSummary.empty());
          continue;
        }

        double totalValue = 0;
        double totalInvested = 0;
        final allocation = <String, double>{};

        // Calculate total value and invested amount
        for (final holding in holdings) {
          final currentPrice = prices[holding.symbol] ?? 0;
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
        // For simplicity, assume BTC price is in the prices map as 'BTCUSDT'
        final btcPrice = prices['BTCUSDT'] ?? 0;
        final btcValue = btcPrice > 0 ? totalValue / btcPrice : 0;

        // Convert allocation to percentages
        final allocationPercent = <String, double>{};
        if (totalValue > 0) {
          allocation.forEach((symbol, value) {
            allocationPercent[symbol] = (value / totalValue) * 100;
          });
        }

        yield Right(
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
      }
    }
  }
}
