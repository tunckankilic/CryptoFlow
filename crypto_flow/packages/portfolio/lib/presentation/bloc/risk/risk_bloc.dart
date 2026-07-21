import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/risk_remote_datasource.dart';
import '../../../domain/entities/risk_metrics.dart';

// ── Events ──────────────────────────────────────────────────────────────────

abstract class RiskEvent extends Equatable {
  const RiskEvent();
  @override
  List<Object?> get props => [];
}

class PositionSizeRequested extends RiskEvent {
  final String symbol;
  final double accountSize;
  final double riskPercentage;
  final double entryPrice;
  final double stopLossPrice;

  const PositionSizeRequested({
    required this.symbol,
    required this.accountSize,
    required this.riskPercentage,
    required this.entryPrice,
    required this.stopLossPrice,
  });

  @override
  List<Object?> get props =>
      [symbol, accountSize, riskPercentage, entryPrice, stopLossPrice];
}

class CorrelationRequested extends RiskEvent {
  final String period;
  const CorrelationRequested({this.period = 'monthly'});
  @override
  List<Object?> get props => [period];
}

class VaRRequested extends RiskEvent {
  final double confidence;
  final int holdingPeriodDays;
  const VaRRequested({this.confidence = 95, this.holdingPeriodDays = 1});
  @override
  List<Object?> get props => [confidence, holdingPeriodDays];
}

// ── States ──────────────────────────────────────────────────────────────────

abstract class RiskState extends Equatable {
  const RiskState();
  @override
  List<Object?> get props => [];
}

class RiskInitial extends RiskState {
  const RiskInitial();
}

class RiskLoading extends RiskState {
  const RiskLoading();
}

class PositionSizeLoaded extends RiskState {
  final PositionSizeResult result;
  const PositionSizeLoaded(this.result);
  @override
  List<Object?> get props => [result];
}

class CorrelationLoaded extends RiskState {
  final CorrelationMatrix matrix;
  const CorrelationLoaded(this.matrix);
  @override
  List<Object?> get props => [matrix];
}

class VaRLoaded extends RiskState {
  final VaRResult result;
  const VaRLoaded(this.result);
  @override
  List<Object?> get props => [result];
}

class RiskError extends RiskState {
  final String message;
  const RiskError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── BLoC ────────────────────────────────────────────────────────────────────

class RiskBloc extends Bloc<RiskEvent, RiskState> {
  final RiskRemoteDataSource _dataSource;

  RiskBloc({required RiskRemoteDataSource dataSource})
      : _dataSource = dataSource,
        super(const RiskInitial()) {
    on<PositionSizeRequested>(_onPositionSize);
    on<CorrelationRequested>(_onCorrelation);
    on<VaRRequested>(_onVaR);
  }

  Future<void> _onPositionSize(
    PositionSizeRequested event,
    Emitter<RiskState> emit,
  ) async {
    emit(const RiskLoading());
    try {
      final model = await _dataSource.getPositionSize(
        symbol: event.symbol,
        accountSize: event.accountSize,
        riskPercentage: event.riskPercentage,
        entryPrice: event.entryPrice,
        stopLossPrice: event.stopLossPrice,
      );
      emit(PositionSizeLoaded(model.toEntity()));
    } catch (e) {
      emit(RiskError(e.toString()));
    }
  }

  Future<void> _onCorrelation(
    CorrelationRequested event,
    Emitter<RiskState> emit,
  ) async {
    emit(const RiskLoading());
    try {
      final model = await _dataSource.getCorrelation(period: event.period);
      emit(CorrelationLoaded(model.toEntity()));
    } catch (e) {
      emit(RiskError(e.toString()));
    }
  }

  Future<void> _onVaR(
    VaRRequested event,
    Emitter<RiskState> emit,
  ) async {
    emit(const RiskLoading());
    try {
      final model = await _dataSource.getVaR(
        confidence: event.confidence,
        holdingPeriodDays: event.holdingPeriodDays,
      );
      emit(VaRLoaded(model.toEntity()));
    } catch (e) {
      emit(RiskError(e.toString()));
    }
  }
}
