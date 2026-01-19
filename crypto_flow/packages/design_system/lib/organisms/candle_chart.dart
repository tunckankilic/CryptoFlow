import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../atoms/app_colors.dart';
import '../atoms/app_typography.dart';
import '../atoms/app_spacing.dart';

/// Candle data model
class Candle {
  final DateTime timestamp;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  const Candle({
    required this.timestamp,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  bool get isBullish => close >= open;
}

/// Interactive candlestick chart widget
class CandleChart extends StatelessWidget {
  final List<Candle> candles;
  final String interval;
  final bool showVolume;
  final bool showMA;
  final Function(Candle)? onCandleTap;

  const CandleChart({
    super.key,
    required this.candles,
    this.interval = '1h',
    this.showVolume = true,
    this.showMA = false,
    this.onCandleTap,
  });

  @override
  Widget build(BuildContext context) {
    if (candles.isEmpty) {
      return SizedBox(
        height: AppSpacing.candlestickHeight,
        child: Center(
          child: Text(
            'No data available',
            style: AppTypography.body2.copyWith(
              color: CryptoColors.textTertiary,
            ),
          ),
        ),
      );
    }

    return Container(
      height: AppSpacing.candlestickHeight,
      padding: AppSpacing.paddingMD,
      child: Column(
        children: [
          // Chart header
          _buildHeader(),

          SizedBox(height: AppSpacing.sm),

          // Candlestick chart
          Expanded(
            child: _buildCandlestickChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          interval.toUpperCase(),
          style: AppTypography.body2.copyWith(
            color: CryptoColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        Row(
          children: [
            if (showVolume) _buildHeaderButton('Volume', true),
            if (showMA) _buildHeaderButton('MA', true),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderButton(String label, bool active) {
    return Container(
      margin: const EdgeInsets.only(left: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: active
            ? CryptoColors.primary.withValues(alpha: 0.2)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
        border: Border.all(
          color: active ? CryptoColors.primary : CryptoColors.borderDark,
        ),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: active ? CryptoColors.primary : CryptoColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCandlestickChart() {
    // For simplicity, using a placeholder implementation
    // A full implementation would use custom painting or fl_chart's BarChart
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceEvenly,
        maxY: _getMaxPrice(),
        minY: _getMinPrice(),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (_getMaxPrice() - _getMinPrice()) / 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: CryptoColors.divider,
              strokeWidth: 0.5,
            );
          },
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < candles.length) {
                  // Show every nth label to avoid crowding
                  if (value.toInt() % (candles.length ~/ 5 + 1) == 0) {
                    final candle = candles[value.toInt()];
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${candle.timestamp.hour}:${candle.timestamp.minute.toString().padLeft(2, '0')}',
                        style: AppTypography.chartLabel.copyWith(
                          color: CryptoColors.textTertiary,
                        ),
                      ),
                    );
                  }
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(0),
                  style: AppTypography.chartLabel.copyWith(
                    color: CryptoColors.textTertiary,
                  ),
                );
              },
            ),
          ),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barGroups: _getBarGroups(),
      ),
    );
  }

  List<BarChartGroupData> _getBarGroups() {
    return List.generate(candles.length, (index) {
      final candle = candles[index];
      final color =
          candle.isBullish ? CryptoColors.candleGreen : CryptoColors.candleRed;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            fromY: candle.low,
            toY: candle.high,
            width: 2,
            color: color,
            borderRadius: BorderRadius.zero,
          ),
        ],
      );
    });
  }

  double _getMaxPrice() {
    if (candles.isEmpty) return 0;
    return candles.map((c) => c.high).reduce((a, b) => a > b ? a : b) * 1.02;
  }

  double _getMinPrice() {
    if (candles.isEmpty) return 0;
    return candles.map((c) => c.low).reduce((a, b) => a < b ? a : b) * 0.98;
  }
}
