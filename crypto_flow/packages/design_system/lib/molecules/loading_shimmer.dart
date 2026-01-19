import 'package:flutter/material.dart';
import '../atoms/app_colors.dart';

/// Shimmer loading animation for skeleton screens
class LoadingShimmer extends StatefulWidget {
  final double width;
  final double height;
  final ShimmerShape shape;
  final Color? baseColor;
  final Color? highlightColor;

  const LoadingShimmer({
    super.key,
    required this.width,
    required this.height,
    this.shape = ShimmerShape.rectangle,
    this.baseColor,
    this.highlightColor,
  });

  /// Create a circular shimmer
  const LoadingShimmer.circular({
    super.key,
    required double size,
    this.baseColor,
    this.highlightColor,
  })  : width = size,
        height = size,
        shape = ShimmerShape.circle;

  /// Create a text-line shimmer
  const LoadingShimmer.text({
    super.key,
    this.width = 100,
    this.height = 16,
    this.baseColor,
    this.highlightColor,
  }) : shape = ShimmerShape.roundedRectangle;

  @override
  State<LoadingShimmer> createState() => _LoadingShimmerState();
}

class _LoadingShimmerState extends State<LoadingShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.baseColor ?? CryptoColors.shimmerBase;
    final highlightColor =
        widget.highlightColor ?? CryptoColors.shimmerHighlight;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: _getDecoration(baseColor, highlightColor),
        );
      },
    );
  }

  BoxDecoration _getDecoration(Color base, Color highlight) {
    final gradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [base, highlight, base],
      stops: [
        _animation.value - 1,
        _animation.value,
        _animation.value + 1,
      ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
    );

    switch (widget.shape) {
      case ShimmerShape.circle:
        return BoxDecoration(
          shape: BoxShape.circle,
          gradient: gradient,
        );
      case ShimmerShape.roundedRectangle:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          gradient: gradient,
        );
      case ShimmerShape.rectangle:
        return BoxDecoration(
          gradient: gradient,
        );
    }
  }
}

/// Shape variants for shimmer loading
enum ShimmerShape {
  rectangle,
  roundedRectangle,
  circle,
}
