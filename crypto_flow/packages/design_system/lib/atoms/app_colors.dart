import 'package:flutter/material.dart';

/// Crypto-themed color palette optimized for price displays and dark themes
class CryptoColors {
  CryptoColors._();

  // Price Direction Colors
  /// Color for price increases (green)
  static const priceUp = Color(0xFF00C853);

  /// Color for price decreases (red)
  static const priceDown = Color(0xFFFF1744);

  /// Color for neutral/unchanged prices (gray)
  static const priceNeutral = Color(0xFF9E9E9E);

  // Chart Colors
  /// Green color for bullish candles (close > open)
  static const candleGreen = Color(0xFF26A69A);

  /// Red color for bearish candles (close < open)
  static const candleRed = Color(0xFFEF5350);

  /// Blue color for chart lines
  static const chartLine = Color(0xFF2196F3);

  /// Semi-transparent blue for chart fill/gradient
  static const chartFill = Color(0x332196F3);

  /// Alternative chart colors for multiple series
  static const chartOrange = Color(0xFFFF9800);
  static const chartPurple = Color(0xFF9C27B0);
  static const chartYellow = Color(0xFFFFC107);

  // Order Book Colors
  /// Semi-transparent green for bid side
  static const bidGreen = Color(0x3300C853);

  /// Semi-transparent red for ask side
  static const askRed = Color(0x33FF1744);

  /// Opaque versions for text
  static const bidGreenText = Color(0xFF00C853);
  static const askRedText = Color(0xFFFF1744);

  // Background Colors (Dark Theme)
  /// Main background color (very dark gray)
  static const darkBg = Color(0xFF121212);

  /// Card/container background (dark gray)
  static const cardBg = Color(0xFF1E1E1E);

  /// Surface/elevated background (medium dark gray)
  static const surfaceBg = Color(0xFF2C2C2C);

  /// Pure black for AMOLED displays
  static const amoledBlack = Color(0xFF000000);

  // Background Colors (Light Theme)
  /// Main background (off-white)
  static const lightBg = Color(0xFFF5F5F5);

  /// Card background (white)
  static const lightCardBg = Color(0xFFFFFFFF);

  /// Surface (very light gray)
  static const lightSurfaceBg = Color(0xFFFAFAFA);

  // UI Colors
  /// Primary brand color (blue)
  static const primary = Color(0xFF2196F3);

  /// Secondary brand color (teal)
  static const secondary = Color(0xFF009688);

  /// Accent color (amber)
  static const accent = Color(0xFFFFC107);

  /// Error color (red)
  static const error = Color(0xFFFF1744);

  /// Success color (green)
  static const success = Color(0xFF00C853);

  /// Warning color (orange)
  static const warning = Color(0xFFFF9800);

  /// Info color (blue)
  static const info = Color(0xFF2196F3);

  // Text Colors (Dark Theme)
  /// Primary text color (white)
  static const textPrimary = Color(0xFFFFFFFF);

  /// Secondary text color (light gray)
  static const textSecondary = Color(0xFFB0B0B0);

  /// Tertiary text color (medium gray)
  static const textTertiary = Color(0xFF707070);

  /// Disabled text color (dark gray)
  static const textDisabled = Color(0xFF505050);

  // Text Colors (Light Theme)
  /// Primary text (dark gray)
  static const lightTextPrimary = Color(0xFF212121);

  /// Secondary text (medium gray)
  static const lightTextSecondary = Color(0xFF757575);

  /// Tertiary text (light gray)
  static const lightTextTertiary = Color(0xFF9E9E9E);

  /// Disabled text (very light gray)
  static const lightTextDisabled = Color(0xFFBDBDBD);

  // Border Colors
  /// Border color for dark theme
  static const borderDark = Color(0xFF404040);

  /// Border color for light theme
  static const borderLight = Color(0xFFE0E0E0);

  /// Divider color
  static const divider = Color(0xFF303030);

  // Special Colors
  /// Shimmer base color for loading states
  static const shimmerBase = Color(0xFF2C2C2C);

  /// Shimmer highlight color
  static const shimmerHighlight = Color(0xFF3C3C3C);

  /// Overlay color for modals/dialogs
  static const overlay = Color(0x99000000);

  // Helper Methods
  /// Get price color based on change value
  static Color getPriceColor(double change) {
    if (change > 0) return priceUp;
    if (change < 0) return priceDown;
    return priceNeutral;
  }

  /// Get candle color based on open/close
  static Color getCandleColor(double open, double close) {
    return close >= open ? candleGreen : candleRed;
  }

  /// Get contrasting text color for a background color
  static Color getContrastingTextColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? lightTextPrimary : textPrimary;
  }
}
