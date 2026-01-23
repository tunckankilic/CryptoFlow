import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:core/services/cloud_sync_service.dart';
import '../../domain/usecases/add_transaction.dart';
import '../../domain/usecases/get_holdings.dart';
import '../../domain/usecases/get_portfolio_value.dart';
import '../../domain/entities/portfolio_summary.dart';
import '../../domain/repositories/portfolio_repository.dart';
import 'package:core/usecases/usecase.dart';
import 'portfolio_event.dart';
import 'portfolio_state.dart';

/// BLoC for managing portfolio state
class PortfolioBloc extends Bloc<PortfolioEvent, PortfolioState> {
  final GetHoldings getHoldings;
  final AddTransaction addTransaction;
  final GetPortfolioValue getPortfolioValue;
  final PortfolioRepository repository;
  final CloudSyncService? cloudSyncService;
  final String? userId;

  StreamSubscription? _holdingsSubscription;
  StreamSubscription? _priceSubscription;
  Map<String, double> _currentPrices = {};

  PortfolioBloc({
    required this.getHoldings,
    required this.addTransaction,
    required this.getPortfolioValue,
    required this.repository,
    this.cloudSyncService,
    this.userId,
  }) : super(const PortfolioInitial()) {
    on<LoadPortfolio>(_onLoadPortfolio);
    on<AddTransactionEvent>(_onAddTransaction);
    on<DeleteTransactionEvent>(_onDeleteTransaction);
    on<WatchPortfolioValue>(_onWatchPortfolioValue);
    on<UpdatePrices>(_onUpdatePrices);
    on<RefreshPrices>(_onRefreshPrices);
    on<HoldingsUpdated>(_onHoldingsUpdated);
  }

  /// Load initial portfolio data
  Future<void> _onLoadPortfolio(
    LoadPortfolio event,
    Emitter<PortfolioState> emit,
  ) async {
    emit(const PortfolioLoading());

    // Get holdings
    final holdingsResult = await getHoldings(NoParams());

    await holdingsResult.fold(
      (failure) async {
        emit(PortfolioError(message: failure.message));
      },
      (holdings) async {
        // Get transactions
        final transactionsResult = await repository.getTransactions();

        transactionsResult.fold(
          (failure) {
            emit(PortfolioError(message: failure.message));
          },
          (transactions) {
            // For initial load, emit with empty prices
            // Prices will be updated by market integration
            emit(PortfolioLoaded(
              summary: PortfolioSummary.empty(),
              holdings: holdings,
              transactions: transactions,
              currentPrices: {},
            ));

            // Start watching for updates
            add(const WatchPortfolioValue());
          },
        );
      },
    );
  }

  /// Add a new transaction
  Future<void> _onAddTransaction(
    AddTransactionEvent event,
    Emitter<PortfolioState> emit,
  ) async {
    final result = await addTransaction(
      AddTransactionParams(transaction: event.transaction),
    );

    result.fold(
      (failure) {
        emit(PortfolioError(message: failure.message));
      },
      (_) {
        // Reload portfolio after adding transaction
        add(const LoadPortfolio());
        // Auto-sync to cloud if available
        _syncToCloud();
      },
    );
  }

  /// Delete a transaction
  Future<void> _onDeleteTransaction(
    DeleteTransactionEvent event,
    Emitter<PortfolioState> emit,
  ) async {
    final result = await repository.deleteTransaction(event.transactionId);

    result.fold(
      (failure) {
        emit(PortfolioError(message: failure.message));
      },
      (_) {
        // Reload portfolio after deleting transaction
        add(const LoadPortfolio());
        // Auto-sync to cloud if available
        _syncToCloud();
      },
    );
  }

  /// Watch for portfolio value updates
  Future<void> _onWatchPortfolioValue(
    WatchPortfolioValue event,
    Emitter<PortfolioState> emit,
  ) async {
    await _holdingsSubscription?.cancel();

    // Watch holdings changes
    _holdingsSubscription = repository.watchHoldings().listen(
      (_) {
        add(const HoldingsUpdated());
      },
    );
  }

  /// Handle holdings updates
  Future<void> _onHoldingsUpdated(
    HoldingsUpdated event,
    Emitter<PortfolioState> emit,
  ) async {
    // Get updated holdings
    final holdingsResult = await getHoldings(NoParams());

    holdingsResult.fold(
      (failure) {
        emit(PortfolioError(message: failure.message));
      },
      (holdings) async {
        // Get transactions
        final transactionsResult = await repository.getTransactions();

        transactionsResult.fold(
          (failure) {
            emit(PortfolioError(message: failure.message));
          },
          (transactions) async {
            // Calculate portfolio value with current prices
            if (_currentPrices.isNotEmpty) {
              final summaryResult = await getPortfolioValue(
                GetPortfolioValueParams(
                  currentPrices: _currentPrices,
                  btcPrice: _currentPrices['BTCUSDT'],
                ),
              );

              summaryResult.fold(
                (failure) {
                  emit(PortfolioError(message: failure.message));
                },
                (summary) {
                  emit(PortfolioLoaded(
                    summary: summary,
                    holdings: holdings,
                    transactions: transactions,
                    currentPrices: _currentPrices,
                  ));
                },
              );
            } else {
              emit(PortfolioLoaded(
                summary: PortfolioSummary.empty(),
                holdings: holdings,
                transactions: transactions,
                currentPrices: {},
              ));
            }
          },
        );
      },
    );
  }

  /// Update with new market prices
  Future<void> _onUpdatePrices(
    UpdatePrices event,
    Emitter<PortfolioState> emit,
  ) async {
    _currentPrices = event.prices;

    if (state is PortfolioLoaded) {
      final currentState = state as PortfolioLoaded;

      // Recalculate portfolio value with new prices
      final summaryResult = await getPortfolioValue(
        GetPortfolioValueParams(
          currentPrices: _currentPrices,
          btcPrice: _currentPrices['BTCUSDT'],
        ),
      );

      summaryResult.fold(
        (failure) {
          emit(PortfolioError(message: failure.message));
        },
        (summary) {
          emit(currentState.copyWith(
            summary: summary,
            currentPrices: _currentPrices,
          ));
        },
      );
    }
  }

  /// Refresh prices from market
  Future<void> _onRefreshPrices(
    RefreshPrices event,
    Emitter<PortfolioState> emit,
  ) async {
    // This would trigger market package to fetch fresh prices
    // For now, we'll just recalculate with existing prices
    if (state is PortfolioLoaded && _currentPrices.isNotEmpty) {
      add(UpdatePrices(_currentPrices));
    }
  }

  @override
  Future<void> close() {
    _holdingsSubscription?.cancel();
    _priceSubscription?.cancel();
    return super.close();
  }

  /// Sync portfolio to cloud if service is available
  Future<void> _syncToCloud() async {
    if (cloudSyncService == null || userId == null) return;
    if (state is! PortfolioLoaded) return;

    final loaded = state as PortfolioLoaded;
    final holdingsJson = loaded.holdings
        .map((h) => {
              'symbol': h.symbol,
              'baseAsset': h.baseAsset,
              'quantity': h.quantity,
              'avgBuyPrice': h.avgBuyPrice,
              'firstBuyDate': h.firstBuyDate.toIso8601String(),
            })
        .toList();

    await cloudSyncService!.syncPortfolio(
      userId: userId!,
      holdings: holdingsJson,
    );
  }
}
