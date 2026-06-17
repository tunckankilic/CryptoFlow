import 'package:equatable/equatable.dart';

abstract class PerformanceEvent extends Equatable {
  const PerformanceEvent();

  @override
  List<Object?> get props => [];
}

class PerformanceRequested extends PerformanceEvent {
  final String period;

  const PerformanceRequested(this.period);

  @override
  List<Object?> get props => [period];
}
