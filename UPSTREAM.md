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
| `manim/scene/scene.py` | `scene.lua` |
| `manim/camera/camera.py` | `renderer.lua`, `native/cairo_backend.c` |

The default Cairo arc consists of eight cubic segments / 32 control points.
Boundary critical points for VMobjects use anchors; dimensions use all control
points. Those are intentionally different upstream semantics. The Cairo
renderer uses default miter joins and butt caps, a 0.01 world-unit stroke-width
multiplier, and the same frame matrix. Length estimation defaults to ten
samples per cubic. Transform curve-count alignment follows `bezier_remap`.

## Reproduce the development oracle

Download the pinned archive into `.dev` and extract it as
`.dev/manim-0.22.1`. Create `.dev/venv` with `python -m venv` and install
`manim==0.22.1` there after checking available system libraries. Then run
`make reference`. The script asserts the exact Manim version. Updating upstream
must be an explicit compatibility change with regenerated tests and provenance.
