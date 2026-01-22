import 'package:flutter/material.dart';
import '../../domain/entities/portfolio_summary.dart';
import 'package:design_system/design_system.dart';
import 'package:core/utils/formatters.dart';

/// Card showing portfolio summary statistics
class PortfolioSummaryCard extends StatelessWidget {
  final PortfolioSummary summary;

  const PortfolioSummaryCard({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final isProfit = summary.isProfit;

    return Card(
      child: Padding(
        padding: AppSpacing.paddingLG,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'Portfolio Value',
              style: AppTypography.caption.copyWith(
                color: CryptoColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),

            // Total value
            Text(
              CryptoFormatters.formatPrice(summary.totalValue),
              style: AppTypography.h2,
            ),
            const SizedBox(height: 4),

            // BTC value
            if (summary.btcValue > 0)
              Text(
                '≈ ${summary.btcValue.toStringAsFixed(8)} BTC',
                style: AppTypography.caption.copyWith(
                  color: CryptoColors.textSecondary,
                ),
              ),
            const SizedBox(height: 24),

            // Stats row
            Row(
              children: [
                // Total invested
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Invested',
                        style: AppTypography.caption.copyWith(
                          color: CryptoColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CryptoFormatters.formatPrice(summary.totalInvested),
                        style: AppTypography.h5,
                      ),
                    ],
                  ),
                ),

                // Total PnL
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Total P&L',
                        style: AppTypography.caption.copyWith(
                          color: CryptoColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            isProfit
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            size: 16,
                            color: isProfit
                                ? CryptoColors.priceUp
                                : CryptoColors.priceDown,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            CryptoFormatters.formatPrice(
                                summary.totalPnl.abs()),
                            style: AppTypography.h5.copyWith(
                              color: isProfit
                                  ? CryptoColors.priceUp
                                  : CryptoColors.priceDown,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      PercentChange(
                        percent: summary.totalPnlPercent,
                        showIcon: false,
                        size: PercentChangeSize.small,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Number of assets
            const SizedBox(height: 16),
            Text(
              '${summary.numberOfAssets} ${summary.numberOfAssets == 1 ? 'asset' : 'assets'}',
              style: AppTypography.caption.copyWith(
                color: CryptoColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
