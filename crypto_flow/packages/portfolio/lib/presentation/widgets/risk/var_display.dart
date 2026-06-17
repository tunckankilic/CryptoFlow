import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../../../domain/entities/risk_metrics.dart';

class VaRDisplay extends StatelessWidget {
  final VaRResult result;

  const VaRDisplay({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Value at Risk (VaR)', style: AppTypography.h5),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${result.confidence.toStringAsFixed(0)}% confidence, '
              '${result.holdingPeriodDays}-day holding period',
              style: const TextStyle(color: CryptoColors.textTertiary, fontSize: 12),
            ),
            const SizedBox(height: AppSpacing.md),
            // Main VaR card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: CryptoColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: CryptoColors.error.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  const Text(
                    'Maximum Expected Loss',
                    style: TextStyle(color: CryptoColors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${result.historicalVaR.toStringAsFixed(2)}',
                    style: AppTypography.h3.copyWith(color: CryptoColors.error),
                  ),
                  Text(
                    '${(result.historicalVaRPct * 100).toStringAsFixed(2)}% of portfolio',
                    style: const TextStyle(color: CryptoColors.error, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Portfolio value
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Portfolio Value', style: TextStyle(color: CryptoColors.textSecondary)),
                Text('\$${result.portfolioValue.toStringAsFixed(2)}', style: AppTypography.label),
              ],
            ),
            const Divider(height: AppSpacing.lg),
            // Component VaR breakdown
            if (result.componentVaR.isNotEmpty) ...[
              Text('Component VaR Breakdown', style: AppTypography.h6),
              const SizedBox(height: AppSpacing.sm),
              ...result.componentVaR.map((c) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(c.symbol, style: AppTypography.label),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            '${(c.weight * 100).toStringAsFixed(1)}%',
                            style: const TextStyle(color: CryptoColors.textSecondary),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: LinearProgressIndicator(
                            value: result.historicalVaR > 0
                                ? (c.var_ / result.historicalVaR).clamp(0, 1)
                                : 0,
                            backgroundColor: Colors.grey.withValues(alpha: 0.2),
                            color: CryptoColors.error,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        SizedBox(
                          width: 80,
                          child: Text(
                            '\$${c.var_.toStringAsFixed(2)}',
                            textAlign: TextAlign.end,
                            style: const TextStyle(color: CryptoColors.error),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}
