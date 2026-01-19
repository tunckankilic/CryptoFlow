import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:design_system/design_system.dart' hide OrderBookEntry;
import '../../domain/entities/order_book.dart';

/// Depth chart visualization for order book
class DepthChart extends StatelessWidget {
  final OrderBook orderBook;
  final double height;

  const DepthChart({
    super.key,
    required this.orderBook,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    final bidSpots = _buildCumulativeSpots(orderBook.bids, true);
    final askSpots = _buildCumulativeSpots(orderBook.asks, false);

    if (bidSpots.isEmpty || askSpots.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(child: Text('No depth data')),
      );
    }

    final maxY = _getMaxY(bidSpots, askSpots);
    final midPrice = orderBook.midPrice;

    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawHorizontalLine: true,
              drawVerticalLine: true,
              horizontalInterval: maxY / 4,
              getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.grey.withOpacity(0.2),
                strokeWidth: 1,
              ),
              getDrawingVerticalLine: (value) => FlLine(
                color: Colors.grey.withOpacity(0.2),
                strokeWidth: 1,
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      _formatPrice(value),
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 50,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      _formatVolume(value),
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              // Bids (left side, green)
              LineChartBarData(
                spots: bidSpots,
                isCurved: false,
                color: CryptoColors.priceUp,
                barWidth: 2,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: CryptoColors.priceUp.withOpacity(0.3),
                ),
              ),
              // Asks (right side, red)
              LineChartBarData(
                spots: askSpots,
                isCurved: false,
                color: CryptoColors.priceDown,
                barWidth: 2,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: CryptoColors.priceDown.withOpacity(0.3),
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              enabled: true,
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (spots) {
                  return spots.map((spot) {
                    final isBid = spot.bar.color == CryptoColors.priceUp;
                    return LineTooltipItem(
                      'Price: ${_formatPrice(spot.x)}\nVolume: ${_formatVolume(spot.y)}',
                      TextStyle(
                        color: isBid
                            ? CryptoColors.priceUp
                            : CryptoColors.priceDown,
                        fontSize: 12,
                      ),
                    );
                  }).toList();
                },
              ),
            ),
            extraLinesData: ExtraLinesData(
              verticalLines: [
                VerticalLine(
                  x: midPrice,
                  color: Colors.grey,
                  strokeWidth: 1,
                  dashArray: [5, 5],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<FlSpot> _buildCumulativeSpots(List<OrderBookEntry> entries, bool isBid) {
    if (entries.isEmpty) return [];

    final spots = <FlSpot>[];
    double cumulative = 0;

    final orderedEntries = isBid ? entries.reversed.toList() : entries;

    for (final entry in orderedEntries) {
      cumulative += entry.quantity;
      spots.add(FlSpot(entry.price, cumulative));
    }

    return spots;
  }

  double _getMaxY(List<FlSpot> bidSpots, List<FlSpot> askSpots) {
    double maxBid = bidSpots.isEmpty
        ? 0
        : bidSpots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    double maxAsk = askSpots.isEmpty
        ? 0
        : askSpots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    return (maxBid > maxAsk ? maxBid : maxAsk) * 1.1;
  }

  String _formatPrice(double value) {
    if (value >= 1000) return value.toStringAsFixed(0);
    if (value >= 1) return value.toStringAsFixed(2);
    return value.toStringAsFixed(4);
  }

  String _formatVolume(double value) {
    if (value >= 1e6) return '${(value / 1e6).toStringAsFixed(1)}M';
    if (value >= 1e3) return '${(value / 1e3).toStringAsFixed(1)}K';
    return value.toStringAsFixed(1);
  }
}
