import 'package:dartz/dartz.dart';
import 'package:core/core.dart';

import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

/// Use case for getting current authenticated user
class GetCurrentUser implements UseCase<AppUser?, NoParams> {
  final AuthRepository repository;

  GetCurrentUser(this.repository);

  @override
  Future<Either<Failure, AppUser?>> call(NoParams params) {
    return repository.getCurrentUser();
  }
}
