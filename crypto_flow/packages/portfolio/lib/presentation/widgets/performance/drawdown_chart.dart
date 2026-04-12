import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../domain/entities/performance_metrics.dart';

/// Area chart showing portfolio drawdown over monthly returns
class DrawdownChart extends StatelessWidget {
  final List<MonthlyReturn> monthlyReturns;
  final double maxDrawdownPct;

  const DrawdownChart({
    super.key,
    required this.monthlyReturns,
    required this.maxDrawdownPct,
  });

  @override
  Widget build(BuildContext context) {
    if (monthlyReturns.isEmpty) return const SizedBox();

    // Build cumulative return series
    final cumulative = <double>[0];
    for (final m in monthlyReturns) {
      cumulative.add(cumulative.last + m.returnPct);
    }

    // Calculate drawdown series
    final drawdowns = <double>[];
    double peak = cumulative[0];
    for (final v in cumulative) {
      if (v > peak) peak = v;
      drawdowns.add(v - peak); // negative values = drawdown
    }

    final spots = drawdowns
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    return Card(
      child: Padding(
        padding: AppSpacing.paddingMD,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Drawdown', style: AppTypography.h5),
                Text(
                  'Max: ${maxDrawdownPct.toStringAsFixed(1)}%',
                  style: AppTypography.caption.copyWith(
                    color: CryptoColors.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 5,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: CryptoColors.borderDark,
                      strokeWidth: 0.5,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) => Text(
                          '${value.toInt()}%',
                          style: AppTypography.caption,
                        ),
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: CryptoColors.error,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: CryptoColors.error.withOpacity(0.15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
