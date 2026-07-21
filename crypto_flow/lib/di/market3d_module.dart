import 'package:market/market.dart';
import 'package:market_3d/market_3d.dart';

import 'injection_container.dart';

/// Geometry for the "3D Market" tab's candlestick city.
///
/// Tighter than [SceneLayout.standard]: `LoadMarket3DCandles`'s default of
/// 100 candles at the standard block width (~85 scene units wide) would
/// overrun `ThermionMarketSceneRenderer`'s fixed 40x40 ground plane. This
/// layout keeps ~100 candles under ~36 units wide with room to spare.
final SceneLayout _market3DCityLayout = SceneLayout(
  blockWidth: 0.28,
  blockDepth: 0.28,
  spacing: 0.08,
  wickThicknessRatio: 0.22,
  sceneHeight: 9.0,
  minBodyHeight: 0.012,
  palette: ScenePalette.standard(),
);

/// Register "3D Market" tab dependencies.
Future<void> registerMarket3DModule() async {
  getIt.registerFactory<Market3DBloc>(
    () => Market3DBloc(
      getCandlesUseCase: getIt<GetCandlesUseCase>(),
      adapter: CandleSceneAdapter(layout: _market3DCityLayout),
    ),
  );
}
