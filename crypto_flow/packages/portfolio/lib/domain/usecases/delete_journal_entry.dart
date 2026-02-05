import 'package:core/error/failures.dart';
import 'package:core/usecases/usecase.dart';
import 'package:dartz/dartz.dart';

import '../repositories/journal_repository.dart';

/// Parameters for DeleteJournalEntry use case
class DeleteJournalEntryParams {
  final int id;

  DeleteJournalEntryParams({required this.id});
}

/// Use case to delete a journal entry
class DeleteJournalEntry implements UseCase<void, DeleteJournalEntryParams> {
  final JournalRepository repository;

  DeleteJournalEntry(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteJournalEntryParams params) async {
    // Validate ID
    if (params.id <= 0) {
      return Left(ValidationFailure('Invalid entry ID'));
    }

    // Delete entry from repository
    return await repository.deleteEntry(params.id);
  }
}
