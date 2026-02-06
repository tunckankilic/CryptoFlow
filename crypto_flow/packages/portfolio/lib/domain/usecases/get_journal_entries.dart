import 'package:core/error/failures.dart';
import 'package:core/usecases/usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

import '../entities/journal_entry.dart';
import '../entities/trade_side.dart';
import '../repositories/journal_repository.dart';

/// Parameters for GetJournalEntries use case
class GetJournalEntriesParams {
  final String? symbol;
  final TradeSide? side;
  final DateTimeRange? range;
  final String? tag;
  final int? limit;

  GetJournalEntriesParams({
    this.symbol,
    this.side,
    this.range,
    this.tag,
    this.limit,
  });
}

/// Use case to get journal entries with optional filters
class GetJournalEntries
    implements UseCase<List<JournalEntry>, GetJournalEntriesParams> {
  final JournalRepository repository;

  GetJournalEntries(this.repository);

  @override
  Future<Either<Failure, List<JournalEntry>>> call(
      GetJournalEntriesParams params) async {
    // Validate limit if provided
    if (params.limit != null && params.limit! <= 0) {
      return Left(ValidationFailure('Limit must be positive'));
    }

    // Get entries from repository with filters
    return await repository.getEntries(
      symbol: params.symbol,
      side: params.side,
      range: params.range,
      tag: params.tag,
      limit: params.limit,
    );
  }
}
