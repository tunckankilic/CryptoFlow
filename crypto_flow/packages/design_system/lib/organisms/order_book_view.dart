import 'package:flutter/material.dart';
import '../atoms/app_colors.dart';
import '../atoms/app_typography.dart';
import '../atoms/app_spacing.dart';

/// Order book entry data model
class OrderBookEntry {
  final double price;
  final double amount;
  final double total;

  const OrderBookEntry({
    required this.price,
    required this.amount,
    required this.total,
  });
}

/// Order book visualization showing bids and asks
class OrderBookView extends StatelessWidget {
  final List<OrderBookEntry> bids;
  final List<OrderBookEntry> asks;
  final int depth;
  final bool showDepthChart;

  const OrderBookView({
    super.key,
    required this.bids,
    required this.asks,
    this.depth = 20,
    this.showDepthChart = false,
  });

  @override
  Widget build(BuildContext context) {
    final displayBids = bids.take(depth).toList();
    final displayAsks = asks.take(depth).toList();

    return Column(
      children: [
        // Header
        _buildHeader(),

        SizedBox(height: AppSpacing.sm),

        // Order book content
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bids (left side)
            Expanded(
              child: _buildOrderList(
                entries: displayBids,
                isBid: true,
              ),
            ),

            Container(
              width: 1,
              height: (depth * AppSpacing.orderBookRowHeight).toDouble(),
              color: CryptoColors.divider,
            ),

            // Asks (right side)
            Expanded(
              child: _buildOrderList(
                entries: displayAsks,
                isBid: false,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: AppSpacing.paddingSM,
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Bids (Buy)',
              style: AppTypography.caption.copyWith(
                color: CryptoColors.bidGreenText,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              'Asks (Sell)',
              style: AppTypography.caption.copyWith(
                color: CryptoColors.askRedText,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList({
    required List<OrderBookEntry> entries,
    required bool isBid,
  }) {
    if (entries.isEmpty) {
      return Center(
        child: Padding(
          padding: AppSpacing.paddingLG,
          child: Text(
            'No data',
            style: AppTypography.caption.copyWith(
              color: CryptoColors.textTertiary,
            ),
          ),
        ),
      );
    }

    // Calculate max total for depth visualization
    final maxTotal =
        entries.map((e) => e.total).reduce((a, b) => a > b ? a : b);

    return Column(
      children: entries.map((entry) {
        return _buildOrderRow(
          entry: entry,
          isBid: isBid,
          maxTotal: maxTotal,
        );
      }).toList(),
    );
  }

  Widget _buildOrderRow({
    required OrderBookEntry entry,
    required bool isBid,
    required double maxTotal,
  }) {
    final depthPercentage = (entry.total / maxTotal).clamp(0.0, 1.0);
    final backgroundColor = isBid ? CryptoColors.bidGreen : CryptoColors.askRed;
    final textColor =
        isBid ? CryptoColors.bidGreenText : CryptoColors.askRedText;

    return SizedBox(
      height: AppSpacing.orderBookRowHeight,
      child: Stack(
        children: [
          // Depth visualization bar
          Positioned(
            right: isBid ? 0 : null,
            left: isBid ? null : 0,
            top: 0,
            bottom: 0,
            width: depthPercentage * 200, // Adjust width as needed
            child: Container(
              color: backgroundColor.withValues(alpha: 0.3),
            ),
          ),

          // Order data
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  entry.price.toStringAsFixed(2),
                  style: AppTypography.chartLabel.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  entry.amount.toStringAsFixed(4),
                  style: AppTypography.chartLabel.copyWith(
                    color: CryptoColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
