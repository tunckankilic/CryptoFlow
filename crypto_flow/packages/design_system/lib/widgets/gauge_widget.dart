import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Gauge widget for displaying 0-100 values with color gradient
///
/// Used for Fear & Greed Index visualization
class GaugeWidget extends StatefulWidget {
  final int value;
  final String label;
  final double size;

  const GaugeWidget({
    super.key,
    required this.value,
    required this.label,
    this.size = 200,
  });

  @override
  State<GaugeWidget> createState() => _GaugeWidgetState();
}

class _GaugeWidgetState extends State<GaugeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: widget.value.toDouble())
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void didUpdateWidget(GaugeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.value.toDouble(),
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size * 0.6,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: _GaugePainter(
              value: _animation.value,
              maxValue: 100,
            ),
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(top: widget.size * 0.15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _animation.value.toInt().toString(),
                      style: TextStyle(
                        fontSize: widget.size * 0.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: widget.size * 0.08,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double value;
  final double maxValue;

  _GaugePainter({
    required this.value,
    required this.maxValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.9);
    final radius = size.width * 0.4;
    final strokeWidth = size.width * 0.08;

    // Draw background arc
    final bgPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      bgPaint,
    );

    // Draw gradient arc
    final sweepAngle = (value / maxValue) * math.pi;
    final gradientPaint = Paint()
      ..shader = SweepGradient(
        startAngle: math.pi,
        endAngle: 2 * math.pi,
        colors: const [
          Color(0xFFD32F2F), // Red - Extreme Fear
          Color(0xFFFF9800), // Orange - Fear
          Color(0xFFFDD835), // Yellow - Neutral
          Color(0xFF4CAF50), // Green - Greed/Extreme Greed
        ],
        stops: const [0.0, 0.25, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      sweepAngle,
      false,
      gradientPaint,
    );

    // Draw needle
    final needleAngle = math.pi + sweepAngle;
    final needleLength = radius * 0.8;
    final needleEnd = Offset(
      center.dx + needleLength * math.cos(needleAngle),
      center.dy + needleLength * math.sin(needleAngle),
    );

    final needlePaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // Needle line
    canvas.drawLine(center, needleEnd, needlePaint);

    // Center dot
    canvas.drawCircle(center, strokeWidth * 0.3, needlePaint);
  }

  @override
  bool shouldRepaint(_GaugePainter oldDelegate) {
    return oldDelegate.value != value;
  }
}
