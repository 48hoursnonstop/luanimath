# Compatibility

Target: Manim Community 0.22.1. Current development version: 0.5.0-dev.

The public API inventory is `compatibility/api_inventory.json`; reviewed
declarations are in `compatibility/implemented.json`. `python3 tools/coverage.py`
validates declarations and writes `compatibility/summary.json`. Status labels:

- `implemented_verified`: the documented API has executed behavioral evidence.
- `implemented_partial`: actual functionality exists, with explicit restrictions.
- `not_implemented`: no implementation is claimed.
- `blocked`: an identified dependency subsystem is missing.
- `not_applicable`: only for a justified host-language difference; none is used
  to avoid implementing a scene capability.

The current inventory contains 5,155 explicit symbols. It includes module
`__all__` declarations, all public definitions, and
public class methods defined in those classes and uppercase constant assignment
declarations. Inherited methods resolve to the defining class. Runtime root
exports have a separate index in `compatibility/public_exports.json`.
Dynamic instance attributes still need a later audit.
These symbol counts are not a percentage of total project completion.

## Executable surface

Actual vector paths: VMobject, VGroup, Group, Arc, Circle, Dot, Ellipse, Line,
Polygon, RegularPolygon, Rectangle, Square, Triangle and CubicBezier. Transforms
include shift, scale, stretch, arbitrary-axis rotation, 2×2/3×3 matrices,
positioning, alignment, grouping, copying, stroke/fill style and z-order.

Actual animations: Create, Write, DrawBorderThenFill, FadeIn, FadeOut, Transform, ReplacementTransform,
Rotate, MoveAlongPath, AnimationGroup, Succession and LaggedStart. Builders use
`m:animate(options):shift(...)`. ValueTracker and callbacks execute in Lua.
Scenes provide add/remove/replace, play/wait, deterministic stepping and real
PNG/MP4/GIF/WebM rendering. All four formats have executed file decoding and
motion checks. PNG transparency has been checked; encoded-format alpha fidelity
needs further coverage.

Text now has real native Pango shaping and cubic outlines: font selection,
Unicode, multiline text, tabs, font size, BOLD/LIGHT weights, ITALIC/OBLIQUE
styles and ligature disabling. Thirteen text cases match upstream metrics
within 1e-4 scene units and image differences within the stated tolerance.
This metric tolerance accounts for the upstream SVG glyph-coordinate
serialization quantization; native Pango paths retain more precision.

One standalone RTL word produces an empty SVG in upstream because canvas-wide
automatic RTL alignment clips it outside the surface. Luanim renders it.
`tools/reference_text.py` retains the original empty output and diagnoses it
by changing only ManimPango's `pango_width` to 100, which restores the glyphs.
The corrected reference matches the native output. This is **one explicitly
recorded original-upstream mismatch**, not a passing original compatibility case.
Mixed LTR/Arabic text is separately checked against unmodified Manim.

## Current restrictions

MovingCamera and MovingCameraScene have an actual animated frame. ThreeDCamera
and ThreeDScene provide phi/theta/gamma orientation, focal distance, zoom,
projection, fixed overlays, depth ordering and tracked camera movement. The
native Cairo backend performs the two-stop lighting gradients used by Manim's
3D shading. Cube, Sphere, ThreeDVMobject and parametric Surface have executed
geometry and visual comparisons; seven moving-camera/3D reference frames,
including lit and unlit objects, matched pixel-for-pixel in this environment.
Surfaces retain upstream zero-based `u_index`/`v_index` metadata internally;
Lua sequence tables remain 1-based.

Numerical axes and graphs now include NumberLine, Axes, scalar/batched point
conversion, ticks, standard triangular 2D tips, ParametricFunction,
FunctionGraph and Axes.plot. Open and closed cubic splines use the upstream
linear-time tridiagonal/rank-one algorithms, with 83 differential cases and
12,264 scalar/invalid-input comparisons. `always_redraw` executes actual Lua
callbacks. Nonlinear scaling, math labels, custom tips and many specialized
plotting methods remain pending and are explicitly rejected where applicable.

- Transform aligns unequal vector families, empty vector groups, differing
  curve counts and multiple subpaths using upstream duplication/fade and null
  path rules. Non-vector point clouds and all malformed/degenerate cases are
  not yet covered. Curved arc/circular paths and custom path functions work.
- One RGBA fill and stroke per object. Gradient/sheens, background strokes,
  several style inheritance options and path-building APIs are pending.
- Path builders support complete cubics and one pending start anchor, including
  lines, quadratic degree elevation, multiple subpaths, closing and subdivision.
  Incomplete two-/three-point cubic groups are rejected. Boundary queries on
  pending paths use the available anchor instead of reproducing upstream's
  inconsistent anchor-array zip failure.
- AnimationGroup/LaggedStart support backward interpolation and there-and-back
  rate functions. Succession remains forward stepping. Starting/target snapshots
  execute their actual updaters; grouped MoveAlongPath preserves the whole group.
  The complete option surface and every overlapping animation case still need work.
- Many constructor options are still pending; an implemented class name does
  not imply all its upstream arguments are implemented.
- Text is currently one VMobject containing shaped contours, rather than
  individual glyph Mobjects. Character slicing, per-glyph timing, text-to-color
  mappings, MarkupText, missing-font warnings and advanced layout remain pending.
  Reverse Write is explicitly rejected.
- Camera clipping at the focal plane, complete surface/camera options,
  per-point textures, subcameras, ambient rotation helpers and the remaining
  3D object families are pending. Points exactly on the focal plane are
  explicitly rejected. The 3D API remains partially compatible.
- Math typography, SVG, images, advanced plots, remaining 3D features, OpenGL,
  audio, render caching, scene sections and notebook integration are pending.
- Lua 5.4 is the only tested ABI. Lua indices are 1-based. Tables and functions
  replace Python classes and keyword machinery where appropriate.

## Numeric and visual tolerances

Differential geometry, style and timing fixtures use absolute tolerance 1e-9.
Image comparisons require equal dimensions, mean absolute RGBA channel error
<=0.6 on [0,255], and at most 0.004 of pixels with any channel error >16.
These allow small Cairo edge-rounding variation without accepting displaced
geometry or changed object colors. Measured errors are recorded, never inferred.
The initial 30 frame pairs had zero pixel error in this environment.

Three-dimensional numerical comparisons use 1e-9 absolute plus 1e-14 relative
tolerance. The relative term is necessary for the upstream behind-focal-plane
sentinel projection factor of 1e6, which magnifies normal floating-point matrix
rounding into coordinates above 1e7. The seven 3D image tolerances are unchanged
from the existing visual suite and measured zero error. Ordinary 2D numerical
tolerances remain 1e-9 absolute.

No overall production-readiness or complete Manim compatibility is claimed.
