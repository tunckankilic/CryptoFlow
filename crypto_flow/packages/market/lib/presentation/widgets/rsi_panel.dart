import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Widget displaying the RSI (Relative Strength Index) indicator panel
class RSIPanel extends StatelessWidget {
  /// RSI values (0-100, can contain nulls for insufficient data)
  final List<double?> rsiValues;

  /// Height of the panel
  final double height;

  /// Overbought level (default: 70)
  final double overboughtLevel;

  /// Oversold level (default: 30)
  final double oversoldLevel;

  const RSIPanel({
    super.key,
    required this.rsiValues,
    this.height = 100,
    this.overboughtLevel = 70,
    this.oversoldLevel = 30,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Filter out nulls and build spots
    final spots = <FlSpot>[];
    for (int i = 0; i < rsiValues.length; i++) {
      if (rsiValues[i] != null) {
        spots.add(FlSpot(i.toDouble(), rsiValues[i]!));
      }
    }

    if (spots.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(
          child: Text('Insufficient data for RSI'),
        ),
      );
    }

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
                Text(
                  'RSI (14)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade300,
                  ),
                ),
                const SizedBox(width: 8),
                if (spots.isNotEmpty)
                  Text(
                    spots.last.y.toStringAsFixed(2),
                    style: TextStyle(
                      fontSize: 12,
                      color: _getRSIColor(spots.last.y),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 100,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 10,
                  getDrawingHorizontalLine: (value) {
                    if (value == overboughtLevel || value == oversoldLevel) {
                      return FlLine(
                        color: value == overboughtLevel
                            ? Colors.red.withOpacity(0.5)
                            : Colors.green.withOpacity(0.5),
                        strokeWidth: 1,
                        dashArray: [5, 5],
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
                      reservedSize: 35,
                      getTitlesWidget: (value, meta) {
                        if (value == 0 ||
                            value == 30 ||
                            value == 50 ||
                            value == 70 ||
                            value == 100) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark ? Colors.white54 : Colors.black54,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.2,
                    color: Colors.purple,
                    barWidth: 1.5,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.purple.withOpacity(0.3),
                          Colors.purple.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          'RSI: ${spot.y.toStringAsFixed(2)}',
                          const TextStyle(color: Colors.white, fontSize: 12),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRSIColor(double value) {
    if (value >= overboughtLevel) {
      return Colors.red;
    } else if (value <= oversoldLevel) {
      return Colors.green;
    }
    return Colors.purple;
  }
}
