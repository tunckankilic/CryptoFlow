import 'package:core/error/failures.dart';
import 'package:core/usecases/usecase.dart';
import 'package:dartz/dartz.dart';
import '../repositories/watchlist_repository.dart';

/// Parameters for IsInWatchlist use case
class IsInWatchlistParams {
  final String symbol;

  IsInWatchlistParams({required this.symbol});
}

/// Use case to check if symbol is in watchlist
class IsInWatchlist implements UseCase<bool, IsInWatchlistParams> {
  final WatchlistRepository repository;

  IsInWatchlist(this.repository);

  @override
  Future<Either<Failure, bool>> call(IsInWatchlistParams params) async {
    return await repository.isInWatchlist(params.symbol);
  }
}
