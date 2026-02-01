import 'package:dartz/dartz.dart';
import 'package:core/core.dart';

import '../repositories/auth_repository.dart';

/// Use case for deleting user account
class DeleteAccount implements UseCase<void, NoParams> {
  final AuthRepository repository;

  DeleteAccount(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.deleteAccount();
  }
}
