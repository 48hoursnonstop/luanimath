# Changelog

## 0.13.0-dev

- Target generation, MoveToTarget, Restore, ApplyMethod, ApplyFunction,
  ApplyPointwiseFunction, ApplyMatrix, FadeToColor, ScaleInPlace and ShrinkToCenter.
- Deferred target creation follows source timing; Lua ApplyMethod accepts
  explicit subject, method name/unbound function and packed argument tables.
- Source-derived Bézier handle shortening/expansion for nonlinear mapping,
  configurable handle factor and post-smoothing, including Surface behavior.
- Align live transform families before capturing starting snapshots; become
  and immediate restore preserve source family alignment/faded extra children.
- Fix Text/MarkupText parent paints to follow requested base color.
- 72 transform cases/360 sampled states, 20 direct operations and 27 exact
  original image matches. Strict bilingual tutorial/reference and twelfth
  real gallery scene.

## 0.12.0-dev

- GrowFromPoint, GrowFromCenter, GrowFromEdge and SpinInFromNothing use
  actual vector snapshots, color interpolation, lagging and scene lifecycles.
- General spiral_path with arbitrary-axis rotation, zero-axis fallback,
  source threshold and extrapolated path evaluation.
- 24 growth cases with 144 sampled states, 108 spiral cases and 52,247
  numerical/lifecycle checks; all 24 actual images match upstream exactly.
- Native text/group growth, captured-center timing, Mobject origins and
  real scene introduction/removal are executed. GrowArrow remains pending.
- English/Spanish tutorials/reference and an eleventh real gallery animation.
- Exclude development-oracle media caches from Git and source archives.

## 0.11.0-dev

- Circular ArcBetweenPoints, endpoint placement, XY center queries/movement
  and final polar angles; full turns use Circle.
- Polygram closed loops, vertex queries, signed per-corner rounding, cutoff
  clamping, anchor redistribution and RoundedRectangle.
- SVG rx/ry defaults, clamping and elliptical corner conversion through the
  native rounded geometry; negative SVG radii are rejected explicitly.
- 16,106 numerical/boundary checks and eleven exact original image matches.
  Eleven original center/subdivision/closed-loop differences are retained
  and compared using separate, explicitly described diagnostics.
- Bilingual rounded-geometry tutorial and tenth real gallery animation;
  references cover 283 function bindings and 109 constants.

## 0.10.0-dev

- LinearBase and LogBase numerical scales, scalar/nested-array map/inverse
  methods, scaled ticks and transformed coordinate conversion.
- Axes origin placement and logarithmic origin ticks; scaled curve sampling,
  discontinuity exclusions and x-scale inheritance in Axes.plot.
- Full 89-color Manim palette with spelling aliases as native Lua RGB strings.
  Correct YELLOW to #F7D96F; PURE_YELLOW retains #FFFF00.
- 20,602 scale checks, 801 exact color checks and four new real image
  comparisons. The previous graph-image mismatch is now resolved exactly.
- English/Spanish scale tutorials and a ninth executed gallery animation,
  with explicit MathTypst labels and tracker-driven motion.
- Pinned native Typst download uses the verified GitHub asset API after
  reproducible HTTP 504 failures on the browser-download URL. Pages passed
  actual deployment and both public math tutorials were verified live.

## 0.9.0-dev

- Native Typst CLI compilation and SVG import; public Typst and MathTypst.
- Named, anonymous, nested and repeated expression captures sharing actual
  glyph identities, source colors, stroke scaling and affine baseline frames.
- Integrity-checked asset cache, explicit compiler/font/root options and
  actual corruption repair; no Python runtime dependency.
- Scoped Lua configuration with guaranteed restoration and render settings
  active during scene construction. Opaque vector color queries/properties.
- 44 formula states and 10 parser cases; 38 exact unmodified image matches
  and six separately diagnosed upstream SVG-cache tracking differences.
- English/Spanish math tutorials, generated reference and an eighth rendered
  gallery scene. CI installs the native compiler with a pinned SHA-256.

## 0.8.2-dev

- English and Spanish Sphinx/Furo manuals: installation, tutorials, migration,
  API reference, configuration, compatibility, gallery and contributor guide.
- Reference records cover the runtime-exported Lua surface, with parameters,
  supported options/defaults, results, source links and alias cross-references.
- Documentation/API drift checks run with the regression suite; release builds
  verify both manuals from clean source and package offline HTML separately.
- Seven real documentation scenes with verified PNGs and decoded MP4s.
- Respect explicit Uncreate remover=false; reject FadeOut remover options in
  accordance with the pinned upstream constructor. Added regression coverage.

## 0.8.1-dev

- Project renamed to **luanimath**, including the Lua module tree, native ABI,
  CLI, examples, cache names, source release prefix and documentation.
- Previous source archives remain available under their original names.
- Native asset hash primitive has executed standard binary/SHA-256 vectors.
- Mathematical typesetting remains in progress; no public Typst API parity
  is claimed by this naming release.

## 0.8.0-dev

- Native MarkupText with validated Pango attributes, nested formatting,
  colors, sizes, decorations, scripts, shaping and justified paragraphs.
- Text word/range font, weight, slant and color maps, long-form aliases,
  per-character gradients, Unicode selectors and overlap conflict detection.
- Independent shaping runs preserve upstream kerning and layout boundaries.
- RGB color gradients and per-family gradient styling preserve opacity.
- 21 markup, 40 styled text and 19 gradient cases, with 61 exact image matches;
  a real 108-frame combined styled-text animation with verified erasure.

## 0.7.0-dev

- Real Pango glyph Mobjects imported from in-memory Cairo SVG; all previous
  text images now match exactly, retaining the diagnosed standalone-RTL case.
- Lua indexing, length, iteration, shared-identity inclusive slicing, split
  and recursive inversion; scaled text font-size access and assignment.
- Invisible whitespace placeholders, natural ligatures and disabling.
- Reverse Write and Unwrite, with upstream ordering/cleanup semantics.
- 19 glyph cases, 42 Write/Unwrite states and images, and three font resizing
  cases; actual selection/style animation and erasure in a native video.

## 0.6.0-dev

- Lua SVG path engine including elliptical arcs and smooth control reflection.
- Native libxml2 decoding, SVG shapes, inherited styles, affine transforms,
  local references and named group lookup, without Python at runtime.
- 73 path and 24 object reference cases, 12 exact pixel comparisons, explicit
  unsupported-feature errors, and a real 96-frame animated SVG example.

## 0.5.0-dev

Resumed after the quota reset. Source-only packaging, checksum validation and
the complete clean extraction/rebuild/test now pass, including actual 3D video.

- Camera, MovingCamera and ThreeDCamera with live view frames, orientation,
  focal distance, zoom, fixed overlays, tracked movement and depth ordering.
- Native two-stop Cairo gradients implement the upstream per-corner lighting.
- Source-derived Cube, Sphere, ThreeDVMobject and parametric Surface meshes.
- Eighteen camera states, six 3D geometry cases and seven exact visual matches,
  covering lit/unlit geometry and a moving camera.
- A real 84-frame 3D animation, full decoding and measured frame changes.
- Strict function-result validation and explicit render-time frame overrides.
- Recorded reference dependency/font fingerprints; verified all 177 installed
  upstream Python sources match the pinned release archive.

## 0.4.0-dev

- Cubic/quadratic/line path builders, pending anchors, subpaths, closure,
  subdivision, wrapped closed subcurves and VectorizedPoint.
- Source-derived vector family/subpath alignment, including empty groups and
  faded duplicate members; 72 Transform states and 30 exact visual comparisons.
- Arc/circular/custom paths, Uncreate, backward group interpolation, snapshot
  updater execution and grouped MoveAlongPath correction.
- State save/restore and explicit updater suspension/resumption.
- Broadened public-definition inventory to 5,155 entries, including utility
  functions intentionally omitted from upstream star imports.

## 0.3.0-dev

- Numerical lines, ticks, triangular tips, axes and transformed point mapping.
- Parametric and function graphs, discontinuity intervals, plots, updater-based
  redraw and open/closed cubic spline smoothing with O(N) solvers.
- 83 new upstream cases and 12,264 scalar/invalid-input checks; real sine plot
  screenshot comparison and an actual tracker-driven graph animation.
- Expanded API inventory to include uppercase constant declarations and a root
  public-export index; all declared availability remains evidence-based.
- Corrected default world frame to Manim's fixed 128/9 × 8 independently of
  raster resolution, and distinguished a path's last control point from its
  arrow-tip endpoint.

## 0.2.0-dev

- Native Pango-shaped Unicode vector text, fonts, size, weight, slant, multiline
  layout, tabs and ligature disabling in a separate native source module.
- Write and DrawBorderThenFill's actual outline/fill interpolation phases.
- Thirteen original-upstream text comparisons and one explicitly diagnosed
  standalone RTL layout mismatch, verified against a corrected-layout oracle.
- Extended geometry/animation oracle: 282 cases, 12,584 numeric comparisons,
  42 reference frame pairs.
- Actual PNG, MP4, GIF and WebM motion exports and complete decoding checks.
- A real typography animation example.

## 0.1.0-dev

- Pinned Manim 0.22.1 sources, attribution and an explicit API inventory.
- Lua vector and cubic geometry, Mobjects, groups, transforms and styles.
- Animation lifecycle, interpolation, composition, trackers and updaters.
- Real Cairo backend, PNG frames, FFmpeg encoding and Lua CLI.
- Native Lua regression tests, frozen upstream numerical and visual fixtures,
  sanitizer target, and clean source release verification.
- Corrected VMobject anchor-based critical points, control-point dimensions,
  inherited Ellipse color, Scene.play rate overrides and shared-object handling
  using actual upstream behavior and regression tests.
