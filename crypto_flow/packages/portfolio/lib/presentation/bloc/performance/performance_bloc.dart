import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/analytics_remote_datasource.dart';
import 'performance_event.dart';
import 'performance_state.dart';

class PerformanceBloc extends Bloc<PerformanceEvent, PerformanceState> {
  final AnalyticsRemoteDataSource _analyticsDataSource;

  PerformanceBloc({
    required AnalyticsRemoteDataSource analyticsDataSource,
  })  : _analyticsDataSource = analyticsDataSource,
        super(const PerformanceInitial()) {
    on<PerformanceRequested>(_onRequested);
  }

  Future<void> _onRequested(
    PerformanceRequested event,
    Emitter<PerformanceState> emit,
  ) async {
    emit(const PerformanceLoading());
    try {
      final model = await _analyticsDataSource.getPerformanceAnalytics(
        period: event.period,
      );
      emit(PerformanceLoaded(model.toEntity()));
    } catch (e) {
      emit(PerformanceError(e.toString()));
    }
  }
}
