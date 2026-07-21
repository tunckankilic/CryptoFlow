import '../models/camera_command.dart';
import '../models/candle_block.dart';
import '../models/depth_surface.dart';
import '../models/market_scene.dart';
import '../models/scene_tap.dart';

/// The contract every 3D backend implements.
///
/// This is the only seam between market data and a rendering engine. Nothing
/// above this interface may import an engine package, and nothing below it may
/// import market entities directly — implementations consume the plain scene
/// models in `domain/models`.
///
/// Implementations planned: `ThermionMarketSceneRenderer` (session 2), and a
/// `FluoriteMarketSceneRenderer` if and when Fluorite opens up. Swapping
/// engines means writing one new implementation of this interface; the data,
/// adapter and presentation layers are untouched.
abstract class MarketSceneRenderer {
  /// Whether [initialize] has completed and the renderer accepts scene calls.
  bool get isInitialized;

  /// Taps on the scene, including misses so the UI can dismiss overlays.
  Stream<SceneTap> get taps;

  /// Prepares the engine, viewport, lighting and ground plane.
  ///
  /// Must complete before any other method is called.
  Future<void> initialize();

  /// Replaces the entire candle city.
  ///
  /// Expensive: call on first load, on symbol or interval change, and when
  /// [MarketScene.needsRescaleFor] reports that the live candle has escaped
  /// the current price scale. Steady-state live updates use [updateLiveBlock].
  Future<void> setScene(MarketScene scene);

  /// Updates or appends a single block without rebuilding the scene.
  ///
  /// The block's `index` identifies which geometry to move: an existing index
  /// mutates that candle in place, an index one past the end appends the newly
  /// opened candle.
  Future<void> updateLiveBlock(CandleBlock block);

  /// Highlights the block at [index], or clears the highlight when `null`.
  Future<void> setSelectedBlock(int? index);

  /// Replaces the order book depth terrain.
  Future<void> setDepthSurface(DepthSurface surface);

  /// Removes the depth terrain from the scene.
  Future<void> clearDepthSurface();

  /// Applies a camera instruction.
  Future<void> applyCamera(CameraCommand command);

  /// Releases engine resources and closes [taps].
  Future<void> dispose();
}
