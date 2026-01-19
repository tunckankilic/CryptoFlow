import 'package:flutter/material.dart';
import '../atoms/app_colors.dart';
import '../atoms/app_typography.dart';
import '../atoms/app_spacing.dart';
import 'package:core/core.dart';

/// Percent change badge with color coding and optional arrow icon
class PercentChange extends StatelessWidget {
  final double percent;
  final bool showIcon;
  final PercentChangeSize size;
  final TextStyle? style;

  const PercentChange({
    super.key,
    required this.percent,
    this.showIcon = true,
    this.size = PercentChangeSize.medium,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final color = CryptoColors.getPriceColor(percent);
    final formattedPercent = CryptoFormatters.formatPercent(percent);
    final textStyle = _getTextStyle();
    final icon = _getIcon();

    return Container(
      padding: _getPadding(),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(_getRadius()),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon && icon != null) ...[
            Icon(
              icon,
              size: _getIconSize(),
              color: color,
            ),
            SizedBox(width: AppSpacing.xs / 2),
          ],
          Text(
            formattedPercent,
            style: (style ?? textStyle).copyWith(color: color),
          ),
        ],
      ),
    );
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case PercentChangeSize.small:
        return AppTypography.percentChangeSmall;
      case PercentChangeSize.medium:
        return AppTypography.percentChange;
      case PercentChangeSize.large:
        return AppTypography.h6;
    }
  }

  IconData? _getIcon() {
    if (!showIcon) return null;
    if (percent > 0) return Icons.arrow_drop_up;
    if (percent < 0) return Icons.arrow_drop_down;
    return null;
  }

  double _getIconSize() {
    switch (size) {
      case PercentChangeSize.small:
        return 16.0;
      case PercentChangeSize.medium:
        return 20.0;
      case PercentChangeSize.large:
        return 24.0;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case PercentChangeSize.small:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xs / 2,
        );
      case PercentChangeSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        );
      case PercentChangeSize.large:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        );
    }
  }

  double _getRadius() {
    switch (size) {
      case PercentChangeSize.small:
        return AppSpacing.radiusSmall;
      case PercentChangeSize.medium:
        return AppSpacing.radiusMedium;
      case PercentChangeSize.large:
        return AppSpacing.radiusMedium;
    }
  }
}

/// Size variants for percent change display
enum PercentChangeSize {
  small,
  medium,
  large,
}
