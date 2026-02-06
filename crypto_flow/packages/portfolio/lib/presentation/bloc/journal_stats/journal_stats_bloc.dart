import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/services/pdf_report_service.dart';
import '../../../domain/entities/stats_period.dart';
import '../../../domain/entities/trade_emotion.dart';
import '../../../domain/repositories/journal_repository.dart';
import '../../../domain/usecases/get_equity_curve.dart';
import '../../../domain/usecases/get_journal_entries.dart';
import '../../../domain/usecases/get_pnl_analysis.dart';
import '../../../domain/usecases/get_trading_stats.dart';
import 'journal_stats_event.dart';
import 'journal_stats_state.dart';

/// BLoC for managing journal statistics and analytics
class JournalStatsBloc extends Bloc<JournalStatsEvent, JournalStatsState> {
  final GetTradingStats getTradingStats;
  final GetEquityCurve getEquityCurve;
  final GetPnlAnalysis getPnlAnalysis;
  final GetJournalEntries getJournalEntries;
  final JournalRepository repository;
  final PdfReportService pdfReportService;

  JournalStatsBloc({
    required this.getTradingStats,
    required this.getEquityCurve,
    required this.getPnlAnalysis,
    required this.getJournalEntries,
    required this.repository,
    required this.pdfReportService,
  }) : super(const JournalStatsInitial()) {
    on<JournalStatsRequested>(_onStatsRequested);
    on<JournalEquityCurveRequested>(_onEquityCurveRequested);
    on<JournalEmotionAnalysisRequested>(_onEmotionAnalysisRequested);
    on<JournalReportRequested>(_onReportRequested);
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

  /// Generate PDF report
  Future<void> _onReportRequested(
    JournalReportRequested event,
    Emitter<JournalStatsState> emit,
  ) async {
    emit(const JournalReportGenerating());

    try {
      // Calculate date range for the period
      final now = DateTime.now();
      DateTime? startDate;

      switch (event.period) {
        case StatsPeriod.daily:
          startDate = now.subtract(const Duration(days: 1));
          break;
        case StatsPeriod.weekly:
          startDate = now.subtract(const Duration(days: 7));
          break;
        case StatsPeriod.monthly:
          startDate = now.subtract(const Duration(days: 30));
          break;
        case StatsPeriod.allTime:
          startDate = null;
          break;
      }

      // Get all required data for the report
      final entriesResult = await getJournalEntries(
        GetJournalEntriesParams(
          range: startDate != null
              ? DateTimeRange(start: startDate, end: now)
              : null,
        ),
      );

      final statsResult = await getTradingStats(
        GetTradingStatsParams(period: event.period),
      );

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

      // Check if we have all the required data
      final entries = entriesResult.fold(
        (failure) => throw Exception(failure.message),
        (entries) => entries,
      );

      final stats = statsResult.fold(
        (failure) => throw Exception(failure.message),
        (stats) => stats,
      );

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

      // Generate the PDF
      final pdfBytes = await pdfReportService.generateTradingReport(
        period: event.period,
        entries: entries,
        stats: stats,
        emotionPnl: emotionPnl,
        symbolPnl: symbolPnl,
        equityCurve: equityCurve,
        maxDrawdown: maxDrawdown,
      );

      emit(JournalReportGenerated(pdfBytes));
    } catch (e) {
      emit(JournalReportError('Failed to generate report: ${e.toString()}'));
    }
  }
}
