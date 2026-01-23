import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:google_sign_in/google_sign_in.dart';

import '../models/app_user_model.dart';
import '../../domain/entities/app_user.dart';

/// Exception thrown by Firebase Auth operations
class AuthException implements Exception {
  final String message;
  final String? code;

  const AuthException(this.message, {this.code});

  @override
  String toString() =>
      'AuthException: $message${code != null ? ' ($code)' : ''}';
}

/// Firebase Authentication data source
class FirebaseAuthDataSource {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthDataSource({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Get current Firebase user
  User? get currentUser => _auth.currentUser;

  /// Sign in with Google
  Future<AppUserModel> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw const AuthException(
          'Google sign in was cancelled',
          code: 'cancelled',
        );
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw const AuthException(
          'Failed to sign in with Google',
          code: 'null-user',
        );
      }

      return AppUserModel.fromFirebaseUser(
        userCredential.user!,
        provider: AuthProvider.google,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        e.message ?? 'Google sign in failed',
        code: e.code,
      );
    }
  }

  /// Sign in with Apple
  Future<AppUserModel> signInWithApple() async {
    try {
      final appleProvider = AppleAuthProvider()
        ..addScope('email')
        ..addScope('name');

      final userCredential = await _auth.signInWithProvider(appleProvider);

      if (userCredential.user == null) {
        throw const AuthException(
          'Failed to sign in with Apple',
          code: 'null-user',
        );
      }

      return AppUserModel.fromFirebaseUser(
        userCredential.user!,
        provider: AuthProvider.apple,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        e.message ?? 'Apple sign in failed',
        code: e.code,
      );
    }
  }

  /// Sign in anonymously
  Future<AppUserModel> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();

      if (userCredential.user == null) {
        throw const AuthException(
          'Failed to sign in anonymously',
          code: 'null-user',
        );
      }

      return AppUserModel.fromFirebaseUser(
        userCredential.user!,
        provider: AuthProvider.anonymous,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        e.message ?? 'Anonymous sign in failed',
        code: e.code,
      );
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      // Sign out from Google if signed in
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
      // Sign out from Firebase
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        e.message ?? 'Sign out failed',
        code: e.code,
      );
    }
  }

  /// Delete user account
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw const AuthException(
          'No user signed in',
          code: 'no-user',
        );
      }
      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        e.message ?? 'Account deletion failed',
        code: e.code,
      );
    }
  }

  /// Get current user as AppUserModel
  AppUserModel? getCurrentUser() {
    final user = _auth.currentUser;
    if (user == null) return null;
    return AppUserModel.fromFirebaseUser(user);
  }
}
