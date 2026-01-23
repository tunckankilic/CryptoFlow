import 'package:core/error/failures.dart';
import 'package:core/usecases/usecase.dart';
import 'package:dartz/dartz.dart';
import '../entities/watchlist_item.dart';
import '../repositories/watchlist_repository.dart';

/// Parameters for ReorderWatchlist use case
class ReorderWatchlistParams {
  final List<WatchlistItem> items;

  ReorderWatchlistParams({required this.items});
}

/// Use case to reorder watchlist items
class ReorderWatchlist implements UseCase<void, ReorderWatchlistParams> {
  final WatchlistRepository repository;

  ReorderWatchlist(this.repository);

  @override
  Future<Either<Failure, void>> call(ReorderWatchlistParams params) async {
    return await repository.reorderWatchlist(params.items);
  }
}
