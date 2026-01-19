import 'package:flutter/material.dart';
import '../atoms/app_colors.dart';
import '../atoms/app_typography.dart';
import 'package:core/core.dart';

/// Animated price text widget that changes color based on price movement
class PriceText extends StatefulWidget {
  final double price;
  final double? previousPrice;
  final TextStyle? style;
  final bool animate;
  final String? currencySymbol;
  final int decimals;

  const PriceText({
    super.key,
    required this.price,
    this.previousPrice,
    this.style,
    this.animate = true,
    this.currencySymbol = '\$',
    this.decimals = 2,
  });

  @override
  State<PriceText> createState() => _PriceTextState();
}

class _PriceTextState extends State<PriceText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  final Color _currentColor = CryptoColors.textPrimary;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(PriceText oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.animate && oldWidget.price != widget.price) {
      _triggerFlashAnimation();
    }
  }

  void _triggerFlashAnimation() {
    final change = widget.price - (widget.previousPrice ?? widget.price);
    final flashColor = CryptoColors.getPriceColor(change);

    _colorAnimation = ColorTween(
      begin: flashColor.withValues(alpha: 0.3),
      end: _currentColor,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward(from: 0.0);
  }

  Color _getPriceColor() {
    if (widget.previousPrice == null) return _currentColor;

    final change = widget.price - widget.previousPrice!;
    if (change > 0) return CryptoColors.priceUp;
    if (change < 0) return CryptoColors.priceDown;
    return CryptoColors.priceNeutral;
  }

  @override
  Widget build(BuildContext context) {
    final displayColor = _getPriceColor();
    final formattedPrice = CryptoFormatters.formatPrice(
      widget.price,
      decimals: widget.decimals,
      symbol: widget.currencySymbol ?? '',
    );

    if (!widget.animate) {
      return Text(
        formattedPrice,
        style: (widget.style ?? AppTypography.priceMedium).copyWith(
          color: displayColor,
        ),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: _controller.isAnimating
                ? _colorAnimation.value
                : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          padding: _controller.isAnimating
              ? const EdgeInsets.symmetric(horizontal: 4, vertical: 2)
              : EdgeInsets.zero,
          child: Text(
            formattedPrice,
            style: (widget.style ?? AppTypography.priceMedium).copyWith(
              color: displayColor,
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
