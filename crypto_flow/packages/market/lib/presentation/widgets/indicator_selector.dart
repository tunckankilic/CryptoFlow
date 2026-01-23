import 'package:flutter/material.dart';
import '../../domain/entities/indicator_type.dart';

/// Widget for selecting which technical indicators to display on the chart
class IndicatorSelector extends StatelessWidget {
  /// Currently active indicators
  final Set<IndicatorType> activeIndicators;

  /// Callback when an indicator is toggled
  final ValueChanged<IndicatorType> onIndicatorToggled;

  const IndicatorSelector({
    super.key,
    required this.activeIndicators,
    required this.onIndicatorToggled,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: IndicatorType.values.map((indicator) {
          final isActive = activeIndicators.contains(indicator);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: FilterChip(
              label: Text(
                indicator.shortName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                ),
              ),
              selected: isActive,
              onSelected: (_) => onIndicatorToggled(indicator),
              backgroundColor: theme.colorScheme.surface,
              selectedColor: _getIndicatorColor(indicator, theme),
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _getIndicatorColor(IndicatorType indicator, ThemeData theme) {
    switch (indicator) {
      case IndicatorType.rsi:
        return Colors.purple;
      case IndicatorType.ema9:
        return Colors.orange;
      case IndicatorType.ema21:
        return Colors.blue;
      case IndicatorType.ema50:
        return Colors.teal;
      case IndicatorType.sma20:
        return Colors.green;
      case IndicatorType.macd:
        return Colors.red;
    }
  }
}
