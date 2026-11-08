# Architecture

## Runtime

```text
scene.lua -> public Lua API -> object/geometry model -> animation/timeline
                                                    -> renderer -> Cairo C ABI
                                                               -> PNG frames
                                                               -> FFmpeg video
```

`lua/luanimath/init.lua` exports the public interface. `mobject.lua` owns points,
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
`lua/luanimath/text.lua` imports real per-glyph outlines from Pango’s in-memory
Cairo SVG output, using the native SVG importer. This preserves the same glyph
serialization, coordinate quantization and contour closure as Manim, with no
temporary text asset or Python. Spaces can have invisible placeholder geometry
when ligatures are disabled. `chars` shares glyph identity; copying preserves
that identity within the copied graph. Native text validates UTF-8 and bounds
the generated SVG stream. It does not rasterize text into a texture.
`text_settings.lua` resolves literal/selector style maps, gradients, line breaks
and overlaps into independent shaping runs, preserving Manim’s kerning/run
boundaries. C validates the runs before allocating graphics state. Markup is
parsed by Pango itself, with per-span attributes preserved in emitted SVG.
OpenGL must implement the same
renderer-facing object model; it is currently blocked in the coverage inventory.
`svg_path.lua` converts SVG commands to the same cubic geometry used by other
objects. `svg.lua` handles inherited styles, affine transforms, local references
and flat shape/group identity. `native/xml.c` decodes XML via libxml2; it does
not implement the geometry. Its document owner survives Lua errors and frees
the document through `__gc`. DTDs, external references and unsupported drawing
features are rejected. Images and math typography remain separate subsystems.
`camera.lua` now owns view frames, trackers, 3D rotation/projection, fixed
overlays, depth keys and the upstream light/normal calculations. The renderer
updates the native Cairo view matrix each frame, projects actual geometry and
uses native linear gradients for shaded faces. Depth is evaluated once per
object per frame before sorting. `three_d.lua` builds actual cubic face meshes
for Cube and parameterized surfaces/Sphere, using the upstream handle-shrink
derivative construction before nonlinear surface mapping.

LuaRay was evaluated as an optional numerical foundation. Basic point arithmetic
here has no need for its large ndarray API; depending on its evolving ABI would
currently add fragility. This decision can be revisited for batched geometry.

## Development reference path

An isolated Python environment executes upstream Manim. It produces frozen
numeric fixtures and Cairo reference images. Tests execute the *actual public
Lua API*, compare state and points, and decode the native output. Python is not
invoked by `require('luanimath')`, the CLI, scene construction, or rendering.

## Documentation pipeline

`tools/doc_api.lua` enumerates runtime exports and common method tables,
including generated camera methods and aliases. `docs/catalog.py`,
`docs/parameters.py` and `docs/returns.py` provide reviewed bilingual contracts.
`tools/docs.py check` rejects missing/stale API entries. The full build generates
Sphinx Lua-domain references, runs actual gallery scenes, decodes their media,
builds English/Spanish HTML with warnings as errors, and checks local links
and anchors. Output and source/media hashes are recorded under `artifacts/`.
Python/Sphinx remain developer dependencies rather than scene runtime tools.

## Mathematical typography

`typst_file.lua` invokes the native Typst CLI with shell-quoted arguments and
atomically caches validated SVG with SHA-256 integrity. Keys include source,
compiler version, font-path strings and project root; external font/file content
changes require cache invalidation. No Python runtime is involved.
`typst_groups.lua` parses balanced math captures while respecting strings and
content blocks. Hidden-capture probe compilations identify actual SVG leaves;
`typst.lua` imports them, preserves identity selections, scales source strokes
and tracks affine baseline frames with a covariance fit. Lua copy memoization
preserves each copied object's own tracking/selection graph.
The Scene render configuration is scoped during construction so typography
uses the active pixel-to-world ratio. TeX is a separate pending adapter.

`scales.lua` implements numerical map/inverse objects. NumberLine keeps raw
parameter ranges and uses the inverse map for geometric interpolation. Axes
places origins with scaled bounds and centers using scaled midpoints. Curves
map sample parameters before calling user Lua functions; graph plotting inherits
the x-axis scale. All scales obey the finite-value geometry contract.
