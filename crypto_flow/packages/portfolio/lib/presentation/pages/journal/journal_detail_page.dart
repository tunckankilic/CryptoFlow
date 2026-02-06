import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:intl/intl.dart';
import 'package:portfolio/domain/entities/trade_side.dart';
import 'dart:io';
import '../../../domain/entities/journal_entry.dart';
import '../../../domain/entities/trade_emotion.dart';

/// Detail view for a single journal entry
class JournalDetailPage extends StatelessWidget {
  final JournalEntry entry;

  const JournalDetailPage({
    super.key,
    required this.entry,
  });

  static const String _title = 'Trade Details';
  static const String _editButton = 'Edit';
  static const String _deleteButton = 'Delete';
  static const String _tradeLabel = 'Trade Summary';
  static const String _strategyLabel = 'Strategy';
  static const String _emotionLabel = 'Emotional State';
  static const String _notesLabel = 'Notes';
  static const String _screenshotLabel = 'Chart Screenshot';
  static const String _tagsLabel = 'Tags';
  static const String _noNotes = 'No notes added';
  static const String _noStrategy = 'No strategy specified';
  static const String _noTags = 'No tags';
  static const String _durationLabel = 'Duration';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text(_title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: _editButton,
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/portfolio/journal/${entry.id}/edit',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: _deleteButton,
            onPressed: () {
              // TODO: Show delete confirmation
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: ListView(
        padding: AppSpacing.paddingMD,
        children: [
          // Trade Summary Card
          _SectionCard(
            title: _tradeLabel,
            child: Column(
              children: [
                _InfoRow(
                  label: 'Symbol',
                  value: entry.symbol,
                  valueStyle: AppTypography.h5,
                ),
                const Divider(height: 24),
                _InfoRow(
                  label: 'Side',
                  value: entry.side.name.toUpperCase(),
                  valueColor: entry.side == TradeSide.long
                      ? CryptoColors.priceUp
                      : CryptoColors.priceDown,
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _InfoRow(
                        label: 'Entry Price',
                        value: '\$${entry.entryPrice.toStringAsFixed(2)}',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _InfoRow(
                        label: 'Exit Price',
                        value: entry.exitPrice != null
                            ? '\$${entry.exitPrice!.toStringAsFixed(2)}'
                            : 'Open',
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                if (entry.pnl != null) ...[
                  _InfoRow(
                    label: 'P&L',
                    value:
                        '${entry.pnl! >= 0 ? '+' : ''}\$${entry.pnl!.toStringAsFixed(2)}',
                    valueColor: CryptoColors.getPriceColor(entry.pnl!),
                    valueStyle: AppTypography.h4.copyWith(
                      color: CryptoColors.getPriceColor(entry.pnl!),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (entry.pnlPercentage != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${entry.pnlPercentage! >= 0 ? '+' : ''}${entry.pnlPercentage!.toStringAsFixed(2)}%',
                      style: AppTypography.body1.copyWith(
                        color: CryptoColors.getPriceColor(entry.pnlPercentage!),
                      ),
                    ),
                  ],
                  const Divider(height: 24),
                ],
                if (entry.riskRewardRatio != null)
                  _InfoRow(
                    label: 'Risk/Reward',
                    value: '${entry.riskRewardRatio!.toStringAsFixed(2)}',
                    valueColor: CryptoColors.primary,
                  ),
                if (entry.duration != null) ...[
                  const Divider(height: 24),
                  _InfoRow(
                    label: _durationLabel,
                    value: _formatDuration(entry.duration!),
                  ),
                ],
                const Divider(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _InfoRow(
                        label: 'Entry Date',
                        value: DateFormat('MMM d, y HH:mm')
                            .format(entry.entryDate),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _InfoRow(
                        label: 'Exit Date',
                        value: entry.exitDate != null
                            ? DateFormat('MMM d, y HH:mm')
                                .format(entry.exitDate!)
                            : 'Open',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Strategy Section
          _SectionCard(
            title: _strategyLabel,
            child: Text(
              entry.strategy ?? _noStrategy,
              style: AppTypography.body1.copyWith(
                color: entry.strategy != null
                    ? CryptoColors.textPrimary
                    : CryptoColors.textTertiary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Emotion Section
          _SectionCard(
            title: _emotionLabel,
            child: Row(
              children: [
                Text(
                  _emotionEmojis[entry.emotion] ?? '',
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  entry.emotion.displayName,
                  style: AppTypography.h5,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Notes Section
          if (entry.notes != null && entry.notes!.isNotEmpty)
            _SectionCard(
              title: _notesLabel,
              child: Text(
                entry.notes!,
                style: AppTypography.body1,
              ),
            ),
          if (entry.notes != null && entry.notes!.isNotEmpty)
            const SizedBox(height: AppSpacing.md),

          // Screenshot
          if (entry.screenshotPath != null)
            _SectionCard(
              title: _screenshotLabel,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                child: Image.file(
                  File(entry.screenshotPath!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          if (entry.screenshotPath != null)
            const SizedBox(height: AppSpacing.md),

          // Tags
          _SectionCard(
            title: _tagsLabel,
            child: entry.tags.isNotEmpty
                ? Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: entry.tags
                        .map((tag) => Chip(
                              label: Text(tag),
                              backgroundColor:
                                  CryptoColors.primary.withOpacity(0.1),
                              side:
                                  const BorderSide(color: CryptoColors.primary),
                            ))
                        .toList(),
                  )
                : Text(
                    _noTags,
                    style: AppTypography.body1.copyWith(
                      color: CryptoColors.textTertiary,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppSpacing.paddingMD,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTypography.h6.copyWith(
                color: CryptoColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            child,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final TextStyle? valueStyle;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.valueStyle,
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
          value,
          style: valueStyle ??
              AppTypography.body1.copyWith(
                color: valueColor ?? CryptoColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}
