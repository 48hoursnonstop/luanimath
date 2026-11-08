# Dependency-ordered roadmap

1. Broaden object/transform semantics: multipath alignment, family alignment,
   style inheritance, path builders and composition/backward-time cases.
2. Typography expansion: remaining font/layout options, deprecated custom tags
   and more shaping edge cases. Native markup, word/range style maps, gradients,
   glyph selection and Write/Unwrite now have executed upstream comparisons.
3. Coordinate-system expansion: automatic labels, specialized plots,
   Riemann rectangles and graphs. NumberLine, Axes, ParametricFunction,
   FunctionGraph, linear/logarithmic scales, standard plots and spline smoothing
   now have executed tests.
4. Expand the now-tested native SVG importer (CSS, caching,
   more units) and add raster assets with real decoding and error handling.
5. Math typography expansion: TeX pipeline, expression-matching transforms,
   additional Typst options and asset-aware cache invalidation. Native Typst
   compilation, labeled/nested captures, stroke scaling and affine baselines
   now have executed numeric/visual comparisons. TeX tools are not installed.
6. Camera/3D expansion: clipping, full camera options, ThreeDAxes, other solids,
   textures and helper scene lifecycles. Moving cameras, 3D projection,
   Cube/Sphere/Surface, depth ordering and lighting now have real executed
   tests. OpenGL follows after the renderer-facing contracts stabilize.
7. Audio synchronization, formats, caching, configuration and remaining API
   families; continually extend differential/visual testing and portability.

Work proceeds through real, tested development releases. Each release updates
the coverage inventory and records remaining differences. The target remains
the broad Manim library, not a permanent reduced 2D product.

Documentation is maintained alongside every feature. Public API additions must
include English and Spanish catalog/parameter entries, supported defaults and
limits, plus applicable executed tutorial/gallery updates. The API drift check
is part of `make check`; strict bilingual HTML builds are a release gate.
