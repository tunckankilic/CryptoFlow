import 'package:core/error/failures.dart';
import 'package:core/usecases/usecase.dart';
import 'package:dartz/dartz.dart';

import '../repositories/journal_repository.dart';

/// Type of P&L analysis to perform
enum PnlAnalysisType {
  /// P&L grouped by trading symbol
  bySymbol,

  /// P&L grouped by emotional state
  byEmotion,
}

/// Parameters for GetPnlAnalysis use case
class GetPnlAnalysisParams {
  final PnlAnalysisType type;
  final int? days;

  GetPnlAnalysisParams({
    required this.type,
    this.days,
  });
}

/// Use case to get P&L analysis
/// Can analyze by symbol or by emotion
class GetPnlAnalysis
    implements UseCase<Map<dynamic, double>, GetPnlAnalysisParams> {
  final JournalRepository repository;

  GetPnlAnalysis(this.repository);

  @override
  Future<Either<Failure, Map<dynamic, double>>> call(
      GetPnlAnalysisParams params) async {
    // Validate days if provided
    if (params.days != null && params.days! <= 0) {
      return Left(ValidationFailure('Days must be positive'));
    }

    // Get analysis based on type
    switch (params.type) {
      case PnlAnalysisType.bySymbol:
        return await repository.getPnlBySymbol(days: params.days);

      case PnlAnalysisType.byEmotion:
        final result = await repository.getPnlByEmotion(days: params.days);
        // Convert Map<TradeEmotion, double> to Map<dynamic, double>
        return result.fold(
          (failure) => Left(failure),
          (emotionMap) => Right(emotionMap.map(
            (key, value) => MapEntry(key as dynamic, value),
          )),
        );
    }
  }
}
