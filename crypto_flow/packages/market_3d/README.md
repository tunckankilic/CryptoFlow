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
