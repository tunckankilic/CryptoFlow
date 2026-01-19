import 'dart:async';

/// Debouncer utility for delaying function execution
/// Useful for search inputs, scroll events, etc.
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({
    this.delay = const Duration(milliseconds: 500),
  });

  /// Run the callback after the delay
  /// If called again before delay expires, timer is reset
  void run(VoidCallback callback) {
    cancel();
    _timer = Timer(delay, callback);
  }

  /// Cancel pending callback
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Check if debouncer is active
  bool get isActive => _timer?.isActive ?? false;

  /// Dispose of the debouncer
  void dispose() {
    cancel();
  }
}

/// Throttler utility for rate-limiting function execution
/// Ensures function is called at most once per duration
class Throttler {
  final Duration duration;
  DateTime? _lastExecutionTime;

  Throttler({
    this.duration = const Duration(milliseconds: 1000),
  });

  /// Run callback if enough time has passed since last execution
  void run(VoidCallback callback) {
    final now = DateTime.now();

    if (_lastExecutionTime == null ||
        now.difference(_lastExecutionTime!) >= duration) {
      _lastExecutionTime = now;
      callback();
    }
  }

  /// Reset throttler
  void reset() {
    _lastExecutionTime = null;
  }

  /// Check if throttler can execute
  bool get canExecute {
    if (_lastExecutionTime == null) return true;
    return DateTime.now().difference(_lastExecutionTime!) >= duration;
  }
}

/// Callback type for debouncer/throttler
typedef VoidCallback = void Function();
