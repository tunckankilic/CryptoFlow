import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../../../domain/entities/performance_metrics.dart';

/// Color-coded grid showing monthly returns
class MonthlyReturnsHeatmap extends StatelessWidget {
  final List<MonthlyReturn> monthlyReturns;

  const MonthlyReturnsHeatmap({
    super.key,
    required this.monthlyReturns,
  });

  Color _cellColor(double pct) {
    if (pct >= 10) return CryptoColors.priceUp;
    if (pct > 0) return CryptoColors.priceUp.withValues(alpha: 0.5);
    if (pct == 0) return CryptoColors.borderDark;
    if (pct > -10) return CryptoColors.priceDown.withValues(alpha: 0.5);
    return CryptoColors.priceDown;
  }

  @override
  Widget build(BuildContext context) {
    if (monthlyReturns.isEmpty) return const SizedBox();

    return Card(
      child: Padding(
        padding: AppSpacing.paddingMD,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Monthly Returns', style: AppTypography.h5),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: monthlyReturns.map((m) {
                return Tooltip(
                  message:
                      '${m.month}: ${m.returnPct >= 0 ? "+" : ""}${m.returnPct.toStringAsFixed(1)}%',
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _cellColor(m.returnPct),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          m.month.substring(5), // MM
                          style: AppTypography.caption.copyWith(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          '${m.returnPct >= 0 ? "+" : ""}${m.returnPct.toStringAsFixed(1)}%',
                          style: AppTypography.caption.copyWith(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.sm),
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendItem(color: CryptoColors.priceDown, label: '< -10%'),
                _LegendItem(
                    color: CryptoColors.priceDown.withValues(alpha: 0.5),
                    label: '-10..0%'),
                _LegendItem(
                    color: CryptoColors.priceUp.withValues(alpha: 0.5),
                    label: '0..+10%'),
                _LegendItem(color: CryptoColors.priceUp, label: '> +10%'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 2),
          Text(label, style: const TextStyle(fontSize: 9)),
        ],
      ),
    );
  }
}
