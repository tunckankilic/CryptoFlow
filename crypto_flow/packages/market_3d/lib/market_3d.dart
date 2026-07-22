/// 3D market scene layer for CryptoWave.
///
/// This package owns everything between market data and a 3D engine:
/// - plain scene models (positions, sizes, colours) with no engine types
/// - adapters turning `Candle` / `OrderBook` entities into those models
/// - the [MarketSceneRenderer] contract every engine backend implements
///
/// Engine-specific code lives under `data/renderers` and is the only place
/// allowed to import a rendering engine.
library;

// Domain layer - Scene models
export 'domain/models/camera_command.dart';
export 'domain/models/candle_block.dart';
export 'domain/models/depth_surface.dart';
export 'domain/models/market_scene.dart';
export 'domain/models/orbit_camera_state.dart';
export 'domain/models/price_scale.dart';
export 'domain/models/scene_color.dart';
export 'domain/models/scene_layout.dart';
export 'domain/models/scene_tap.dart';
export 'domain/models/vec3.dart';

// Domain layer - Renderer contract
export 'domain/renderer/market_scene_renderer.dart';

// Domain layer - Adapters
export 'domain/adapters/candle_scene_adapter.dart';
export 'domain/adapters/depth_scene_adapter.dart';

// Data layer - Engine backends (the only code here that imports an engine)
export 'data/renderers/thermion_market_scene_renderer.dart';

// Presentation layer - Bloc
export 'presentation/bloc/market3d/market3d_bloc.dart';
export 'presentation/bloc/market3d/market3d_event.dart';
export 'presentation/bloc/market3d/market3d_state.dart';

// Presentation layer - Pages
export 'presentation/pages/market3d_page.dart';
