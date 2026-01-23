import 'package:equatable/equatable.dart';

/// Authentication provider types
enum AuthProvider {
  /// Google Sign In
  google,

  /// Apple Sign In
  apple,

  /// Email/Password authentication
  email,

  /// Anonymous authentication
  anonymous,
}

/// Represents an authenticated user in the application
class AppUser extends Equatable {
  /// Firebase user ID
  final String uid;

  /// User's email address (may be null for anonymous users)
  final String? email;

  /// User's display name
  final String? displayName;

  /// URL to user's profile photo
  final String? photoUrl;

  /// Authentication provider used
  final AuthProvider provider;

  /// Timestamp when the account was created
  final DateTime createdAt;

  /// Timestamp of last login
  final DateTime lastLoginAt;

  const AppUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    required this.provider,
    required this.createdAt,
    required this.lastLoginAt,
  });

  /// Check if user is anonymous
  bool get isAnonymous => provider == AuthProvider.anonymous;

  /// Check if user has a verified email
  bool get hasEmail => email != null && email!.isNotEmpty;

  /// Get display name or fallback
  String get displayNameOrEmail => displayName ?? email ?? 'Anonymous User';

  /// Get initials for avatar
  String get initials {
    if (displayName != null && displayName!.isNotEmpty) {
      final parts = displayName!.split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return displayName![0].toUpperCase();
    }
    if (email != null && email!.isNotEmpty) {
      return email![0].toUpperCase();
    }
    return 'A';
  }

  @override
  List<Object?> get props => [
        uid,
        email,
        displayName,
        photoUrl,
        provider,
        createdAt,
        lastLoginAt,
      ];

  @override
  String toString() => 'AppUser(uid: $uid, email: $email, provider: $provider)';
}
