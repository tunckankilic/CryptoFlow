import 'dart:async';
import 'dart:convert';
import 'dart:developer' show log;

import 'package:rxdart/rxdart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../config/app_config.dart';
import '../constants/app_constants.dart';
import '../error/exceptions.dart';
import 'token_provider.dart';
import 'websocket_client.dart';

/// WebSocket client for the CryptoFlow AWS API Gateway WebSocket endpoint.
///
/// Used exclusively for receiving server-push messages such as triggered
/// alert notifications. Market-data streams continue to use the separate
/// [BinanceWebSocketClient].
///
/// Authentication is performed by appending the Cognito access token as a
/// `?token=` query parameter during the `$connect` upgrade request.
class AwsWebSocketClient implements WebSocketClient {
  final TokenProvider _tokenProvider;

  WebSocketChannel? _channel;
  final _statusController = BehaviorSubject<WebSocketStatus>.seeded(
    WebSocketStatus.disconnected,
  );
  final _dataController = StreamController<dynamic>.broadcast();

  Timer? _pingTimer;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  bool _manualDisconnect = false;

  AwsWebSocketClient({required TokenProvider tokenProvider})
      : _tokenProvider = tokenProvider;

  // ------------------------------------------------------------------
  // Public API
  // ------------------------------------------------------------------

  @override
  Stream<dynamic> connect(String url) {
    _manualDisconnect = false;
    _reconnectAttempts = 0;
    _connectInternal();
    return _dataController.stream;
  }

  @override
  void disconnect() {
    log('AwsWebSocket: disconnecting');
    _manualDisconnect = true;
    _reconnectTimer?.cancel();
    _stopPingTimer();

    try {
      _channel?.sink.close();
    } catch (e) {
      log('AwsWebSocket: error closing — $e');
    }

    _channel = null;
    _reconnectAttempts = 0;
    _statusController.add(WebSocketStatus.disconnected);
  }

  @override
  bool get isConnected => _statusController.value == WebSocketStatus.connected;

  @override
  Stream<WebSocketStatus> get statusStream => _statusController.stream;

  @override
  void dispose() {
    disconnect();
    _statusController.close();
    _dataController.close();
  }

  // ------------------------------------------------------------------
  // Internal
  // ------------------------------------------------------------------

  Future<void> _connectInternal() async {
    _statusController.add(WebSocketStatus.connecting);

    try {
      final token = await _tokenProvider.getAccessToken();
      if (token == null) {
        log('AwsWebSocket: no token available — cannot connect');
        _statusController.add(WebSocketStatus.error);
        return;
      }

      final wsUrl = '${AppConfig.wsBaseUrl}?token=$token';
      log('AwsWebSocket: connecting to ${AppConfig.wsBaseUrl}');

      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _statusController.add(WebSocketStatus.connected);
      _reconnectAttempts = 0;

      _startPingTimer();

      _channel!.stream.listen(
        _onData,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );
    } catch (e) {
      log('AwsWebSocket: connection error — $e');
      _statusController.add(WebSocketStatus.error);
      _attemptReconnect();
    }
  }

  void _onData(dynamic data) {
    try {
      final decoded = jsonDecode(data);
      _dataController.add(decoded);
    } catch (e) {
      log('AwsWebSocket: parse error — $e');
      _dataController.addError(
        WebSocketException(
          type: WebSocketExceptionType.parseError,
          details: data,
        ),
      );
    }
  }

  void _onError(dynamic error) {
    log('AwsWebSocket: error — $error');
    _statusController.add(WebSocketStatus.error);
    _dataController.addError(
      WebSocketException(
        type: WebSocketExceptionType.connectionLost,
        message: error.toString(),
      ),
    );
    _attemptReconnect();
  }

  void _onDone() {
    log('AwsWebSocket: connection closed');
    _stopPingTimer();
    if (!_manualDisconnect) {
      _statusController.add(WebSocketStatus.disconnected);
      _attemptReconnect();
    } else {
      _statusController.add(WebSocketStatus.disconnected);
    }
  }

  void _attemptReconnect() {
    if (_manualDisconnect) return;
    if (_reconnectAttempts >= AppConstants.wsMaxReconnectAttempts) {
      log('AwsWebSocket: max reconnect attempts reached');
      _statusController.add(WebSocketStatus.error);
      return;
    }

    _reconnectAttempts++;
    _statusController.add(WebSocketStatus.reconnecting);

    final delay = _reconnectDelay();
    log('AwsWebSocket: reconnecting in ${delay}s (attempt $_reconnectAttempts)');

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: delay), _connectInternal);
  }

  int _reconnectDelay() {
    final base = AppConstants.wsReconnectDelayBase;
    final max = AppConstants.wsReconnectDelayMax;
    final delay = base * (1 << (_reconnectAttempts - 1));
    return delay > max ? max : delay;
  }

  void _startPingTimer() {
    _stopPingTimer();
    _pingTimer = Timer.periodic(
      Duration(minutes: AppConstants.wsPingIntervalMinutes),
      (_) {
        if (_channel != null && isConnected) {
          try {
            _channel!.sink.add(jsonEncode({'action': 'ping'}));
          } catch (e) {
            log('AwsWebSocket: ping failed — $e');
          }
        }
      },
    );
  }

  void _stopPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }
}
