import 'package:equatable/equatable.dart';
import 'package:local_auth/local_auth.dart';

/// Base class for biometric states
abstract class BiometricState extends Equatable {
  const BiometricState();

  @override
  List<Object?> get props => [];
}

/// Initial state before checking availability
class BiometricInitial extends BiometricState {
  const BiometricInitial();
}

/// Checking biometric availability
class BiometricChecking extends BiometricState {
  const BiometricChecking();
}

/// Biometric is available on this device
class BiometricAvailable extends BiometricState {
  final List<BiometricType> types;
  final bool isEnabled;

  const BiometricAvailable({
    required this.types,
    required this.isEnabled,
  });

  @override
  List<Object?> get props => [types, isEnabled];
}

/// Biometric is not available on this device
class BiometricNotAvailable extends BiometricState {
  const BiometricNotAvailable();
}

/// Authentication successful
class BiometricAuthenticated extends BiometricState {
  const BiometricAuthenticated();
}

/// Authentication failed
class BiometricFailed extends BiometricState {
  final String message;

  const BiometricFailed({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Too many failed attempts
class BiometricLockedOut extends BiometricState {
  final bool permanent;

  const BiometricLockedOut({required this.permanent});

  @override
  List<Object?> get props => [permanent];
}
