import 'package:auth/auth.dart';
import 'package:core/core.dart';

import 'injection_container.dart';

/// Register Auth package dependencies
Future<void> registerAuthModule() async {
  // Data source — feature-flagged between Cognito (AWS) and Firebase (legacy)
  if (FeatureFlags.useCognitoAuth) {
    getIt.registerLazySingleton<AuthDataSource>(
      () => CognitoAuthDataSource(),
    );
  } else {
    getIt.registerLazySingleton<AuthDataSource>(
      () => FirebaseAuthDataSource(),
    );
  }

  // Repository
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<AuthDataSource>()),
  );

  // Use cases
  getIt.registerLazySingleton<SignInWithGoogle>(
    () => SignInWithGoogle(getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<SignInWithApple>(
    () => SignInWithApple(getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<SignInAnonymously>(
    () => SignInAnonymously(getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<SignOut>(
    () => SignOut(getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<GetCurrentUser>(
    () => GetCurrentUser(getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<WatchAuthState>(
    () => WatchAuthState(getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<DeleteAccount>(
    () => DeleteAccount(getIt<AuthRepository>()),
  );

  // BLoC
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(
      signInWithGoogle: getIt<SignInWithGoogle>(),
      signInWithApple: getIt<SignInWithApple>(),
      signInAnonymously: getIt<SignInAnonymously>(),
      signOut: getIt<SignOut>(),
      getCurrentUser: getIt<GetCurrentUser>(),
      watchAuthState: getIt<WatchAuthState>(),
      deleteAccount: getIt<DeleteAccount>(),
    ),
  );
}
