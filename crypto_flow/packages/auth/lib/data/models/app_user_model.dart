import 'package:amplify_auth_cognito/amplify_auth_cognito.dart' as cognito;
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

  /// Create from a Cognito [AuthUser] + the result of `fetchUserAttributes`.
  ///
  /// Cognito does not expose `creationDate` or `lastLogin` via
  /// `fetchUserAttributes`, so both fall back to "now" — that's acceptable
  /// because the app only uses these fields for display purposes.
  factory AppUserModel.fromCognitoUser({
    required cognito.AuthUser authUser,
    required List<cognito.AuthUserAttribute> attributes,
    AuthProvider? provider,
  }) {
    String? attr(String key) {
      for (final a in attributes) {
        if (a.userAttributeKey.key == key) return a.value;
      }
      return null;
    }

    final inferredProvider = provider ??
        _providerFromCognitoIdentities(attr('identities')) ??
        AuthProvider.email;

    return AppUserModel(
      uid: authUser.userId, // Cognito sub
      email: attr('email'),
      displayName: attr('name') ??
          attr('preferred_username') ??
          attr('given_name'),
      photoUrl: attr('picture'),
      provider: inferredProvider,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );
  }

  /// Cognito stores federated identities as a JSON string in the
  /// `identities` attribute, e.g.
  /// `[{"providerName":"Google","providerType":"Google", ...}]`.
  ///
  /// We do a tiny substring match to avoid pulling in `dart:convert` for
  /// such a small need.
  static AuthProvider? _providerFromCognitoIdentities(String? identities) {
    if (identities == null || identities.isEmpty) return null;
    final lower = identities.toLowerCase();
    if (lower.contains('signinwithapple') || lower.contains('"apple"')) {
      return AuthProvider.apple;
    }
    if (lower.contains('"google"')) {
      return AuthProvider.google;
    }
    return null;
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
