# Dependency-ordered roadmap

1. Broaden object/transform semantics: multipath alignment, family alignment,
   style inheritance, path builders and composition/backward-time cases.
2. Typography expansion: individual glyph Mobjects, character selection,
   per-glyph Write timing and markup. Native Pango-shaped Unicode paths,
   fonts and text metrics now have executed upstream comparisons.
3. Coordinate-system expansion: nonlinear scales, labels, specialized plots,
   Riemann rectangles and graphs. NumberLine, Axes, ParametricFunction,
   FunctionGraph, standard plots and spline smoothing now have executed tests.
4. SVG and raster assets with real file decoding, transformations and errors.
5. Math typography: external TeX or Typst pipeline, vector import, glyph grouping
   and matching-expression transforms. TeX tools are not currently installed.
6. Camera/3D expansion: clipping, full camera options, ThreeDAxes, other solids,
   textures and helper scene lifecycles. Moving cameras, 3D projection,
   Cube/Sphere/Surface, depth ordering and lighting now have real executed
   tests. OpenGL follows after the renderer-facing contracts stabilize.
7. Audio synchronization, formats, caching, configuration and remaining API
   families; continually extend differential/visual testing and portability.

Work proceeds through real, tested development releases. Each release updates
the coverage inventory and records remaining differences. The target remains
the broad Manim library, not a permanent reduced 2D product.
