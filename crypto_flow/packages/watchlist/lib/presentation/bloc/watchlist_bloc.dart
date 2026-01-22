import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watchlist/domain/entities/watchlist_item.dart';
import '../../domain/usecases/get_watchlist.dart';
import '../../domain/usecases/add_to_watchlist.dart';
import '../../domain/usecases/remove_from_watchlist.dart';
import '../../domain/usecases/reorder_watchlist.dart';
import '../../domain/repositories/watchlist_repository.dart';
import 'package:core/usecases/usecase.dart';
import 'watchlist_event.dart';
import 'watchlist_state.dart';

/// BLoC for managing watchlist state
class WatchlistBloc extends Bloc<WatchlistEvent, WatchlistState> {
  final GetWatchlist getWatchlist;
  final AddToWatchlist addToWatchlist;
  final RemoveFromWatchlist removeFromWatchlist;
  final ReorderWatchlist reorderWatchlist;
  final WatchlistRepository repository;

  StreamSubscription? _watchlistSubscription;

  WatchlistBloc({
    required this.getWatchlist,
    required this.addToWatchlist,
    required this.removeFromWatchlist,
    required this.reorderWatchlist,
    required this.repository,
  }) : super(const WatchlistInitial()) {
    on<LoadWatchlist>(_onLoadWatchlist);
    on<AddToWatchlistEvent>(_onAddToWatchlist);
    on<RemoveFromWatchlistEvent>(_onRemoveFromWatchlist);
    on<ReorderWatchlistEvent>(_onReorderWatchlist);
    on<WatchlistUpdated>(_onWatchlistUpdated);
  }

  /// Load watchlist
  Future<void> _onLoadWatchlist(
    LoadWatchlist event,
    Emitter<WatchlistState> emit,
  ) async {
    emit(const WatchlistLoading());

    final result = await getWatchlist(NoParams());

    result.fold(
      (failure) => emit(WatchlistError(message: failure.message)),
      (items) {
        emit(_buildLoadedState(items));

        // Start watching for updates
        _watchlistSubscription?.cancel();
        _watchlistSubscription = repository.watchWatchlist().listen((_) {
          add(const WatchlistUpdated());
        });
      },
    );
  }

  /// Add to watchlist
  Future<void> _onAddToWatchlist(
    AddToWatchlistEvent event,
    Emitter<WatchlistState> emit,
  ) async {
    final result = await addToWatchlist(
      AddToWatchlistParams(symbol: event.symbol),
    );

    result.fold(
      (failure) => emit(WatchlistError(message: failure.message)),
      (_) => add(const LoadWatchlist()),
    );
  }

  /// Remove from watchlist
  Future<void> _onRemoveFromWatchlist(
    RemoveFromWatchlistEvent event,
    Emitter<WatchlistState> emit,
  ) async {
    final result = await removeFromWatchlist(
      RemoveFromWatchlistParams(symbol: event.symbol),
    );

    result.fold(
      (failure) => emit(WatchlistError(message: failure.message)),
      (_) => add(const LoadWatchlist()),
    );
  }

  /// Reorder watchlist
  Future<void> _onReorderWatchlist(
    ReorderWatchlistEvent event,
    Emitter<WatchlistState> emit,
  ) async {
    final result = await reorderWatchlist(
      ReorderWatchlistParams(items: event.items),
    );

    result.fold(
      (failure) => emit(WatchlistError(message: failure.message)),
      (_) {
        // Optimistically update UI
        if (state is WatchlistLoaded) {
          final current = state as WatchlistLoaded;
          emit(current.copyWith(items: event.items));
        }
      },
    );
  }

  /// Handle watchlist updates
  Future<void> _onWatchlistUpdated(
    WatchlistUpdated event,
    Emitter<WatchlistState> emit,
  ) async {
    final result = await getWatchlist(NoParams());

    result.fold(
      (failure) => emit(WatchlistError(message: failure.message)),
      (items) => emit(_buildLoadedState(items)),
    );
  }

  /// Build loaded state with cache
  WatchlistLoaded _buildLoadedState(List<dynamic> items) {
    final typedItems = items.cast();
    final cache = <String, bool>{};
    for (final item in typedItems) {
      cache[item.symbol] = true;
    }

    return WatchlistLoaded(
      items: typedItems as List<WatchlistItem>,
      inWatchlistCache: cache,
    );
  }

  @override
  Future<void> close() {
    _watchlistSubscription?.cancel();
    return super.close();
  }
}
