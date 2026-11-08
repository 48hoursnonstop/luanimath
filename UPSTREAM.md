# Upstream and provenance

Reference: Manim Community Edition **v0.22.1**.

- Repository: https://github.com/ManimCommunity/manim
- Commit: `16ea443e2a5f1d79db0a721161411ce916d6e733`
- Archive URL and SHA-256: `compatibility/upstream.json`.
- SHA-256 for all inspected package sources: `compatibility/upstream_files.sha256`.
- Upstream licenses: `LICENSE.manim` and `LICENSE.manim-community`.

Manim is copyright its original and community contributors, including Grant
Sanderson and the Manim Community Developers. The retained MIT notices apply
to its source-derived algorithms. Luanim's own changes are MIT-licensed.

## Initial port mapping

| Upstream source | Lua/native implementation |
| --- | --- |
| `manim/mobject/mobject.py` | `lua/luanim/mobject.lua`, `scene.lua` hierarchy handling |
| `manim/mobject/types/vectorized_mobject.py` | `mobject.lua`, `bezier.lua`, `animation.lua` |
| `manim/mobject/geometry/arc.py` | `geometry.lua` cubic arc control points |
| `manim/mobject/geometry/line.py` | `geometry.lua` straight lines and buffers |
| `manim/mobject/geometry/polygram.py` | `geometry.lua` polygons and rectangles |
| `manim/utils/bezier.py` | `bezier.lua` interpolation, splitting and remapping |
| `manim/utils/rate_functions.py` | `rate_functions.lua` |
| `manim/animation/{animation,creation,fading,transform,rotation,composition}.py` | `animation.lua` |
| `manim/mobject/value_tracker.py` | `geometry.lua`, `mobject.lua` |
| `manim/mobject/svg/svg_mobject.py` | `svg.lua`, `svg_path.lua`, `native/xml.c` |
| `manim/mobject/text/text_mobject.py` | `text.lua`, `native/text.c` |
| `manim/mobject/graphing/number_line.py` | `graphing.lua` |
| `manim/mobject/graphing/coordinate_systems.py` | `graphing.lua` |
| `manim/mobject/graphing/functions.py` | `graphing.lua` |
| `manim/mobject/geometry/tips.py` | `graphing.lua` triangular tip geometry |
| `manim/scene/scene.py` | `scene.lua` |
| `manim/camera/camera.py` | `renderer.lua`, `native/cairo_backend.c` |
| `manim/camera/{moving_camera,three_d_camera}.py` | `camera.lua` |
| `manim/scene/three_d_scene.py` | `scene.lua` camera methods |
| `manim/mobject/three_d/three_dimensions.py` | `three_d.lua` |
| `manim/mobject/three_d/three_d_utils.py`, `manim/utils/color/core.py` | `camera.lua` corner normals and lighting |

The default Cairo arc consists of eight cubic segments / 32 control points.
Boundary critical points for VMobjects use anchors; dimensions use all control
points. Those are intentionally different upstream semantics. The Cairo
renderer uses default miter joins and butt caps, a 0.01 world-unit stroke-width
multiplier, and the same frame matrix. Length estimation defaults to ten
samples per cubic. Transform curve-count alignment follows `bezier_remap`.
Spline smoothing uses the upstream open/closed handle-point systems and their
linear-time solutions. Tick enumeration preserves Manim's origin inclusion,
negative/positive range handling, and tip endpoint rules.

Text uses Manim's public-font-size / 4.8 conversion to Pango points and a final
0.05 scene-unit geometry scale. Glyph rounding is disabled, as in ManimPango
0.7.1. That installed dependency's `cmanimpango.pyx` was also inspected to
verify its font description, per-line positioning and width behavior.
Standalone RTL clipping is preserved as a diagnosed upstream difference in
the test records; it is not silently accepted as original parity.

SVG arc conversion also derives from **svgelements 1.9.6**, the installed
upstream dependency, especially `Arc._svg_parameterize` and `Arc.as_quad_curves`.
Its MIT notice is retained in `LICENSE.svgelements`. Lua directly executes the
conversion; neither svgelements nor Python is a runtime dependency.

## Reproduce the development oracle

Download the pinned archive into `.dev` and extract it as
`.dev/manim-0.22.1`. Create `.dev/venv` with `python -m venv` and install
`manim==0.22.1` there after checking available system libraries. Then run
`make reference`. The script asserts the exact Manim version. Updating upstream
must be an explicit compatibility change with regenerated tests and provenance.

The installed reference wheel's 177 Python package sources were checked against
the pinned source archive: every file matched byte-for-byte. Exact reference
dependency versions and tested font-file hashes are recorded in
`compatibility/reference_environment.json`.
