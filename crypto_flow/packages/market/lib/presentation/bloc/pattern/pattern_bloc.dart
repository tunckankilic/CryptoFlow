import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/pattern_remote_datasource.dart';
import '../../../domain/entities/chart_pattern.dart';

// Events
abstract class PatternEvent extends Equatable {
  const PatternEvent();

  @override
  List<Object?> get props => [];
}

class PatternRequested extends PatternEvent {
  final String symbol;
  const PatternRequested(this.symbol);

  @override
  List<Object?> get props => [symbol];
}

// States
abstract class PatternState extends Equatable {
  const PatternState();

  @override
  List<Object?> get props => [];
}

class PatternInitial extends PatternState {
  const PatternInitial();
}

class PatternLoading extends PatternState {
  const PatternLoading();
}

class PatternLoaded extends PatternState {
  final List<ChartPattern> patterns;
  const PatternLoaded(this.patterns);

  @override
  List<Object?> get props => [patterns];
}

class PatternError extends PatternState {
  final String message;
  const PatternError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class PatternBloc extends Bloc<PatternEvent, PatternState> {
  final PatternRemoteDataSource _dataSource;

  PatternBloc({required PatternRemoteDataSource dataSource})
      : _dataSource = dataSource,
        super(const PatternInitial()) {
    on<PatternRequested>(_onRequested);
  }

  Future<void> _onRequested(
    PatternRequested event,
    Emitter<PatternState> emit,
  ) async {
    emit(const PatternLoading());
    try {
      final models = await _dataSource.getPatterns(event.symbol);
      emit(PatternLoaded(models.map((m) => m.toEntity()).toList()));
    } catch (e) {
      emit(PatternError(e.toString()));
    }
  }
}
