import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../domain/entities/performance_metrics.dart';

/// Bar chart comparing portfolio returns against benchmarks (BTC, ETH)
class BenchmarkComparisonChart extends StatelessWidget {
  final List<BenchmarkComparison> benchmarks;

  const BenchmarkComparisonChart({
    super.key,
    required this.benchmarks,
  });

  @override
  Widget build(BuildContext context) {
    if (benchmarks.isEmpty) return const SizedBox();

    return Card(
      child: Padding(
        padding: AppSpacing.paddingMD,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Benchmark Comparison', style: AppTypography.h5),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceEvenly,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= benchmarks.length) {
                            return const SizedBox();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              benchmarks[idx].symbol,
                              style: AppTypography.caption,
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 45,
                        getTitlesWidget: (value, meta) => Text(
                          '${value.toInt()}%',
                          style: AppTypography.caption,
                        ),
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: CryptoColors.borderDark,
                      strokeWidth: 0.5,
                    ),
                  ),
                  barGroups: benchmarks.asMap().entries.map((entry) {
                    final i = entry.key;
                    final b = entry.value;
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: b.portfolioReturnPct,
                          color: CryptoColors.primary,
                          width: 16,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                        BarChartRodData(
                          toY: b.benchmarkReturnPct,
                          color: CryptoColors.chartOrange,
                          width: 16,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendDot(color: CryptoColors.primary, label: 'Portfolio'),
                const SizedBox(width: AppSpacing.md),
                _LegendDot(
                    color: CryptoColors.chartOrange, label: 'Benchmark'),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            // Alpha display
            ...benchmarks.map(
              (b) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  'Alpha vs ${b.symbol}: ${b.alpha >= 0 ? "+" : ""}${b.alpha.toStringAsFixed(2)}%',
                  style: AppTypography.caption.copyWith(
                    color: b.alpha >= 0
                        ? CryptoColors.success
                        : CryptoColors.error,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppTypography.caption),
      ],
    );
  }
}
