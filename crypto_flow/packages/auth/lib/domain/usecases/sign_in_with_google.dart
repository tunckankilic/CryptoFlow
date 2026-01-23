import 'package:dartz/dartz.dart';
import 'package:core/core.dart';

import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

/// Use case for signing in with Google
class SignInWithGoogle implements UseCase<AppUser, NoParams> {
  final AuthRepository repository;

  SignInWithGoogle(this.repository);

  @override
  Future<Either<Failure, AppUser>> call(NoParams params) {
    return repository.signInWithGoogle();
  }
}
