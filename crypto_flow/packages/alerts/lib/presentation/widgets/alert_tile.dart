import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/price_alert.dart';
import '../bloc/alert_bloc.dart';
import '../bloc/alert_event.dart';
import 'package:design_system/design_system.dart';
import 'package:core/utils/formatters.dart';

/// Widget displaying a single alert
class AlertTile extends StatelessWidget {
  final PriceAlert alert;

  const AlertTile({
    super.key,
    required this.alert,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: AppSpacing.paddingMD,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Symbol and toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert.symbol,
                        style: AppTypography.h4,
                      ),
                      const SizedBox(height: 4),
                      _buildAlertTypeChip(),
                    ],
                  ),
                ),
                Switch(
                  value: alert.isActive,
                  onChanged: alert.isTriggered
                      ? null
                      : (value) {
                          context.read<AlertBloc>().add(
                                ToggleAlertEvent(alert.id, value),
                              );
                        },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Target info
            Row(
              children: [
                const Icon(Icons.trending_up, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Target: ${CryptoFormatters.formatPrice(alert.targetPrice)}',
                  style: AppTypography.h5,
                ),
              ],
            ),

            // Percent change for percent alerts
            if (alert.percentChange != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.percent, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    '${alert.percentChange!.toStringAsFixed(1)}% change',
                    style: AppTypography.caption,
                  ),
                ],
              ),
            ],

            // Status
            const SizedBox(height: 12),
            Row(
              children: [
                if (alert.isTriggered) ...[
                  const Icon(Icons.check_circle, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Triggered ${_formatTime(alert.triggeredAt!)}',
                    style: AppTypography.caption.copyWith(
                      color: Colors.green,
                    ),
                  ),
                ] else if (alert.isActive) ...[
                  const Icon(Icons.notifications_active,
                      color: Colors.blue, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Active',
                    style: AppTypography.caption.copyWith(
                      color: Colors.blue,
                    ),
                  ),
                ] else ...[
                  const Icon(Icons.notifications_off,
                      color: Colors.grey, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Inactive',
                    style: AppTypography.caption.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
                if (alert.repeatEnabled) ...[
                  const SizedBox(width: 16),
                  const Icon(Icons.repeat, color: Colors.grey, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Repeat',
                    style: AppTypography.caption.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ],
            ),

            // Note
            if (alert.note != null && alert.note!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                alert.note!,
                style: AppTypography.caption.copyWith(
                  color: CryptoColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAlertTypeChip() {
    Color color;
    IconData icon;
    String label;

    switch (alert.type) {
      case AlertType.above:
        color = CryptoColors.priceUp;
        icon = Icons.arrow_upward;
        label = 'Above';
        break;
      case AlertType.below:
        color = CryptoColors.priceDown;
        icon = Icons.arrow_downward;
        label = 'Below';
        break;
      case AlertType.percentUp:
        color = CryptoColors.priceUp;
        icon = Icons.trending_up;
        label = 'Percent Up';
        break;
      case AlertType.percentDown:
        color = CryptoColors.priceDown;
        icon = Icons.trending_down;
        label = 'Percent Down';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.caption.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return 'just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}
