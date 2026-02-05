import 'package:flutter/material.dart';
import '../../../domain/entities/trade_emotion.dart';
import 'package:design_system/design_system.dart';

/// Widget for selecting trading emotion with emoji cards
class EmotionPickerWidget extends StatelessWidget {
  final TradeEmotion selectedEmotion;
  final ValueChanged<TradeEmotion> onEmotionSelected;

  const EmotionPickerWidget({
    super.key,
    required this.selectedEmotion,
    required this.onEmotionSelected,
  });

  static const String _title = 'How did you feel?';

  // Map emotions to emoji
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_title, style: AppTypography.body1),
        const SizedBox(height: AppSpacing.sm),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.sm,
          crossAxisSpacing: AppSpacing.sm,
          childAspectRatio: 1.2,
          children: TradeEmotion.values.map((emotion) {
            final isSelected = emotion == selectedEmotion;
            return _EmotionCard(
              emotion: emotion,
              emoji: _emotionEmojis[emotion]!,
              isSelected: isSelected,
              onTap: () => onEmotionSelected(emotion),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _EmotionCard extends StatelessWidget {
  final TradeEmotion emotion;
  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;

  const _EmotionCard({
    required this.emotion,
    required this.emoji,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? CryptoColors.primary.withOpacity(0.1)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          border: Border.all(
            color: isSelected ? CryptoColors.primary : CryptoColors.borderDark,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              emotion.displayName,
              style: AppTypography.caption.copyWith(
                color: isSelected
                    ? CryptoColors.primary
                    : CryptoColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
