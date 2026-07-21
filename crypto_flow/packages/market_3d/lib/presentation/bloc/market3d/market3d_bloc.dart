import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:market/market.dart';

import '../../../domain/adapters/candle_scene_adapter.dart';
import 'market3d_event.dart';
import 'market3d_state.dart';

/// BLoC for the "3D Market" tab.
///
/// Mirrors `CandleBloc`'s load pattern: fetch history via a use case, emit
/// loading/loaded/error. Session 6 adds the live-stream subscription that
/// `CandleBloc` also has; this bloc only proves the load path for now.
class Market3DBloc extends Bloc<Market3DEvent, Market3DState> {
  final GetCandlesUseCase _getCandlesUseCase;
  final CandleSceneAdapter _adapter;

  Market3DBloc({
    required GetCandlesUseCase getCandlesUseCase,
    CandleSceneAdapter? adapter,
  })  : _getCandlesUseCase = getCandlesUseCase,
        _adapter = adapter ?? CandleSceneAdapter(),
        super(const Market3DInitial()) {
    on<LoadMarket3DCandles>(_onLoadCandles);
  }

  Future<void> _onLoadCandles(
    LoadMarket3DCandles event,
    Emitter<Market3DState> emit,
  ) async {
    emit(const Market3DLoading());

    final result = await _getCandlesUseCase(
      CandlesParams(
        symbol: event.symbol,
        interval: event.interval,
        limit: event.limit,
      ),
    );

    result.fold(
      (failure) => emit(Market3DError(failure.message)),
      (candles) {
        final scene = _adapter.buildScene(
          symbol: event.symbol,
          interval: event.interval,
          candles: candles,
        );
        emit(Market3DLoaded(
          symbol: event.symbol,
          interval: event.interval,
          candles: candles,
          scene: scene,
        ));
      },
    );
  }
}
