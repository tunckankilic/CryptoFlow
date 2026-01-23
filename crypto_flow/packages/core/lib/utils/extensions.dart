/// Useful extensions for common operations
library;

// String extensions
extension StringExtensions on String {
  /// Convert string to uppercase symbol format
  /// Example: "btcusdt".toSymbol() => "BTCUSDT"
  String toSymbol() => toUpperCase();

  /// Convert string to lowercase symbol format
  /// Example: "BTCUSDT".toSymbolLower() => "btcusdt"
  String toSymbolLower() => toLowerCase();

  /// Check if string is a valid symbol (alphanumeric only)
  bool get isValidSymbol =>
      isNotEmpty && RegExp(r'^[a-zA-Z0-9]+$').hasMatch(this);

  /// Capitalize first letter
  /// Example: "bitcoin".capitalize() => "Bitcoin"
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  /// Title case (capitalize each word)
  /// Example: "hello world".toTitleCase() => "Hello World"
  String toTitleCase() {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize()).join(' ');
  }

  /// Check if string is numeric
  bool get isNumeric => double.tryParse(this) != null;

  /// Convert to double safely (returns 0 if invalid)
  double toDoubleSafe() => double.tryParse(this) ?? 0.0;

  /// Convert to int safely (returns 0 if invalid)
  int toIntSafe() => int.tryParse(this) ?? 0;
}

// Double extensions
extension DoubleExtensions on double {
  /// Quick percent formatting
  /// Example: 5.23.toPercentString() => "+5.23%"
  String toPercentString({int decimals = 2}) {
    final sign = this >= 0 ? '+' : '';
    return '$sign${toStringAsFixed(decimals)}%';
  }

  /// Format as price
  /// Example: 67234.50.toPriceString() => "\$67,234.50"
  String toPriceString({int decimals = 2}) {
    return toStringAsFixed(decimals);
  }

  /// Check if value is positive
  bool get isPositive => this > 0;

  /// Check if value is negative
  bool get isNegative => this < 0;

  /// Clamp value between min and max
  double clampValue(double min, double max) {
    if (this < min) return min;
    if (this > max) return max;
    return this;
  }

  /// Round to decimal places
  double roundToDecimals(int decimals) {
    final factor = 10.0 * decimals;
    return (this * factor).round() / factor;
  }
}

// DateTime extensions
extension DateTimeExtensions on DateTime {
  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Check if date is tomorrow
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  /// Check if date is in the past
  bool get isPast => isBefore(DateTime.now());

  /// Check if date is in the future
  bool get isFuture => isAfter(DateTime.now());

  /// Get start of day (00:00:00)
  DateTime get startOfDay => DateTime(year, month, day);

  /// Get end of day (23:59:59)
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);

  /// Get timestamp in milliseconds
  int get timestamp => millisecondsSinceEpoch;

  /// Get timestamp in seconds
  int get timestampSeconds => millisecondsSinceEpoch ~/ 1000;

  /// Format as time ago
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(this);

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
    } else {
      return '${difference.inDays ~/ 7}w ago';
    }
  }

  /// Add business days (skip weekends)
  DateTime addBusinessDays(int days) {
    var result = this;
    var remaining = days;

    while (remaining > 0) {
      result = result.add(const Duration(days: 1));
      if (result.weekday != DateTime.saturday &&
          result.weekday != DateTime.sunday) {
        remaining--;
      }
    }

    return result;
  }

  /// Check if weekend
  bool get isWeekend =>
      weekday == DateTime.saturday || weekday == DateTime.sunday;

  /// Check if weekday
  bool get isWeekday => !isWeekend;
}

// List extensions
extension ListExtensions<T> on List<T> {
  /// Safely get element at index (returns null if out of bounds)
  T? getOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }

  /// Get first element or null
  T? get firstOrNull => isEmpty ? null : first;

  /// Get last element or null
  T? get lastOrNull => isEmpty ? null : last;

  /// Partition list into chunks of specified size
  List<List<T>> chunk(int size) {
    final chunks = <List<T>>[];
    for (var i = 0; i < length; i += size) {
      chunks.add(sublist(i, i + size > length ? length : i + size));
    }
    return chunks;
  }

  /// Remove duplicates
  List<T> unique() {
    return toSet().toList();
  }
}

// Map extensions
extension MapExtensions<K, V> on Map<K, V> {
  /// Safely get value with default
  V getOrDefault(K key, V defaultValue) {
    return this[key] ?? defaultValue;
  }

  /// Check if map has all keys
  bool hasKeys(List<K> keys) {
    return keys.every((key) => containsKey(key));
  }

  /// Get value or throw exception
  V getOrThrow(K key, {String? message}) {
    if (!containsKey(key)) {
      throw ArgumentError(message ?? 'Key $key not found in map');
    }
    return this[key] as V;
  }
}

// int extensions
extension IntExtensions on int {
  /// Convert milliseconds timestamp to DateTime
  DateTime get toDateTime => DateTime.fromMillisecondsSinceEpoch(this);

  /// Convert seconds timestamp to DateTime
  DateTime get toDateTimeFromSeconds =>
      DateTime.fromMillisecondsSinceEpoch(this * 1000);

  /// Format as duration (seconds to readable format)
  String get toDurationString {
    final duration = Duration(seconds: this);
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds.remainder(60)}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  /// Check if number is even
  bool get isEven => this % 2 == 0;

  /// Check if number is odd
  bool get isOdd => this % 2 != 0;
}
