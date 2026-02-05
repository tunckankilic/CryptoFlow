import 'package:core/error/failures.dart';
import 'package:core/usecases/usecase.dart';
import 'package:dartz/dartz.dart';

import '../entities/journal_entry.dart';
import '../repositories/journal_repository.dart';

/// Parameters for UpdateJournalEntry use case
class UpdateJournalEntryParams {
  final JournalEntry entry;

  UpdateJournalEntryParams({required this.entry});
}

/// Use case to update an existing journal entry
/// Validates entry data before updating in repository
class UpdateJournalEntry implements UseCase<void, UpdateJournalEntryParams> {
  final JournalRepository repository;

  UpdateJournalEntry(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateJournalEntryParams params) async {
    // Validate entry data
    if (params.entry.id <= 0) {
      return Left(ValidationFailure('Invalid entry ID'));
    }

    if (params.entry.quantity <= 0) {
      return Left(ValidationFailure('Quantity must be positive'));
    }

    if (params.entry.entryPrice <= 0) {
      return Left(ValidationFailure('Entry price must be positive'));
    }

    if (params.entry.symbol.isEmpty) {
      return Left(ValidationFailure('Symbol cannot be empty'));
    }

    // Update entry in repository
    return await repository.updateEntry(params.entry);
  }
}
