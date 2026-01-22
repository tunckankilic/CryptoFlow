import 'package:core/error/failures.dart';
import 'package:core/usecases/usecase.dart';
import 'package:dartz/dartz.dart';
import '../entities/watchlist_item.dart';
import '../repositories/watchlist_repository.dart';

/// Use case to get watchlist
class GetWatchlist implements UseCase<List<WatchlistItem>, NoParams> {
  final WatchlistRepository repository;

  GetWatchlist(this.repository);

  @override
  Future<Either<Failure, List<WatchlistItem>>> call(NoParams params) async {
    return await repository.getWatchlist();
  }
}
