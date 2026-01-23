import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/macd_result.dart';

/// Widget displaying the MACD (Moving Average Convergence Divergence) indicator panel
class MACDPanel extends StatelessWidget {
  /// MACD calculation result
  final MACDResult macdResult;

  /// Height of the panel
  final double height;

  const MACDPanel({
    super.key,
    required this.macdResult,
    this.height = 120,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (macdResult.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(
          child: Text('Insufficient data for MACD'),
        ),
      );
    }

    // Build MACD line spots
    final macdSpots = <FlSpot>[];
    final signalSpots = <FlSpot>[];
    final histogramBars = <BarChartGroupData>[];

    double minY = 0;
    double maxY = 0;

    for (int i = 0; i < macdResult.length; i++) {
      if (macdResult.macdLine[i] != null) {
        macdSpots.add(FlSpot(i.toDouble(), macdResult.macdLine[i]!));
        minY = minY < macdResult.macdLine[i]! ? minY : macdResult.macdLine[i]!;
        maxY = maxY > macdResult.macdLine[i]! ? maxY : macdResult.macdLine[i]!;
      }

      if (macdResult.signalLine[i] != null) {
        signalSpots.add(FlSpot(i.toDouble(), macdResult.signalLine[i]!));
        minY =
            minY < macdResult.signalLine[i]! ? minY : macdResult.signalLine[i]!;
        maxY =
            maxY > macdResult.signalLine[i]! ? maxY : macdResult.signalLine[i]!;
      }

      if (macdResult.histogram[i] != null) {
        final value = macdResult.histogram[i]!;
        minY = minY < value ? minY : value;
        maxY = maxY > value ? maxY : value;

        histogramBars.add(
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: value,
                color: value >= 0
                    ? Colors.green.withOpacity(0.6)
                    : Colors.red.withOpacity(0.6),
                width: 2,
                borderRadius: BorderRadius.zero,
              ),
            ],
          ),
        );
      }
    }

    // Add padding to Y range
    final yRange = maxY - minY;
    minY -= yRange * 0.1;
    maxY += yRange * 0.1;

    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 4),
            child: Row(
              children: [
                const Text(
                  'MACD',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                _buildLegend('MACD', Colors.blue),
                _buildLegend('Signal', Colors.orange),
                _buildLegend('Hist', Colors.grey),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                // Histogram bars
                if (histogramBars.isNotEmpty)
                  BarChart(
                    BarChartData(
                      minY: minY,
                      maxY: maxY,
                      barGroups: histogramBars,
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      barTouchData: BarTouchData(enabled: false),
                    ),
                  ),
                // MACD and Signal lines
                LineChart(
                  LineChartData(
                    minY: minY,
                    maxY: maxY,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: yRange / 4,
                      getDrawingHorizontalLine: (value) {
                        if (value.abs() < 0.001) {
                          return FlLine(
                            color: isDark
                                ? Colors.white.withOpacity(0.3)
                                : Colors.black.withOpacity(0.3),
                            strokeWidth: 0.5,
                          );
                        }
                        return FlLine(
                          color: isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.black.withOpacity(0.05),
                          strokeWidth: 0.5,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 9,
                                color: isDark ? Colors.white54 : Colors.black54,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      // MACD Line
                      LineChartBarData(
                        spots: macdSpots,
                        isCurved: true,
                        curveSmoothness: 0.2,
                        color: Colors.blue,
                        barWidth: 1.5,
                        dotData: const FlDotData(show: false),
                      ),
                      // Signal Line
                      LineChartBarData(
                        spots: signalSpots,
                        isCurved: true,
                        curveSmoothness: 0.2,
                        color: Colors.orange,
                        barWidth: 1.5,
                        dotData: const FlDotData(show: false),
                      ),
                    ],
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            final label =
                                spot.barIndex == 0 ? 'MACD' : 'Signal';
                            return LineTooltipItem(
                              '$label: ${spot.y.toStringAsFixed(4)}',
                              TextStyle(
                                color: spot.barIndex == 0
                                    ? Colors.blue
                                    : Colors.orange,
                                fontSize: 12,
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 3,
            color: color,
          ),
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
