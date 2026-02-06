import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:design_system/design_system.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/journal_entry.dart';
import '../../../domain/entities/trade_side.dart';
import '../../../domain/entities/trade_emotion.dart';

/// Card widget for displaying journal entry in a list
class JournalEntryCard extends StatelessWidget {
  final JournalEntry entry;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const JournalEntryCard({
    super.key,
    required this.entry,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  static const String _editLabel = 'Edit';
  static const String _deleteLabel = 'Delete';

  // Emotion emoji mapping
  static const Map<TradeEmotion, String> _emotionEmojis = {
    TradeEmotion.confident: '😎',
    TradeEmotion.neutral: '😐',
    TradeEmotion.fearful: '😰',
    TradeEmotion.greedy: '🤑',
    TradeEmotion.fomo: '😱',
    TradeEmotion.revenge: '😤',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Slidable(
        key: ValueKey(entry.id),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => onEdit(),
              backgroundColor: CryptoColors.primary,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: _editLabel,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            ),
            SlidableAction(
              onPressed: (_) => onDelete(),
              backgroundColor: CryptoColors.error,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: _deleteLabel,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            ),
          ],
        ),
        child: Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            child: Padding(
              padding: AppSpacing.paddingMD,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Symbol and Side Badge
                  Row(
                    children: [
                      Text(
                        entry.symbol,
                        style: AppTypography.h5,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _SideBadge(side: entry.side),
                      const Spacer(),
                      Text(
                        _emotionEmojis[entry.emotion] ?? '',
                        style: const TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Prices
                  Row(
                    children: [
                      Expanded(
                        child: _PriceInfo(
                          label: 'Entry',
                          price: entry.entryPrice,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: CryptoColors.textTertiary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _PriceInfo(
                          label: 'Exit',
                          price: entry.exitPrice,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // P&L and R:R
                  Row(
                    children: [
                      if (entry.pnl != null) ...[
                        Expanded(
                          child: _PnlDisplay(
                            pnl: entry.pnl!,
                            pnlPercentage: entry.pnlPercentage,
                          ),
                        ),
                      ],
                      if (entry.riskRewardRatio != null) ...[
                        const SizedBox(width: AppSpacing.sm),
                        _RRBadge(ratio: entry.riskRewardRatio!),
                      ],
                    ],
                  ),

                  // Date and Tags
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: CryptoColors.textTertiary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        DateFormat('MMM d, y').format(entry.entryDate),
                        style: AppTypography.caption.copyWith(
                          color: CryptoColors.textTertiary,
                        ),
                      ),
                      const Spacer(),
                      if (entry.tags.isNotEmpty)
                        Row(
                          children: entry.tags.take(2).map((tag) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                left: AppSpacing.xs,
                              ),
                              child: Chip(
                                label: Text(
                                  tag,
                                  style: AppTypography.caption,
                                ),
                                visualDensity: VisualDensity.compact,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.xs,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SideBadge extends StatelessWidget {
  final TradeSide side;

  const _SideBadge({required this.side});

  @override
  Widget build(BuildContext context) {
    final isLong = side == TradeSide.long;
    final color = isLong ? CryptoColors.priceUp : CryptoColors.priceDown;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
        border: Border.all(color: color),
      ),
      child: Text(
        side.displayName.toUpperCase(),
        style: AppTypography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _PriceInfo extends StatelessWidget {
  final String label;
  final double? price;

  const _PriceInfo({
    required this.label,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: CryptoColors.textTertiary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          price != null ? '\$${price!.toStringAsFixed(2)}' : '-',
          style: AppTypography.body2.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _PnlDisplay extends StatelessWidget {
  final double pnl;
  final double? pnlPercentage;

  const _PnlDisplay({
    required this.pnl,
    this.pnlPercentage,
  });

  @override
  Widget build(BuildContext context) {
    final color = CryptoColors.getPriceColor(pnl);
    final pnlText = pnl >= 0
        ? '+\$${pnl.toStringAsFixed(2)}'
        : '-\$${pnl.abs().toStringAsFixed(2)}';
    final percentText = pnlPercentage != null
        ? ' (${pnlPercentage! >= 0 ? '+' : ''}${pnlPercentage!.toStringAsFixed(2)}%)'
        : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'P&L',
          style: AppTypography.caption.copyWith(
            color: CryptoColors.textTertiary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '$pnlText$percentText',
          style: AppTypography.body2.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _RRBadge extends StatelessWidget {
  final double ratio;

  const _RRBadge({required this.ratio});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: CryptoColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
        border: Border.all(color: CryptoColors.primary),
      ),
      child: Text(
        'R:R ${ratio.toStringAsFixed(2)}',
        style: AppTypography.caption.copyWith(
          color: CryptoColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
