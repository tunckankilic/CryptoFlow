import 'package:core/error/failures.dart';
import 'package:core/usecases/usecase.dart';
import 'package:dartz/dartz.dart';
import '../repositories/watchlist_repository.dart';

/// Parameters for AddToWatchlist use case
class AddToWatchlistParams {
  final String symbol;

  AddToWatchlistParams({required this.symbol});
}

/// Use case to add symbol to watchlist
class AddToWatchlist implements UseCase<void, AddToWatchlistParams> {
  final WatchlistRepository repository;

  AddToWatchlist(this.repository);

  @override
  Future<Either<Failure, void>> call(AddToWatchlistParams params) async {
    if (params.symbol.isEmpty) {
      return Left(ValidationFailure('Symbol cannot be empty'));
    }
    return await repository.addToWatchlist(params.symbol);
  }
}
