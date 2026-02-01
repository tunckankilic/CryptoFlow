import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// Result of biometric authentication
enum BiometricResult {
  success,
  failed,
  notAvailable,
  notEnrolled,
  lockedOut,
  permanentlyLocked,
  error,
}

/// Service for handling biometric authentication
class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  /// Check if device supports biometric authentication
  Future<bool> isAvailable() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      return canCheck && isSupported;
    } catch (e) {
      return false;
    }
  }

  /// Get available biometric types on this device
  Future<List<BiometricType>> getAvailableTypes() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// Authenticate using biometrics
  Future<BiometricResult> authenticate({
    required String reason,
    bool biometricOnly = false,
  }) async {
    try {
      final success = await _auth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: biometricOnly,
          useErrorDialogs: true,
        ),
      );
      return success ? BiometricResult.success : BiometricResult.failed;
    } on PlatformException catch (e) {
      if (e.code == 'NotAvailable') return BiometricResult.notAvailable;
      if (e.code == 'NotEnrolled') return BiometricResult.notEnrolled;
      if (e.code == 'LockedOut') return BiometricResult.lockedOut;
      if (e.code == 'PermanentlyLockedOut') {
        return BiometricResult.permanentlyLocked;
      }
      return BiometricResult.error;
    }
  }

  /// Get appropriate icon for the biometric type
  IconData getIcon(List<BiometricType> types) {
    if (types.contains(BiometricType.face)) return Icons.face;
    if (types.contains(BiometricType.fingerprint)) return Icons.fingerprint;
    return Icons.lock;
  }

  /// Get label for the biometric type
  String getLabel(List<BiometricType> types) {
    if (types.contains(BiometricType.face)) return 'Face ID';
    if (types.contains(BiometricType.fingerprint)) return 'Touch ID';
    return 'Biometric';
  }
}
