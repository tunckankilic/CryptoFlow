import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'dart:math' as math;

/// Gauge-style card showing Sharpe or Sortino ratio
class SharpeRatioCard extends StatelessWidget {
  final String title;
  final double value;
  final double minValue;
  final double maxValue;

  const SharpeRatioCard({
    super.key,
    required this.title,
    required this.value,
    this.minValue = -2,
    this.maxValue = 4,
  });

  Color _gaugeColor() {
    if (value >= 2) return CryptoColors.success;
    if (value >= 1) return CryptoColors.priceUp;
    if (value >= 0) return CryptoColors.warning;
    return CryptoColors.error;
  }

  String _ratingLabel() {
    if (value >= 3) return 'Excellent';
    if (value >= 2) return 'Very Good';
    if (value >= 1) return 'Good';
    if (value >= 0) return 'Neutral';
    return 'Poor';
  }

  @override
  Widget build(BuildContext context) {
    final color = _gaugeColor();
    final progress =
        ((value - minValue) / (maxValue - minValue)).clamp(0.0, 1.0);

    return Card(
      child: Padding(
        padding: AppSpacing.paddingMD,
        child: Column(
          children: [
            Text(title, style: AppTypography.caption),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: 100,
              height: 60,
              child: CustomPaint(
                painter: _GaugePainter(
                  progress: progress,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              value.toStringAsFixed(2),
              style: AppTypography.h4.copyWith(color: color),
            ),
            Text(
              _ratingLabel(),
              style: AppTypography.caption.copyWith(
                color: CryptoColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double progress;
  final Color color;

  _GaugePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height * 2);
    const startAngle = math.pi;
    const sweepAngle = math.pi;

    // Background arc
    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, startAngle, sweepAngle, false, bgPaint);

    // Foreground arc
    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, startAngle, sweepAngle * progress, false, fgPaint);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) =>
      old.progress != progress || old.color != color;
}
