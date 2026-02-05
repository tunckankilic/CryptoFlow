import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/trade_emotion.dart';
import '../../../domain/repositories/journal_repository.dart';
import '../../../domain/usecases/get_equity_curve.dart';
import '../../../domain/usecases/get_pnl_analysis.dart';
import '../../../domain/usecases/get_trading_stats.dart';
import 'journal_stats_event.dart';
import 'journal_stats_state.dart';

/// BLoC for managing journal statistics and analytics
class JournalStatsBloc extends Bloc<JournalStatsEvent, JournalStatsState> {
  final GetTradingStats getTradingStats;
  final GetEquityCurve getEquityCurve;
  final GetPnlAnalysis getPnlAnalysis;
  final JournalRepository repository;

  JournalStatsBloc({
    required this.getTradingStats,
    required this.getEquityCurve,
    required this.getPnlAnalysis,
    required this.repository,
  }) : super(const JournalStatsInitial()) {
    on<JournalStatsRequested>(_onStatsRequested);
    on<JournalEquityCurveRequested>(_onEquityCurveRequested);
    on<JournalEmotionAnalysisRequested>(_onEmotionAnalysisRequested);
  }

  /// Load trading statistics for a period
  Future<void> _onStatsRequested(
    JournalStatsRequested event,
    Emitter<JournalStatsState> emit,
  ) async {
    emit(const JournalStatsLoading());

    // Get trading stats
    final statsResult = await getTradingStats(
      GetTradingStatsParams(period: event.period),
    );

    await statsResult.fold(
      (failure) async {
        emit(JournalStatsError(failure.message));
      },
      (stats) async {
        // Get additional data in parallel
        final equityCurveResult = await getEquityCurve(
          GetEquityCurveParams(days: null),
        );
        final emotionPnlResult = await getPnlAnalysis(
          GetPnlAnalysisParams(type: PnlAnalysisType.byEmotion, days: null),
        );
        final symbolPnlResult = await getPnlAnalysis(
          GetPnlAnalysisParams(type: PnlAnalysisType.bySymbol, days: null),
        );
        final maxDrawdownResult = await repository.getMaxDrawdown(days: null);

        // Combine all results
        final equityCurve = equityCurveResult.fold(
          (failure) => <double>[],
          (curve) => curve,
        );

        final emotionPnl = emotionPnlResult.fold(
          (failure) => <TradeEmotion, double>{},
          (analysis) => analysis.map(
            (key, value) => MapEntry(key as TradeEmotion, value),
          ),
        );

        final symbolPnl = symbolPnlResult.fold(
          (failure) => <String, double>{},
          (analysis) => analysis.map(
            (key, value) => MapEntry(key as String, value),
          ),
        );

        final maxDrawdown = maxDrawdownResult.fold(
          (failure) => 0.0,
          (drawdown) => drawdown,
        );

        emit(JournalStatsLoaded(
          stats: stats,
          equityCurve: equityCurve,
          emotionPnl: emotionPnl,
          symbolPnl: symbolPnl,
          maxDrawdown: maxDrawdown,
        ));
      },
    );
  }

  /// Load equity curve data
  Future<void> _onEquityCurveRequested(
    JournalEquityCurveRequested event,
    Emitter<JournalStatsState> emit,
  ) async {
    if (state is! JournalStatsLoaded) {
      return;
    }

    final currentState = state as JournalStatsLoaded;

    final result = await getEquityCurve(
      GetEquityCurveParams(days: event.days),
    );

    result.fold(
      (failure) => emit(JournalStatsError(failure.message)),
      (equityCurve) {
        emit(currentState.copyWith(equityCurve: equityCurve));
      },
    );
  }

  /// Load emotion-based P&L analysis
  Future<void> _onEmotionAnalysisRequested(
    JournalEmotionAnalysisRequested event,
    Emitter<JournalStatsState> emit,
  ) async {
    if (state is! JournalStatsLoaded) {
      return;
    }

    final currentState = state as JournalStatsLoaded;

    final result = await getPnlAnalysis(
      GetPnlAnalysisParams(
        type: PnlAnalysisType.byEmotion,
        days: event.days,
      ),
    );

    result.fold(
      (failure) => emit(JournalStatsError(failure.message)),
      (analysis) {
        final emotionPnl = analysis.map(
          (key, value) => MapEntry(key as TradeEmotion, value),
        );
        emit(currentState.copyWith(emotionPnl: emotionPnl));
      },
    );
  }
}
