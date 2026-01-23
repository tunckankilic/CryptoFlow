import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;

import '../../domain/entities/app_user.dart';

/// Data model for AppUser with Firebase mapping
class AppUserModel extends AppUser {
  const AppUserModel({
    required super.uid,
    super.email,
    super.displayName,
    super.photoUrl,
    required super.provider,
    required super.createdAt,
    required super.lastLoginAt,
  });

  /// Create from Firebase User
  factory AppUserModel.fromFirebaseUser(User user, {AuthProvider? provider}) {
    // Determine provider from Firebase user
    AuthProvider authProvider = provider ?? AuthProvider.anonymous;

    if (provider == null && user.providerData.isNotEmpty) {
      final providerId = user.providerData.first.providerId;
      switch (providerId) {
        case 'google.com':
          authProvider = AuthProvider.google;
          break;
        case 'apple.com':
          authProvider = AuthProvider.apple;
          break;
        case 'password':
          authProvider = AuthProvider.email;
          break;
        default:
          authProvider =
              user.isAnonymous ? AuthProvider.anonymous : AuthProvider.email;
      }
    } else if (user.isAnonymous) {
      authProvider = AuthProvider.anonymous;
    }

    return AppUserModel(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      provider: authProvider,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
      lastLoginAt: user.metadata.lastSignInTime ?? DateTime.now(),
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'provider': provider.name,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory AppUserModel.fromJson(Map<String, dynamic> json) {
    return AppUserModel(
      uid: json['uid'] as String,
      email: json['email'] as String?,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      provider: AuthProvider.values.firstWhere(
        (e) => e.name == json['provider'],
        orElse: () => AuthProvider.anonymous,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: DateTime.parse(json['lastLoginAt'] as String),
    );
  }

  /// Convert to domain entity
  AppUser toEntity() => this;
}
