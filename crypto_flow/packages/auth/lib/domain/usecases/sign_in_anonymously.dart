import 'package:dartz/dartz.dart';
import 'package:core/core.dart';

import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

/// Use case for signing in anonymously
class SignInAnonymously implements UseCase<AppUser, NoParams> {
  final AuthRepository repository;

  SignInAnonymously(this.repository);

  @override
  Future<Either<Failure, AppUser>> call(NoParams params) {
    return repository.signInAnonymously();
  }
}
