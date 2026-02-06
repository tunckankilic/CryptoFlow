import 'package:equatable/equatable.dart';
import '../../../domain/entities/stats_period.dart';

/// Base class for all journal stats events
abstract class JournalStatsEvent extends Equatable {
  const JournalStatsEvent();

  @override
  List<Object?> get props => [];
}

/// Request trading statistics for a specific period
class JournalStatsRequested extends JournalStatsEvent {
  final StatsPeriod period;

  const JournalStatsRequested(this.period);

  @override
  List<Object?> get props => [period];
}

/// Request equity curve data
class JournalEquityCurveRequested extends JournalStatsEvent {
  /// Number of days to include (null for all time)
  final int? days;

  const JournalEquityCurveRequested({this.days});

  @override
  List<Object?> get props => [days];
}

/// Request emotion-based P&L analysis
class JournalEmotionAnalysisRequested extends JournalStatsEvent {
  /// Number of days to include (null for all time)
  final int? days;

  const JournalEmotionAnalysisRequested({this.days});

  @override
  List<Object?> get props => [days];
}

/// Request PDF report generation
class JournalReportRequested extends JournalStatsEvent {
  final StatsPeriod period;

  const JournalReportRequested(this.period);

  @override
  List<Object?> get props => [period];
}
