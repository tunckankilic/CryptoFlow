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

/// Geometry for the order book depth terrain drawn in front of the city.
///
/// Tuned against the city the same way [_market3DCityLayout] is, and for the
/// same reason: [DepthLayout.standard] is the adapter's unit-test baseline,
/// not a composition.
///
/// The terrain sits several units nearer the camera than the city (see
/// `ThermionMarketSceneRenderer`'s terrain z offset), so perspective already
/// makes it read larger than its measurements suggest. Sized to roughly a
/// quarter of the ~36-unit-wide, 9-unit-tall city it stands in front of: big
/// enough to read as a second instrument, small enough not to occlude the
/// candles behind it.
final DepthLayout _market3DDepthLayout = DepthLayout(
  sideWidth: 4.5,
  sideDepth: 2.0,
  maxHeight: 2.2,
  spreadGap: 0.5,
  bidColor: ScenePalette.standard().bullish,
  askColor: ScenePalette.standard().bearish,
);

/// Register "3D Market" tab dependencies.
Future<void> registerMarket3DModule() async {
  getIt.registerFactory<Market3DBloc>(
    () => Market3DBloc(
      getCandlesUseCase: getIt<GetCandlesUseCase>(),
      getCandleStreamUseCase: getIt<GetCandleStreamUseCase>(),
      getOrderBookUseCase: getIt<GetOrderBookUseCase>(),
      adapter: CandleSceneAdapter(layout: _market3DCityLayout),
      depthAdapter: DepthSceneAdapter(layout: _market3DDepthLayout),
    ),
  );
}
