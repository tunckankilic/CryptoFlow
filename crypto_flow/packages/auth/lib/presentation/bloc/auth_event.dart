import 'package:equatable/equatable.dart';

/// Base class for all authentication events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Check if user is already authenticated
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Request Google Sign In
class AuthGoogleSignInRequested extends AuthEvent {
  const AuthGoogleSignInRequested();
}

/// Request Apple Sign In
class AuthAppleSignInRequested extends AuthEvent {
  const AuthAppleSignInRequested();
}

/// Request Anonymous Sign In
class AuthAnonymousSignInRequested extends AuthEvent {
  const AuthAnonymousSignInRequested();
}

/// Request Sign Out
class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

/// Request Account Deletion
class AuthDeleteAccountRequested extends AuthEvent {
  const AuthDeleteAccountRequested();
}

/// Auth state changed (from stream)
class AuthStateChanged extends AuthEvent {
  final dynamic user;

  const AuthStateChanged(this.user);

  @override
  List<Object?> get props => [user];
}
