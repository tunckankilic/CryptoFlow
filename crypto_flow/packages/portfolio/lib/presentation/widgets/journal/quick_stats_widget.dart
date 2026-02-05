import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../../../domain/entities/trading_stats.dart';

/// Quick statistics display for journal overview
class QuickStatsWidget extends StatelessWidget {
  final TradingStats stats;

  const QuickStatsWidget({
    super.key,
    required this.stats,
  });

  static const String _winRateLabel = 'Win Rate';
  static const String _totalPnlLabel = 'Total P&L';
  static const String _totalTradesLabel = 'Trades';

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: _winRateLabel,
            value: '${stats.winRate.toStringAsFixed(1)}%',
            color:
                stats.winRate >= 50 ? CryptoColors.success : CryptoColors.error,
            icon: Icons.trending_up,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatCard(
            label: _totalPnlLabel,
            value: _formatPnl(stats.totalPnl),
            color: CryptoColors.getPriceColor(stats.totalPnl),
            icon: Icons.account_balance_wallet,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatCard(
            label: _totalTradesLabel,
            value: stats.totalTrades.toString(),
            color: CryptoColors.primary,
            icon: Icons.bar_chart,
          ),
        ),
      ],
    );
  }

  String _formatPnl(double value) {
    if (value >= 0) {
      return '+\$${value.toStringAsFixed(2)}';
    }
    return '-\$${value.abs().toStringAsFixed(2)}';
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: AppSpacing.paddingSM,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(color: CryptoColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.h5.copyWith(color: color),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: CryptoColors.textTertiary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
