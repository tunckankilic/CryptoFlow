import 'package:auth/auth.dart';

import 'injection_container.dart';

/// Register Auth package dependencies
Future<void> registerAuthModule() async {
  // Data source — Cognito (AWS)
  getIt.registerLazySingleton<AuthDataSource>(
    () => CognitoAuthDataSource(),
  );

  // Repository
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<AuthDataSource>()),
  );

  // Use cases
  getIt.registerLazySingleton<SignInWithApple>(
    () => SignInWithApple(getIt<AuthRepository>()),
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

  // BLoC — lazySingleton because it's a global BLoC shared across the app
  getIt.registerLazySingleton<AuthBloc>(
    () => AuthBloc(
      signInWithApple: getIt<SignInWithApple>(),
      signOut: getIt<SignOut>(),
      getCurrentUser: getIt<GetCurrentUser>(),
      watchAuthState: getIt<WatchAuthState>(),
      deleteAccount: getIt<DeleteAccount>(),
    ),
  );
}
