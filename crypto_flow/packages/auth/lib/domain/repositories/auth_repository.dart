import 'package:dartz/dartz.dart';
import 'package:core/core.dart';

import '../entities/app_user.dart';

/// Abstract repository interface for authentication operations
abstract class AuthRepository {
  /// Stream of authentication state changes
  /// Emits null when user is signed out, AppUser when signed in
  Stream<AppUser?> get authStateChanges;

  /// Sign in with Google
  /// Returns Either<Failure, AppUser> on success or failure
  Future<Either<Failure, AppUser>> signInWithGoogle();

  /// Sign in with Apple (iOS only)
  /// Returns Either<Failure, AppUser> on success or failure
  Future<Either<Failure, AppUser>> signInWithApple();

  /// Sign in anonymously
  /// Returns Either<Failure, AppUser> on success or failure
  Future<Either<Failure, AppUser>> signInAnonymously();

  /// Sign out current user
  /// Returns Either<Failure, void> on success or failure
  Future<Either<Failure, void>> signOut();

  /// Get current authenticated user
  /// Returns null if not authenticated
  Future<Either<Failure, AppUser?>> getCurrentUser();

  /// Delete current user account
  /// Returns Either<Failure, void> on success or failure
  Future<Either<Failure, void>> deleteAccount();
}
