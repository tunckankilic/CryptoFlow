import 'package:core/error/failures.dart';
import 'package:core/usecases/usecase.dart';
import 'package:dartz/dartz.dart';

import '../entities/journal_entry.dart';
import '../repositories/journal_repository.dart';

/// Parameters for AddJournalEntry use case
class AddJournalEntryParams {
  final JournalEntry entry;

  AddJournalEntryParams({required this.entry});
}

/// Use case to add a new journal entry
/// Validates entry data before adding to repository
class AddJournalEntry implements UseCase<int, AddJournalEntryParams> {
  final JournalRepository repository;

  AddJournalEntry(this.repository);

  @override
  Future<Either<Failure, int>> call(AddJournalEntryParams params) async {
    // Validate entry data
    if (params.entry.quantity <= 0) {
      return Left(ValidationFailure('Quantity must be positive'));
    }

    if (params.entry.entryPrice <= 0) {
      return Left(ValidationFailure('Entry price must be positive'));
    }

    if (params.entry.symbol.isEmpty) {
      return Left(ValidationFailure('Symbol cannot be empty'));
    }

    // Add entry to repository
    return await repository.addEntry(params.entry);
  }
}
