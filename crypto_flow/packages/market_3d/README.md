# market_3d

3D market scene layer for Crypto Wave: the candlestick city and the order book
depth terrain, behind an engine-agnostic renderer contract.

The data layer is plain Dart. Scene models (`domain/models`) and the adapters
that compute them from `Candle` / `OrderBook` entities never import an engine;
only `data/renderers/**` and `data/spike/**` do. Swapping the engine means
writing one new implementation of `MarketSceneRenderer` and nothing else.

## Geometry technique

**Decision: raw vertex data, one merged mesh per candle, placed by a
translation-only transform.** Body and wick are written into a single vertex
buffer (`data/renderers/candle_mesh.dart`) with their true extents baked in.

Why, over the alternative of scaling a shared unit cube per box:

- **One entity per candle instead of two.** A candle is two boxes; merging them
  halves the entity and draw-call count across the city.
- **No hidden factor of two.** `GeometryUtils.cube` spans `-1..1`, so scaling it
  by `size` yields a box of `2 × size`. The transform approach has to remember
  to halve at every call site; baked vertices carry the real dimensions and a
  test asserts them.
- **The transform stays a pure translation**, which is what keeps a block
  independent of its neighbours — appending or replacing one candle never moves
  the others.

The cost is that changing a candle's *shape* means rebuilding its buffer rather
than editing a matrix. That is fine for history, which is static.

Measured on a physical iPhone (iPhone14,5, iOS 27) with the render loop live: one
build + destroy cycle costs **0.94–1.21 ms**, stable across repeated runs of
100 cycles, so nothing leaks. At that rate a 200-candle city rebuilds in
roughly 200 ms — fine for a one-off rescale, far too slow to do on every
market tick. The live block therefore has to be updated in place rather than
rebuilt (session 6); if editing its vertices proves awkward, the live candle
alone can fall back to a unit-cube body scaled by transform while history
stays merged.

## Depth terrain update strategy (session 10)

**Decision: rebuild both ribbons from scratch on every order book update.**
No attempt at mutable vertices, and no per-level entities.

The alternative was ruled out before it was measured. Thermion 0.4.1 exposes
no way to rewrite an existing asset's vertex buffer: `ThermionAsset` offers
only `setMorphTargetWeights` and `setMorphAnimationData`, both of which drive
pre-authored morph targets, not arbitrary geometry. "Mutable vertices" is not
an option this engine has, so the only real question was whether re-meshing is
cheap enough — and, if it isn't, whether the terrain needs throttling.

Why the terrain gets away with a strategy the candle city could not:

- **Two assets, not forty.** A whole side of the book is one colour, so
  `DepthMesh.buildSide` merges all its levels into a single vertex buffer.
  The entire terrain is two assets — bid ribbon, ask ribbon — against the
  city's one asset per candle. The city's ~1 ms per-candle build+destroy cost
  (see above) is what makes a 200-candle rebuild a ~200 ms non-starter; the
  same per-asset cost over two assets is not.
- **Every level moves anyway.** A candle tick changes one block, which is why
  session 6 could take an O(1) `updateLiveBlock` path. An order book update
  shifts the cumulative curve from the mid price outward, so most of the
  surface changes at once — a partial-update path would rebuild nearly
  everything regardless, at the cost of a diffing pass and per-level entities.

Measured on the iOS Simulator (iPhone 17 Pro, arm64, **debug** build) with the
render loop live and the 100-candle city rendered, 60 consecutive
whole-terrain re-mesh cycles per run (20 bid + 20 ask levels), timed around
`setDepthSurface` end to end — build both meshes, create both assets, destroy
the previous two:

| Run | Min | Median | Mean | Max |
|---|---|---|---|---|
| 1 | 1.35 ms | 2.47 ms | 2.79 ms | 10.9 ms |
| 2 | 0.87 ms | 1.48 ms | 2.00 ms | 15.2 ms |
| 3 | 0.89 ms | 2.76 ms | 4.37 ms | 50.2 ms |
| 4 | 1.24 ms | 2.04 ms | 2.54 ms | 17.7 ms |

**Median 1.5–2.8 ms per whole-terrain rebuild**, against a 16.7 ms frame
budget. The maxima are outliers in a debug build under an unthrottled loop
(the 50 ms one was a single cycle in run 3, with the rest of that run's
distribution unchanged) — they scale with allocation pressure, not with the
mesh, and none of them repeated. Two assets rebuild at roughly the cost
session 3 measured for two candles, which is exactly what the merged-per-side
design predicts.

Caveats, stated rather than glossed: this is the **simulator in debug mode**,
not a `--profile` build on the phone — session 3's ~1 ms per-candle figure was
a device measurement and is the more trustworthy of the two. Treat these
numbers as an order-of-magnitude answer to "is re-meshing viable", which they
settle comfortably, not as a frame-budget guarantee. The device confirmation
is still open (see HANDOFF.md).

Consequence for session 11 (live depth): **no throttling needed, and the
assumption that it would be was wrong.** The order book stream this app
already subscribes to is `BinanceEndpoints.depthStream`, which builds
`/ws/<symbol>@depth20` — no `@100ms` speed suffix, so it uses Binance's
default 1000 ms cadence, the same rate as the kline stream session 8 found
comfortably under budget. One ~2 ms rebuild per second is not a frame-budget
problem. If a future session ever switches to the 100 ms variant, that is
ten rebuilds a second and the arithmetic is worth redoing — but nothing in
the current data path pushes faster than 1 Hz.

## Performance pass (session 8): already at target, no changes made

**Measured on a physical iPhone (iPhone14,5, iOS 27), `flutter run --profile`,
DevTools Performance page, ~100–102 real BTCUSDT 1m candles, live kline stream
running throughout, camera actively orbiting/pinching/resetting during capture:**

| | Build (UI) | Raster | Total | Budget (60fps) |
|---|---|---|---|---|
| Sample 1 | 0.4 ms | 1.5 ms | 1.9 ms | 16.7 ms |
| Sample 2 | 1.4 ms | 0.8 ms | 2.2 ms | 16.7 ms |
| Sample 3 (spans a candle rollover) | 0.9 ms | 1.1 ms | 2.0 ms | 16.7 ms |

DevTools reported "No suggestions for this frame - no jank detected" on every
inspected frame across two separate ~20–55s capture windows, average FPS held
at 57–60 throughout, no red (jank) bars in either window. No before/after
delta to report — **the checklist in PLAN.md (material/entity reuse,
zero-allocation frames, WS throttling, candle cap) turned out to already be
satisfied by the session 1–7 design, not something this session needed to
apply:**

- Binance's own kline WebSocket only pushes an update roughly once per
  second — far below the 60Hz frame budget — so "throttle WS-driven scene
  updates to display refresh" was never actually a live risk; there was
  nothing to throttle down to.
- The common-case live tick already takes the O(1)-per-tick
  `CandleSceneAdapter.applyLiveCandle` path (session 6), touching exactly one
  asset. A full rescale (`buildScene`, the ~100ms-for-100-candles path) only
  fires when a live price escapes the current `PriceScale`, which is rare and
  was not observed during this session's capture windows.
- Materials are already one `UbershaderMaterialInstance` per candle, created
  once at `addCandle`/`updateLiveBlock` time, not recreated per frame; camera
  gestures only call `camera.lookAt` (session 7), never touch geometry or
  materials.

Conclusion: **60fps target met on this device without any code change.** If a
future session adds heavier per-frame work (e.g. depth terrain, session
10–11), re-run this same DevTools capture before assuming the budget still
holds — this number is a snapshot of the candlestick-city-only scene, not a
permanent guarantee.
