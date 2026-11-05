# Architecture

## Runtime

```text
scene.lua -> public Lua API -> object/geometry model -> animation/timeline
                                                    -> renderer -> Cairo C ABI
                                                               -> PNG frames
                                                               -> FFmpeg video
```

`lua/luanim/init.lua` exports the public interface. `mobject.lua` owns points,
hierarchical identity, transformations and update callbacks. `geometry.lua`
constructs actual cubic paths, following upstream geometry. `vector.lua`,
`bezier.lua`, `color.lua` and `rate_functions.lua` implement the associated
mathematics without a numerical package dependency.

`animation.lua` separates construction, begin, interpolation and finish.
Transforms capture copies at begin and align control-point counts through de
Casteljau subdivision. Composition schedules children by their natural
durations and lag ratios. Successions capture each child's state when it
actually begins; groups begin all members and can interpolate backward.
Updaters on an animated object are suspended and resumed, while snapshot and
target updaters run before each interpolation, matching the upstream lifecycle.
Vector alignment recursively normalizes families and subpaths, duplicates
missing family members with zero opacity, and creates null vector paths where
needed. Pending single-anchor paths are an explicit state of the geometry model.

`scene.lua` orchestrates identity and frame evaluation. Each play/wait segment
samples `t = k / fps` for `0 <= t < duration`, then finishes at its logical end.
Thus encoded duration is the sum of the rounded-up segment frame counts / fps,
which can differ from logical scene time for non-integral frame durations.
The final still contains the finished state and may differ from the final
encoded sample. There is no real-time clock in the evaluation path.

`renderer.lua` flattens visible vector families once by object identity, sorts
by z-index with stable insertion ties, and dispatches geometry to the Cairo
backend. The C module does not own Lua scene objects. Its surface userdata owns
one Cairo surface and context; `close`, `__gc` and `__close` share idempotent
cleanup. Inputs are validated before modifying Cairo state. PNG errors propagate
as Lua errors. Dimensions bound native allocations. The context uses Manim's
world-to-pixel matrix and stroke-width factor of 0.01.

`config.lua` resolves and validates configuration. FFmpeg invocation passes
individually quoted arguments, and frame directories come from `mktemp`.
Failed renders retain their frame directory for diagnosis. Successful renders
remove only their own generated directory unless `keep_frames` is requested.

`graphing.lua` owns numerical ranges, NumberLine, Axes and parametric graphs.
It derives mapping from the transformed axis endpoints, including arrow tips,
so mapping follows group rotations/scaling. `bezier.lua` solves open splines
using Thomas' tridiagonal algorithm and closed splines using a rank-one cyclic
correction. Both are O(N), rather than a dense cubic-cost solve. The public
world frame matches Manim's fixed 128/9 × 8 default independently of raster size.

## Dependencies and extension boundaries

Cairo is the first backend. `native/text.c` owns the Pango typography interface;
`lua/luanim/text.lua` converts actual glyph outlines to vector objects and applies
the upstream font-size and geometry scaling. It uses a Cairo SVG target for
the same font metrics as Manim and does not rasterize text into a texture.
OpenGL must implement the same
renderer-facing object model; it is currently blocked in the coverage inventory.
SVG, images, math typography, camera movement and 3D projection each require
their own tested subsystem rather than pretending to be generic path aliases.

LuaRay was evaluated as an optional numerical foundation. Basic point arithmetic
here has no need for its large ndarray API; depending on its evolving ABI would
currently add fragility. This decision can be revisited for batched geometry.

## Development reference path

An isolated Python environment executes upstream Manim. It produces frozen
numeric fixtures and Cairo reference images. Tests execute the *actual public
Lua API*, compare state and points, and decode the native output. Python is not
invoked by `require('luanim')`, the CLI, scene construction, or rendering.
