import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

/// Use case for watching authentication state changes (stream-based)
class WatchAuthState {
  final AuthRepository repository;

  WatchAuthState(this.repository);

  /// Returns a stream of auth state changes
  Stream<AppUser?> call() {
    return repository.authStateChanges;
  }
}
