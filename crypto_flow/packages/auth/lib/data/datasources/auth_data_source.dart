import '../models/app_user_model.dart';

/// Exception thrown by any concrete [AuthDataSource] implementation.
///
/// `code` follows a small shared vocabulary so that
/// [AuthRepositoryImpl] can map it onto the domain `AuthFailure` enum
/// regardless of which datasource produced the error.
///
/// Common codes:
///   * `cancelled`     — user dismissed the sign-in flow
///   * `not-authorized`— wrong credentials / invalid token
///   * `no-user`       — operation requires a signed-in user
///   * `requires-recent-login` — sensitive op needs re-auth (delete account)
///   * `timeout`       — operation timed out
///   * `unsupported`   — datasource does not support this operation
///   * `unknown`       — anything else
class AuthException implements Exception {
  final String message;
  final String? code;

  const AuthException(this.message, {this.code});

  @override
  String toString() =>
      'AuthException: $message${code != null ? ' ($code)' : ''}';
}

/// Backend-agnostic authentication data source.
abstract class AuthDataSource {
  /// Emits the current user (or `null` when signed out) and updates whenever
  /// the underlying auth state changes.
  Stream<AppUserModel?> get authStateChanges;

  /// Returns the currently signed-in user, or `null` if there is none.
  Future<AppUserModel?> getCurrentUser();

  Future<AppUserModel> signInWithApple();

  Future<void> signOut();

  Future<void> deleteAccount();
}
