import 'package:flutter/material.dart';
import '../../domain/entities/holding.dart';
import 'package:design_system/design_system.dart';
import 'package:core/utils/formatters.dart';

/// Widget displaying a single holding with current value and PnL
class HoldingTile extends StatelessWidget {
  final Holding holding;
  final double currentPrice;

  const HoldingTile({
    super.key,
    required this.holding,
    required this.currentPrice,
  });

  @override
  Widget build(BuildContext context) {
    final currentValue = holding.currentValue(currentPrice);
    final pnl = holding.pnl(currentPrice);
    final pnlPercent = holding.pnlPercent(currentPrice);
    final isProfit = holding.isProfit(currentPrice);

    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (context) => _HoldingActionsSheet(
            symbol: holding.symbol,
            currentPrice: currentPrice,
          ),
        );
      },
      child: Card(
        margin: AppSpacing.paddingMD,
        child: Padding(
          padding: AppSpacing.paddingMD,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Symbol and current price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    holding.baseAsset,
                    style: AppTypography.h4,
                  ),
                  Text(
                    CryptoFormatters.formatPrice(currentPrice),
                    style: AppTypography.priceSmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Quantity and average buy price
              Row(
                children: [
                  Text(
                    'Qty: ${holding.quantity.toStringAsFixed(8)}',
                    style: AppTypography.caption.copyWith(
                      color: CryptoColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Avg: ${CryptoFormatters.formatPrice(holding.avgBuyPrice)}',
                    style: AppTypography.caption.copyWith(
                      color: CryptoColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Current value and PnL
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Value',
                        style: AppTypography.caption.copyWith(
                          color: CryptoColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CryptoFormatters.formatPrice(currentValue),
                        style: AppTypography.h5,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'P&L',
                        style: AppTypography.caption.copyWith(
                          color: CryptoColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
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
                            CryptoFormatters.formatPrice(pnl.abs()),
                            style: AppTypography.h5.copyWith(
                              color: isProfit
                                  ? CryptoColors.priceUp
                                  : CryptoColors.priceDown,
                            ),
                          ),
                          const SizedBox(width: 8),
                          PercentChange(
                            percent: pnlPercent,
                            showIcon: false,
                            size: PercentChangeSize.small,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet with actions for aholding
class _HoldingActionsSheet extends StatelessWidget {
  final String symbol;
  final double currentPrice;

  const _HoldingActionsSheet({
    required this.symbol,
    required this.currentPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingLG,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.book),
            title: const Text('Add to Journal'),
            subtitle: const Text('Log this trade in your journal'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/portfolio/journal/add');
            },
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}
