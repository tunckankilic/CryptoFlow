import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:core/core.dart';
import 'fear_greed_event.dart';
import 'fear_greed_state.dart';

/// BLoC for Fear & Greed Index
class FearGreedBloc extends Bloc<FearGreedEvent, FearGreedState> {
  final FearGreedDatasource _datasource;
  final WidgetDataService? _widgetDataService;

  FearGreedBloc(
    this._datasource, {
    WidgetDataService? widgetDataService,
  }) : _widgetDataService = widgetDataService,
       super(const FearGreedInitial()) {
    on<LoadFearGreedIndex>(_onLoad);
  }

  Future<void> _onLoad(
    LoadFearGreedIndex event,
    Emitter<FearGreedState> emit,
  ) async {
    emit(const FearGreedLoading());

    try {
      final index = await _datasource.getFearGreedIndex();
      emit(FearGreedLoaded(index));
      _widgetDataService?.updateFearGreedData(
        value: index.value,
        label: index.classification,
      );
    } on ServerException catch (e) {
      emit(FearGreedError(e.message));
    } catch (e) {
      emit(FearGreedError('Failed to load Fear & Greed Index'));
    }
  }
}
