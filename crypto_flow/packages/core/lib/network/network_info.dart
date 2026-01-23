import 'package:connectivity_plus/connectivity_plus.dart';

/// Abstract interface for network connectivity checking
abstract class NetworkInfo {
  /// Check if device is connected to internet
  Future<bool> get isConnected;

  /// Stream of connectivity changes
  Stream<bool> get onConnectivityChanged;

  /// Get current connectivity type
  Future<ConnectivityResult> get connectivityType;
}

/// Implementation of NetworkInfo using connectivity_plus package
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  NetworkInfoImpl(this.connectivity);

  @override
  Future<bool> get isConnected async {
    final result = await connectivity.checkConnectivity();
    return _isConnectedResult(result);
  }

  @override
  Stream<bool> get onConnectivityChanged {
    return connectivity.onConnectivityChanged.map((result) {
      return _isConnectedResult(result);
    });
  }

  @override
  Future<ConnectivityResult> get connectivityType async {
    return await connectivity.checkConnectivity();
  }

  /// Helper to determine if connectivity result means connected
  bool _isConnectedResult(ConnectivityResult result) {
    return result != ConnectivityResult.none;
  }

  /// Check if connected via WiFi
  Future<bool> get isWiFi async {
    final result = await connectivity.checkConnectivity();
    return result == ConnectivityResult.wifi;
  }

  /// Check if connected via mobile data
  Future<bool> get isMobile async {
    final result = await connectivity.checkConnectivity();
    return result == ConnectivityResult.mobile;
  }

  /// Check if connected via ethernet
  Future<bool> get isEthernet async {
    final result = await connectivity.checkConnectivity();
    return result == ConnectivityResult.ethernet;
  }
}
