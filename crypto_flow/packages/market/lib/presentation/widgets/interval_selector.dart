import 'package:flutter/material.dart';

/// Widget for selecting chart time intervals
class IntervalSelector extends StatelessWidget {
  final String currentInterval;
  final ValueChanged<String> onIntervalChanged;

  static const List<String> intervals = [
    '1m',
    '5m',
    '15m',
    '30m',
    '1h',
    '4h',
    '1d',
    '1w',
  ];

  static const Map<String, String> intervalLabels = {
    '1m': '1m',
    '5m': '5m',
    '15m': '15m',
    '30m': '30m',
    '1h': '1H',
    '4h': '4H',
    '1d': '1D',
    '1w': '1W',
  };

  const IntervalSelector({
    super.key,
    required this.currentInterval,
    required this.onIntervalChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: intervals.length,
        itemBuilder: (context, index) {
          final interval = intervals[index];
          final isSelected = interval == currentInterval;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _IntervalChip(
              label: intervalLabels[interval] ?? interval,
              isSelected: isSelected,
              onTap: () => onIntervalChanged(interval),
            ),
          );
        },
      ),
    );
  }
}

class _IntervalChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _IntervalChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
