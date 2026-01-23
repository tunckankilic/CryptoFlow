import 'package:auth/auth.dart';

import 'injection_container.dart';

/// Register Auth package dependencies
Future<void> registerAuthModule() async {
  // Data sources
  getIt.registerLazySingleton<FirebaseAuthDataSource>(
    () => FirebaseAuthDataSource(),
  );

  // Repository
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<FirebaseAuthDataSource>()),
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

  // BLoC
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(
      signInWithGoogle: getIt<SignInWithGoogle>(),
      signInWithApple: getIt<SignInWithApple>(),
      signInAnonymously: getIt<SignInAnonymously>(),
      signOut: getIt<SignOut>(),
      getCurrentUser: getIt<GetCurrentUser>(),
      watchAuthState: getIt<WatchAuthState>(),
    ),
  );
}
