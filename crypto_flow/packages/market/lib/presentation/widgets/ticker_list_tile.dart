import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../../domain/entities/ticker.dart';

/// Optimized list tile for ticker display with real-time updates
class TickerListTile extends StatelessWidget {
  final Ticker ticker;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const TickerListTile({
    super.key,
    required this.ticker,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPositive = ticker.priceChangePercent >= 0;

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Asset icon placeholder
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  ticker.baseAsset.substring(
                      0,
                      ticker.baseAsset.length > 2
                          ? 2
                          : ticker.baseAsset.length),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Symbol and name
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ticker.baseAsset,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    ticker.quoteAsset,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),

            // Price
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  PriceText(
                    price: ticker.price,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  PercentChange(
                    percent: ticker.priceChangePercent,
                    showIcon: true,
                  ),
                ],
              ),
            ),

            // Volume indicator
            const SizedBox(width: 8),
            SizedBox(
              width: 60,
              child: _VolumeIndicator(
                volume: ticker.quoteVolume,
                isPositive: isPositive,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VolumeIndicator extends StatelessWidget {
  final double volume;
  final bool isPositive;

  const _VolumeIndicator({
    required this.volume,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          _formatVolume(volume),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.color
                    ?.withOpacity(0.7),
              ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 4,
          width: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: (isPositive ? CryptoColors.priceUp : CryptoColors.priceDown)
                .withOpacity(0.3),
          ),
        ),
      ],
    );
  }

  String _formatVolume(double volume) {
    if (volume >= 1e9) return '${(volume / 1e9).toStringAsFixed(1)}B';
    if (volume >= 1e6) return '${(volume / 1e6).toStringAsFixed(1)}M';
    if (volume >= 1e3) return '${(volume / 1e3).toStringAsFixed(1)}K';
    return volume.toStringAsFixed(0);
  }
}
