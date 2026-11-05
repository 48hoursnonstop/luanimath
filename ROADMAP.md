# Dependency-ordered roadmap

1. Broaden object/transform semantics: multipath alignment, family alignment,
   style inheritance, path builders and composition/backward-time cases.
2. Typography foundation: actual Pango-shaped Unicode paths, fonts and text
   metrics; differential tests against upstream Text with the same font stack.
3. Coordinate systems: NumberLine, Axes, ParametricFunction, plots and associated
   numerical mapping; preserve curve and sampling semantics.
4. SVG and raster assets with real file decoding, transformations and errors.
5. Math typography: external TeX or Typst pipeline, vector import, glyph grouping
   and matching-expression transforms. TeX tools are not currently installed.
6. Camera model and moving/zoomed cameras, then projection, 3D surfaces and
   lighting; OpenGL after the renderer-facing contracts have stabilized.
7. Audio synchronization, formats, caching, configuration and remaining API
   families; continually extend differential/visual testing and portability.

Work proceeds through real, tested development releases. Each release updates
the coverage inventory and records remaining differences. The target remains
the broad Manim library, not a permanent reduced 2D product.
