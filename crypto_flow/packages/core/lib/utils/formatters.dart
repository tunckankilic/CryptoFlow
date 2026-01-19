import 'package:intl/intl.dart';

/// Formatters for cryptocurrency data display
class CryptoFormatters {
  CryptoFormatters._();

  /// Format price with appropriate decimal places
  ///
  /// Examples:
  /// - formatPrice(67234.50) => "\$67,234.50"
  /// - formatPrice(0.000123) => "\$0.000123"
  /// - formatPrice(1234567.89, decimals: 0) => "\$1,234,568"
  static String formatPrice(double price,
      {int decimals = 2, String symbol = '\$'}) {
    // Auto-adjust decimals for very small prices
    int adjustedDecimals = decimals;
    if (price < 0.01 && price > 0) {
      // For very small prices, show more decimals
      adjustedDecimals = _calculateOptimalDecimals(price);
    }

    final formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: adjustedDecimals,
    );
    return formatter.format(price);
  }

  /// Format price without currency symbol
  static String formatPriceSimple(double price, {int decimals = 2}) {
    int adjustedDecimals = decimals;
    if (price < 0.01 && price > 0) {
      adjustedDecimals = _calculateOptimalDecimals(price);
    }

    final formatter = NumberFormat.decimalPattern();
    formatter.minimumFractionDigits = adjustedDecimals;
    formatter.maximumFractionDigits = adjustedDecimals;
    return formatter.format(price);
  }

  /// Calculate optimal decimal places for small prices
  static int _calculateOptimalDecimals(double price) {
    if (price >= 0.01) return 2;
    if (price >= 0.001) return 3;
    if (price >= 0.0001) return 4;
    if (price >= 0.00001) return 5;
    if (price >= 0.000001) return 6;
    return 8; // Max decimals for very tiny prices
  }

  /// Format percentage with + or - sign
  ///
  /// Examples:
  /// - formatPercent(5.23) => "+5.23%"
  /// - formatPercent(-2.15) => "-2.15%"
  /// - formatPercent(0) => "0.00%"
  static String formatPercent(double percent, {int decimals = 2}) {
    final formatter = NumberFormat.decimalPattern();
    formatter.minimumFractionDigits = decimals;
    formatter.maximumFractionDigits = decimals;

    final formattedValue = formatter.format(percent.abs());

    if (percent > 0) {
      return '+$formattedValue%';
    } else if (percent < 0) {
      return '-$formattedValue%';
    } else {
      return '$formattedValue%';
    }
  }

  /// Format large numbers with K, M, B suffixes
  ///
  /// Examples:
  /// - formatVolume(1234567890) => "1.2B"
  /// - formatVolume(500300000) => "500.3M"
  /// - formatVolume(45600) => "45.6K"
  /// - formatVolume(123) => "123"
  static String formatVolume(double volume, {int decimals = 1}) {
    if (volume >= 1e9) {
      return '${(volume / 1e9).toStringAsFixed(decimals)}B';
    } else if (volume >= 1e6) {
      return '${(volume / 1e6).toStringAsFixed(decimals)}M';
    } else if (volume >= 1e3) {
      return '${(volume / 1e3).toStringAsFixed(decimals)}K';
    } else {
      return volume.toStringAsFixed(0);
    }
  }

  /// Format market cap (same as volume)
  static String formatMarketCap(double cap, {int decimals = 1}) {
    return formatVolume(cap, decimals: decimals);
  }

  /// Format compact number with appropriate suffix
  static String formatCompact(double number, {int decimals = 1}) {
    return formatVolume(number, decimals: decimals);
  }

  /// Format time ago from DateTime
  ///
  /// Examples:
  /// - timeAgo(2 hours ago) => "2h ago"
  /// - timeAgo(5 minutes ago) => "5m ago"
  /// - timeAgo(30 seconds ago) => "Just now"
  /// - timeAgo(yesterday) => "Yesterday"
  static String timeAgo(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}w ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '${years}y ago';
    }
  }

  /// Format date and time
  static String formatDateTime(DateTime dateTime, {bool showTime = true}) {
    if (showTime) {
      return DateFormat('MMM d, y HH:mm').format(dateTime);
    } else {
      return DateFormat('MMM d, y').format(dateTime);
    }
  }

  /// Format date only
  static String formatDate(DateTime dateTime) {
    return DateFormat('MMM d, y').format(dateTime);
  }

  /// Format time only
  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm:ss').format(dateTime);
  }

  /// Format timestamp (milliseconds since epoch)
  static String formatTimestamp(int timestamp, {bool showTime = true}) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return formatDateTime(dateTime, showTime: showTime);
  }

  /// Format change with arrow indicator
  ///
  /// Examples:
  /// - formatChange(123.45) => "↑ \$123.45"
  /// - formatChange(-67.89) => "↓ \$67.89"
  static String formatChange(double change, {bool showCurrency = true}) {
    final arrow = change >= 0 ? '↑' : '↓';
    final value = change.abs();

    if (showCurrency) {
      return '$arrow ${formatPrice(value)}';
    } else {
      return '$arrow ${formatPriceSimple(value)}';
    }
  }

  /// Format decimal with fixed precision
  static String formatDecimal(double value, {int decimals = 2}) {
    return value.toStringAsFixed(decimals);
  }

  /// Format integer with thousand separators
  static String formatInteger(int value) {
    final formatter = NumberFormat.decimalPattern();
    return formatter.format(value);
  }
}
