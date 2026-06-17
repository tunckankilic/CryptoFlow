import 'package:equatable/equatable.dart';
import '../../../domain/entities/performance_metrics.dart';

abstract class PerformanceState extends Equatable {
  const PerformanceState();

  @override
  List<Object?> get props => [];
}

class PerformanceInitial extends PerformanceState {
  const PerformanceInitial();
}

class PerformanceLoading extends PerformanceState {
  const PerformanceLoading();
}

class PerformanceLoaded extends PerformanceState {
  final PerformanceMetrics metrics;

  const PerformanceLoaded(this.metrics);

  @override
  List<Object?> get props => [metrics];
}

class PerformanceError extends PerformanceState {
  final String message;

  const PerformanceError(this.message);

  @override
  List<Object?> get props => [message];
}
