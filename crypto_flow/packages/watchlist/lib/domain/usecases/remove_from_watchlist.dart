import 'package:core/error/failures.dart';
import 'package:core/usecases/usecase.dart';
import 'package:dartz/dartz.dart';
import '../repositories/watchlist_repository.dart';

/// Parameters for RemoveFromWatchlist use case
class RemoveFromWatchlistParams {
  final String symbol;

  RemoveFromWatchlistParams({required this.symbol});
}

/// Use case to remove symbol from watchlist
class RemoveFromWatchlist implements UseCase<void, RemoveFromWatchlistParams> {
  final WatchlistRepository repository;

  RemoveFromWatchlist(this.repository);

  @override
  Future<Either<Failure, void>> call(RemoveFromWatchlistParams params) async {
    return await repository.removeFromWatchlist(params.symbol);
  }
}
