import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../atoms/app_colors.dart';
import '../atoms/app_typography.dart';
import '../atoms/app_spacing.dart';
import '../molecules/price_text.dart';
import '../molecules/percent_change.dart';
import '../molecules/sparkline.dart';

/// Cryptocurrency list tile showing key information
class CoinTile extends StatelessWidget {
  final String symbol;
  final String name;
  final String? iconUrl;
  final double price;
  final double? previousPrice;
  final double percentChange24h;
  final List<double>? sparklineData;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const CoinTile({
    super.key,
    required this.symbol,
    required this.name,
    this.iconUrl,
    required this.price,
    this.previousPrice,
    required this.percentChange24h,
    this.sparklineData,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          height: AppSpacing.coinTileHeight,
          padding: AppSpacing.paddingMD,
          child: Row(
            children: [
              // Coin icon
              _buildIcon(),
              SizedBox(width: AppSpacing.sm),

              // Symbol and name
              Expanded(
                flex: 2,
                child: _buildSymbolAndName(),
              ),

              SizedBox(width: AppSpacing.sm),

              // Sparkline (optional)
              if (sparklineData != null && sparklineData!.isNotEmpty)
                _buildSparkline(),

              if (sparklineData != null && sparklineData!.isNotEmpty)
                SizedBox(width: AppSpacing.sm),

              // Price and percent change
              _buildPriceInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: AppSpacing.coinIconSize,
      height: AppSpacing.coinIconSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: CryptoColors.surfaceBg,
      ),
      child: iconUrl != null
          ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: iconUrl!,
                width: AppSpacing.coinIconSize,
                height: AppSpacing.coinIconSize,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildPlaceholderIcon(),
                errorWidget: (context, url, error) => _buildPlaceholderIcon(),
              ),
            )
          : _buildPlaceholderIcon(),
    );
  }

  Widget _buildPlaceholderIcon() {
    return Center(
      child: Text(
        symbol.substring(0, 1).toUpperCase(),
        style: AppTypography.h5.copyWith(
          color: CryptoColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildSymbolAndName() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          symbol.toUpperCase(),
          style: AppTypography.symbol.copyWith(
            color: CryptoColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 2),
        Text(
          name,
          style: AppTypography.caption.copyWith(
            color: CryptoColors.textSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildSparkline() {
    return Expanded(
      flex: 1,
      child: Sparkline(
        data: sparklineData!,
        height: 32,
        showGradient: true,
      ),
    );
  }

  Widget _buildPriceInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        PriceText(
          price: price,
          previousPrice: previousPrice,
          style: AppTypography.priceSmall,
          animate: true,
        ),
        SizedBox(height: 2),
        PercentChange(
          percent: percentChange24h,
          showIcon: true,
          size: PercentChangeSize.small,
        ),
      ],
    );
  }
}
