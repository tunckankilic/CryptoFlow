import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../../domain/entities/chart_pattern.dart';

/// Overlay widget showing detected chart patterns on a candle chart.
/// Place this as a Stack child on top of the existing CandleChart widget.
class PatternOverlay extends StatelessWidget {
  final List<ChartPattern> patterns;
  final double chartWidth;
  final double chartHeight;
  final int totalCandles;

  const PatternOverlay({
    super.key,
    required this.patterns,
    required this.chartWidth,
    required this.chartHeight,
    required this.totalCandles,
  });

  Color _patternColor(SignalDirection direction) {
    switch (direction) {
      case SignalDirection.bullish:
        return CryptoColors.priceUp;
      case SignalDirection.bearish:
        return CryptoColors.priceDown;
      case SignalDirection.neutral:
        return CryptoColors.warning;
    }
  }

  IconData _patternIcon(PatternType type) {
    switch (type) {
      case PatternType.doubleTop:
      case PatternType.headAndShoulders:
      case PatternType.resistance:
        return Icons.arrow_downward;
      case PatternType.doubleBottom:
      case PatternType.inverseHeadAndShoulders:
      case PatternType.support:
        return Icons.arrow_upward;
      case PatternType.ascendingTriangle:
      case PatternType.descendingTriangle:
      case PatternType.symmetricalTriangle:
        return Icons.change_history;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (patterns.isEmpty || totalCandles == 0) return const SizedBox();

    final candleWidth = chartWidth / totalCandles;

    return Stack(
      children: patterns.map((p) {
        final left = p.startIndex * candleWidth;
        final width = (p.endIndex - p.startIndex + 1) * candleWidth;
        final color = _patternColor(p.direction);

        return Positioned(
          left: left.clamp(0, chartWidth - 20),
          top: 0,
          child: GestureDetector(
            onTap: () => _showPatternInfo(context, p),
            child: Container(
              width: width.clamp(20, chartWidth),
              height: chartHeight,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                border:
                    Border.all(color: color.withValues(alpha: 0.3), width: 1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_patternIcon(p.patternType),
                          size: 10, color: Colors.white),
                      const SizedBox(width: 2),
                      Text(
                        '${(p.confidence * 100).toInt()}%',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 9),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showPatternInfo(BuildContext context, ChartPattern pattern) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: AppSpacing.paddingMD,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _patternIcon(pattern.patternType),
                  color: _patternColor(pattern.direction),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    pattern.patternType.name,
                    style: AppTypography.h5,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _patternColor(pattern.direction)
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    pattern.direction.name.toUpperCase(),
                    style: AppTypography.caption.copyWith(
                      color: _patternColor(pattern.direction),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(pattern.description, style: AppTypography.body1),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Confidence: ${(pattern.confidence * 100).toStringAsFixed(0)}%',
              style: AppTypography.caption,
            ),
            if (pattern.keyLevels.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Key Levels: ${pattern.keyLevels.map((l) => l.toStringAsFixed(2)).join(", ")}',
                style: AppTypography.caption,
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}
