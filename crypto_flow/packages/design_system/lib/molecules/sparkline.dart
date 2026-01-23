import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../atoms/app_colors.dart';

/// Mini sparkline chart for visualizing price trends
class Sparkline extends StatelessWidget {
  final List<double> data;
  final Color? lineColor;
  final bool showGradient;
  final double height;
  final double? width;

  const Sparkline({
    super.key,
    required this.data,
    this.lineColor,
    this.showGradient = true,
    this.height = 40.0,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return SizedBox(
        height: height,
        width: width,
        child: const Center(
          child: Icon(Icons.show_chart,
              size: 20, color: CryptoColors.textTertiary),
        ),
      );
    }

    // Determine line color based on trend (first vs last)
    final isPositiveTrend = data.last >= data.first;
    final effectiveLineColor = lineColor ??
        (isPositiveTrend ? CryptoColors.priceUp : CryptoColors.priceDown);

    return SizedBox(
      height: height,
      width: width,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (data.length - 1).toDouble(),
          minY: _getMinValue(),
          maxY: _getMaxValue(),
          lineBarsData: [
            LineChartBarData(
              spots: _getSpots(),
              isCurved: true,
              color: effectiveLineColor,
              barWidth: 1.5,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: showGradient
                  ? BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          effectiveLineColor.withValues(alpha: 0.3),
                          effectiveLineColor.withValues(alpha: 0.0),
                        ],
                      ),
                    )
                  : BarAreaData(show: false),
            ),
          ],
          lineTouchData: const LineTouchData(enabled: false),
        ),
        duration: Duration.zero, // No animation for sparklines
      ),
    );
  }

  List<FlSpot> _getSpots() {
    return List.generate(
      data.length,
      (index) => FlSpot(index.toDouble(), data[index]),
    );
  }

  double _getMinValue() {
    if (data.isEmpty) return 0;
    final min = data.reduce((a, b) => a < b ? a : b);
    final max = data.reduce((a, b) => a > b ? a : b);
    final range = max - min;
    // Add 5% padding at the bottom
    return min - (range * 0.05);
  }

  double _getMaxValue() {
    if (data.isEmpty) return 0;
    final min = data.reduce((a, b) => a < b ? a : b);
    final max = data.reduce((a, b) => a > b ? a : b);
    final range = max - min;
    // Add 5% padding at the top
    return max + (range * 0.05);
  }
}
