import 'package:flutter/material.dart';
import '../atoms/app_colors.dart';
import '../atoms/app_typography.dart';
import '../atoms/app_spacing.dart';
import '../molecules/price_text.dart';
import '../molecules/percent_change.dart';
import 'package:core/core.dart';

/// Detailed price information card
class PriceCard extends StatelessWidget {
  final double price;
  final double? previousPrice;
  final double percentChange24h;
  final double? high24h;
  final double? low24h;
  final double? volume24h;
  final double? marketCap;
  final String? symbol;

  const PriceCard({
    super.key,
    required this.price,
    this.previousPrice,
    required this.percentChange24h,
    this.high24h,
    this.low24h,
    this.volume24h,
    this.marketCap,
    this.symbol,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: CryptoColors.cardBg,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      ),
      child: Padding(
        padding: AppSpacing.paddingLG,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Symbol (if provided)
            if (symbol != null) ...[
              Text(
                symbol!.toUpperCase(),
                style: AppTypography.h5.copyWith(
                  color: CryptoColors.textSecondary,
                ),
              ),
              SizedBox(height: AppSpacing.sm),
            ],

            // Main price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                PriceText(
                  price: price,
                  previousPrice: previousPrice,
                  style: AppTypography.priceLarge,
                  animate: true,
                ),
                PercentChange(
                  percent: percentChange24h,
                  showIcon: true,
                  size: PercentChangeSize.large,
                ),
              ],
            ),

            SizedBox(height: AppSpacing.lg),

            // 24h Stats
            _buildStatsGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    final stats = <String, String?>{
      '24h High':
          high24h != null ? CryptoFormatters.formatPrice(high24h!) : null,
      '24h Low': low24h != null ? CryptoFormatters.formatPrice(low24h!) : null,
      'Volume (24h)':
          volume24h != null ? CryptoFormatters.formatVolume(volume24h!) : null,
      'Market Cap': marketCap != null
          ? CryptoFormatters.formatMarketCap(marketCap!)
          : null,
    };

    final availableStats = stats.entries.where((e) => e.value != null).toList();

    if (availableStats.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        for (int i = 0; i < availableStats.length; i += 2)
          Padding(
            padding: EdgeInsets.only(
              bottom: i < availableStats.length - 2 ? AppSpacing.md : 0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    availableStats[i].key,
                    availableStats[i].value!,
                  ),
                ),
                if (i + 1 < availableStats.length) ...[
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _buildStatItem(
                      availableStats[i + 1].key,
                      availableStats[i + 1].value!,
                    ),
                  ),
                ] else
                  const Spacer(),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: CryptoColors.textTertiary,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.body2.copyWith(
            color: CryptoColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
