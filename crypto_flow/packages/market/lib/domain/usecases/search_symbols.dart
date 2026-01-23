import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:core/error/failures.dart';
import 'package:core/usecases/usecase.dart';
import '../entities/ticker.dart';
import '../repositories/market_repository.dart';

/// Use case to search for trading pairs by query
class SearchSymbolsUseCase implements UseCase<List<Ticker>, SearchParams> {
  final MarketRepository repository;

  SearchSymbolsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Ticker>>> call(SearchParams params) {
    return repository.searchSymbols(params.query);
  }
}

/// Parameters for symbol search
class SearchParams extends Equatable {
  /// Search query (matches symbol or asset names)
  final String query;

  /// Optional filter for quote asset (e.g., "USDT", "BTC")
  final String? quoteAsset;

  /// Maximum number of results to return
  final int limit;

  const SearchParams({
    required this.query,
    this.quoteAsset,
    this.limit = 50,
  });

  @override
  List<Object?> get props => [query, quoteAsset, limit];
}
