import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:design_system/design_system.dart';

/// Line chart showing portfolio P&L over time
class PnLChart extends StatelessWidget {
  final List<FlSpot> data;
  final double breakEvenValue;

  const PnLChart({
    super.key,
    required this.data,
    required this.breakEvenValue,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox.shrink();
    }

    final minY = data.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final maxY = data.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final range = maxY - minY;

    return Card(
      child: Padding(
        padding: AppSpacing.paddingLG,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Portfolio Performance',
              style: AppTypography.h4,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles:
                          SideTitles(showTitles: true, reservedSize: 40),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minY: minY - (range * 0.1),
                  maxY: maxY + (range * 0.1),
                  lineBarsData: [
                    LineChartBarData(
                      spots: data,
                      isCurved: true,
                      color: CryptoColors.chartLine,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: CryptoColors.chartFill,
                      ),
                    ),
                  ],
                  extraLinesData: ExtraLinesData(
                    horizontalLines: [
                      HorizontalLine(
                        y: breakEvenValue,
                        color: CryptoColors.priceNeutral,
                        strokeWidth: 1,
                        dashArray: [5, 5],
                        label: HorizontalLineLabel(
                          show: true,
                          labelResolver: (_) => 'Break Even',
                          style: AppTypography.caption.copyWith(
                            color: CryptoColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
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
