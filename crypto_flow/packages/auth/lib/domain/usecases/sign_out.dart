import 'package:dartz/dartz.dart';
import 'package:core/core.dart';

import '../repositories/auth_repository.dart';

/// Use case for signing out
class SignOut implements UseCase<void, NoParams> {
  final AuthRepository repository;

  SignOut(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.signOut();
  }
}
