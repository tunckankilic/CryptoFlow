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
than editing a matrix. That is fine for history, which is static, and is the
open question for the live block in session 6: if per-tick rebuilds prove too
expensive there, the live candle alone can keep a unit-cube body scaled by
transform while history stays merged.
