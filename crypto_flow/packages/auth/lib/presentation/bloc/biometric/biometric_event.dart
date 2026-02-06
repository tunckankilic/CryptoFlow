import 'package:equatable/equatable.dart';

/// Base class for biometric events
abstract class BiometricEvent extends Equatable {
  const BiometricEvent();

  @override
  List<Object?> get props => [];
}

/// Check if biometric is available on this device
class CheckBiometricAvailability extends BiometricEvent {
  const CheckBiometricAvailability();
}

/// Authenticate using biometrics
class AuthenticateWithBiometric extends BiometricEvent {
  final String reason;

  const AuthenticateWithBiometric({
    this.reason = 'CryptoWave\'a erişmek için doğrulayın',
  });

  @override
  List<Object?> get props => [reason];
}

/// Enable biometric authentication
class EnableBiometric extends BiometricEvent {
  const EnableBiometric();
}

/// Disable biometric authentication
class DisableBiometric extends BiometricEvent {
  const DisableBiometric();
}

/// Reset biometric state (e.g., after failed attempt)
class ResetBiometricState extends BiometricEvent {
  const ResetBiometricState();
}
