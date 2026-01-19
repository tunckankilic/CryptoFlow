import 'dart:async';
import 'dart:convert';
import 'dart:developer' show log;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:rxdart/rxdart.dart';
import '../constants/api_endpoints.dart';
import '../constants/app_constants.dart';
import '../error/exceptions.dart';

/// WebSocket connection status
enum WebSocketStatus {
  connecting,
  connected,
  disconnected,
  error,
  reconnecting,
}

/// Abstract WebSocket client interface
abstract class WebSocketClient {
  /// Connect to WebSocket stream
  Stream<dynamic> connect(String url);

  /// Disconnect from WebSocket
  void disconnect();

  /// Check if currently connected
  bool get isConnected;

  /// Stream of connection status changes
  Stream<WebSocketStatus> get statusStream;

  /// Dispose of resources
  void dispose();
}

/// Binance WebSocket client implementation with auto-reconnection
class BinanceWebSocketClient implements WebSocketClient {
  WebSocketChannel? _channel;
  final _statusController = BehaviorSubject<WebSocketStatus>.seeded(
    WebSocketStatus.disconnected,
  );
  final _dataController = StreamController<dynamic>.broadcast();

  Timer? _pingTimer;
  Timer? _reconnectTimer;
  String? _currentUrl;
  int _reconnectAttempts = 0;
  bool _manualDisconnect = false;

  BinanceWebSocketClient();

  @override
  Stream<dynamic> connect(String url) {
    _currentUrl = url;
    _manualDisconnect = false;
    _reconnectAttempts = 0;
    _connect();
    return _dataController.stream;
  }

  /// Internal connect logic
  void _connect() {
    if (_currentUrl == null) return;

    try {
      _statusController.add(WebSocketStatus.connecting);

      final fullUrl = '${BinanceEndpoints.wsBaseUrl}$_currentUrl';
      log('Connecting to WebSocket: $fullUrl');

      _channel = WebSocketChannel.connect(Uri.parse(fullUrl));

      _statusController.add(WebSocketStatus.connected);
      _reconnectAttempts = 0;
      log('WebSocket connected');

      // Start ping timer to keep connection alive
      _startPingTimer();

      // Listen to messages
      _channel!.stream.listen(
        _onData,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );
    } catch (e) {
      log('WebSocket connection error: $e');
      _handleConnectionError(e);
    }
  }

  /// Handle incoming data
  void _onData(dynamic data) {
    try {
      final decoded = jsonDecode(data);
      _dataController.add(decoded);
    } catch (e) {
      log('⚠️ WebSocket parse error: $e');
      _dataController.addError(
        WebSocketException(
          type: WebSocketExceptionType.parseError,
          details: data,
        ),
      );
    }
  }

  /// Handle errors
  void _onError(dynamic error) {
    log('WebSocket error: $error');
    _statusController.add(WebSocketStatus.error);

    _dataController.addError(
      WebSocketException(
        type: WebSocketExceptionType.connectionLost,
        message: error.toString(),
      ),
    );

    _attemptReconnect();
  }

  /// Handle connection closed
  void _onDone() {
    log('WebSocket connection closed');
    _stopPingTimer();

    if (!_manualDisconnect) {
      _statusController.add(WebSocketStatus.disconnected);
      _attemptReconnect();
    } else {
      _statusController.add(WebSocketStatus.disconnected);
    }
  }

  /// Handle connection errors
  void _handleConnectionError(dynamic error) {
    _statusController.add(WebSocketStatus.error);

    _dataController.addError(
      WebSocketException(
        type: WebSocketExceptionType.connectionFailed,
        message: error.toString(),
      ),
    );

    _attemptReconnect();
  }

  /// Attempt to reconnect with exponential backoff
  void _attemptReconnect() {
    if (_manualDisconnect) return;

    if (_reconnectAttempts >= AppConstants.wsMaxReconnectAttempts) {
      log('Max reconnection attempts reached');
      _statusController.add(WebSocketStatus.error);
      _dataController.addError(
        WebSocketException(
          type: WebSocketExceptionType.connectionFailed,
          message: 'Max reconnection attempts exceeded',
        ),
      );
      return;
    }

    _reconnectAttempts++;
    _statusController.add(WebSocketStatus.reconnecting);

    // Calculate delay with exponential backoff: 1s, 2s, 4s, 8s, 16s, max 30s
    final delay = _calculateReconnectDelay();
    log('Reconnecting in ${delay}s (attempt $_reconnectAttempts)');

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: delay), () {
      log('Attempting reconnection...');
      _connect();
    });
  }

  /// Calculate reconnection delay with exponential backoff
  int _calculateReconnectDelay() {
    final baseDelay = AppConstants.wsReconnectDelayBase;
    final maxDelay = AppConstants.wsReconnectDelayMax;

    // Exponential backoff: base * 2^(attempts-1)
    final delay = baseDelay * (1 << (_reconnectAttempts - 1));

    // Cap at max delay
    return delay > maxDelay ? maxDelay : delay;
  }

  /// Start ping timer to keep connection alive
  void _startPingTimer() {
    _stopPingTimer();

    final pingInterval = Duration(
      minutes: AppConstants.wsPingIntervalMinutes,
    );

    _pingTimer = Timer.periodic(pingInterval, (timer) {
      if (_channel != null && isConnected) {
        try {
          // Send ping message (Binance expects pong response)
          _channel!.sink.add(jsonEncode({'method': 'ping'}));
          log('Ping sent');
        } catch (e) {
          log('Failed to send ping: $e');
        }
      }
    });
  }

  /// Stop ping timer
  void _stopPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  @override
  void disconnect() {
    log('Disconnecting WebSocket');
    _manualDisconnect = true;
    _reconnectTimer?.cancel();
    _stopPingTimer();

    try {
      _channel?.sink.close();
    } catch (e) {
      log('Error closing WebSocket: $e');
    }

    _channel = null;
    _currentUrl = null;
    _reconnectAttempts = 0;
    _statusController.add(WebSocketStatus.disconnected);
  }

  @override
  bool get isConnected {
    return _statusController.value == WebSocketStatus.connected;
  }

  @override
  Stream<WebSocketStatus> get statusStream => _statusController.stream;

  @override
  void dispose() {
    disconnect();
    _statusController.close();
    _dataController.close();
  }

  /// Send a message to the WebSocket
  void send(dynamic message) {
    if (!isConnected) {
      throw WebSocketException(
        type: WebSocketExceptionType.sendFailed,
        message: 'Cannot send message: WebSocket not connected',
      );
    }

    try {
      final encoded = message is String ? message : jsonEncode(message);
      _channel!.sink.add(encoded);
    } catch (e) {
      throw WebSocketException(
        type: WebSocketExceptionType.sendFailed,
        message: 'Failed to send message: $e',
      );
    }
  }

  /// Subscribe to a channel (Binance specific)
  void subscribe(String channel) {
    send({
      'method': 'SUBSCRIBE',
      'params': [channel],
      'id': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Unsubscribe from a channel (Binance specific)
  void unsubscribe(String channel) {
    send({
      'method': 'UNSUBSCRIBE',
      'params': [channel],
      'id': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Get current status
  WebSocketStatus get status => _statusController.value;

  /// Get reconnect attempts count
  int get reconnectAttempts => _reconnectAttempts;
}
