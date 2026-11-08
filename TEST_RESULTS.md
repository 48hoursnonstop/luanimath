# Executed test results

## 0.9.0-dev — native mathematical typography

- Complete `make check` passed, including all existing numerical, visual and
  media regressions; core suite remains **18 groups, 333 checks**.
- Real Manim 0.22.1 with typst-py 0.15.2 (embedded Typst 0.15.1) produced
  **44 formula states/images and 10 capture-parser cases**. Actual Lua API
  execution passed **63,893 checks**, including capture identity, nested/repeated
  labels, source colors, sizing, strokes, affine baselines, copied graphs,
  configuration restoration, invalid input and corrupt-cache recompilation.
  Cache paths containing quotes, a newline and Unicode executed successfully.
- **38 unmodified-upstream image comparisons measured zero pixel error**.
  Six original cache-hit states lose baseline/stroke tracking in upstream;
  their mismatches remain asserted and separately recorded. Six diagnostic
  images changing only use_svg_cache=False also measured zero pixel error.
  These are explicitly separate from original-upstream compatibility passes.
- ASan/UBSan passed nine native-boundary suites including the new formula
  suite. Leak detection was disabled; system libraries were not instrumented.
- Both strict manuals built with **269 function bindings, 251 distinct
  functions, 18 aliases, 35 constants, 71 HTML pages and 6,391 checked local
  links/assets/anchors**. Both languages include the executed math tutorial.
- All eight gallery scenes rendered actual PNG/MP4 output and all videos
  fully decoded. The math example contains **36 frames, 640×360, 12 fps,
  three seconds**; its real final frame was opened for visual inspection.
- The inventory now declares **211/5,155 symbols available (4.09%)**:
  205 partially implemented and six verified. This is a symbol count, not an
  overall completion estimate.
- Clean source rebuilding, regression and strict documentation rebuilding
  are required by `make release`; their executed result and archive hashes
  are recorded in the generated release verification report.

## 0.8.2-dev — bilingual documentation

- Complete `make check` passed, including the new runtime documentation/API
  drift check. Core suite: **18 groups, 333 checks**.
- Reviewed English/Spanish descriptions and parameter/return contracts cover
  **261 function bindings, 243 distinct functions, 18 aliases and 35 constants**
  in the enumerated Lua surface. This is documentation coverage, not upstream
  compatibility or overall completion.
- Strict Sphinx/Furo builds passed for both languages: **67 HTML pages** and
  **5,879 checked local links, assets and anchors** at the recorded build.
- All **seven gallery scenes** executed through the actual Lua CLI: real
  640×360 PNGs were opened, all MP4s were probed and fully decoded at 12 fps.
  Source/image/video SHA-256 values are in the gallery verification report.
- Chromium opened the manual for visual inspection. English and Spanish
  searches for SVGMobject executed in-browser and returned the Lua API target.
- ASan/UBSan passed the native-boundary regression suites; leak detection was
  disabled and system libraries were not instrumented.
- Actual upstream execution confirmed Uncreate(remover=False) retains one
  degenerate curve and its scene object, while FadeOut rejects an explicit
  remover keyword. Matching Lua regression checks passed.
- Source archive extraction, SHA-256 manifest validation, native rebuilding,
  full `make check` and strict bilingual documentation rebuilding all passed
  from the clean extracted source. A separate offline HTML archive was built.

## 0.8.1-dev — project rename

- `require('luanimath')`, the renamed native module and
  `tools/luanimath.lua` execute real scenes from `/mnt/datos/luanimath`.
- Complete `make check` passed after the rename, including all actual media
  decoding and frozen upstream numerical/visual comparisons.
- Core suite: **17 groups, 326 checks**, including native SHA-256 standard
  vectors, an embedded NUL, a million-byte input and invalid input.
- ASan/UBSan passed the renamed core, text, alignment, 3D, SVG, glyph, markup
  and text-styling suites. Leak detection remained disabled.
- Prior source archives remain intact under their original filenames.
- Source-only `luanimath-0.8.1-dev.tar.gz` clean extraction/rebuilding/testing
  is the release gate; generated integrity reports are under `releases/`.

## 0.8.0-dev — 2026-11-07 America/Mexico_City

- Strict native compilation and complete `make check` passed. Final added
  markup font-size/empty-gradient checks also passed through the real Lua API.
- **21 MarkupText cases, 87,595 numerical/invalid-input checks**, including
  three source-derived resized glyph arrays and font-size properties.
- **40 styled Text cases and 19 RGB gradient cases, 125,380 checks**. Includes
  Unicode and bracket selectors, aliases, per-range fonts/weights/slants/colors,
  gradients, source shaping boundaries and twenty seeded overlapping-style cases.
- All **61 new real images matched pixel-for-pixel**. Existing text, glyph,
  SVG, 3D, alignment, plotting, composition and media regression suites passed.
- Markup example: **108 frames, 640×360, 24 fps, 4.5 seconds**. FFmpeg fully
  decoded it and checked both motion and actual final text erasure. Mean RGB
  frame changes: **3.4541449652777776** and **3.7308969907407405**. A decoded
  frame was opened for inspection.
- ASan/UBSan passed core, text, alignment, 3D, SVG, glyph, markup and
  text-styling suites, including the final added markup assertions. Leak
  detection was disabled and system libraries were not instrumented. Logs
  are retained under `artifacts/`.
- Clean source extraction/rebuild/test and SHA-256 results are generated by
  `make release` under `releases/`; the release is gated on that actual run.

## 0.7.0-dev — 2026-11-07 America/Mexico_City

- Strict native compilation and complete `make check` passed.
- **19 glyph cases, 42 Write/Unwrite states and three font resizing cases**;
  **72,066 numerical/identity/invalid-input checks**. Includes real Noto Sans
  ligatures, invisible spaces, tabs, mixed scripts, combining accents, raw
  positioning, resizing, shared slices, copies and reversed order cleanup.
- **42 actual per-letter animation frames matched pixel-for-pixel**.
- All **13 original-upstream text images** and the separately diagnosed RTL
  layout image now match pixel-for-pixel. The original upstream RTL clipping
  mismatch remains recorded; its diagnostic is not counted as original parity.
- Glyph example: **108 frames, 640×360, 24 fps, 4.5 seconds**, fully decoded.
  Sampled frame RGB changes were **3.439907407407407** and
  **2.837824074074074**. A decoded frame was opened and inspected. The final
  central lettering was erased by real Unwrite and checked numerically.
- All existing regressions, differential geometry, SVG, 3D, plotting and media
  decoding passed. ASan/UBSan passed core, text, alignment, 3D, SVG and glyph
  suites; leak detection was disabled and system libraries were not instrumented.
- Source-only archive extraction, SHA-256 manifest validation, native rebuild
  and complete `make check` passed in a clean directory. Archive checksum,
  verification JSON and full clean build log are retained in `releases/`.

## 0.6.0-dev — 2026-11-07 America/Mexico_City

- Strict native C11 compilation and full `make check` passed.
- SVG: **73 path cases, 24 imported object cases, 6,632 numerical and
  invalid-input checks** executed through the Lua API, against actual Manim.
- **12 native SVG images matched pixel-for-pixel**, including transformed
  paths, CSS RGB colors, alpha quantization, local references, non-scaling
  strokes, visibility and root styling.
- Actual SVG animation: **96 frames, 640×360, 24 fps, four seconds**. FFmpeg
  fully decoded it. Mean sampled RGB frame changes: **4.556552372685185** and
  **4.883288483796297**. A decoded frame was opened for inspection.
- All existing regression, differential, text, graphing, alignment, paths,
  3D and actual media checks passed. The recorded original RTL mismatch remains.
- ASan/UBSan passed core, text, alignment, 3D and the new SVG suite. Leak
  detection was disabled; system dependencies were not instrumented.
- Source-only archive creation, clean extraction, SHA-256 manifest validation,
  native recompilation and the complete test suite passed. Generated
  verification JSON, archive SHA-256 and full build log are in `releases/`.

## 0.5.0-dev — 2026-11-04 America/Mexico_City

- Native module compiled with strict C11 warnings; complete `make check` passed.
- **18 camera configurations and 6 3D geometry cases**, **6,756 numerical and
  invalid-input checks**. See COMPATIBILITY.md for the justified absolute and
  relative projection tolerance, including points behind the focal plane.
- **Seven actual native images matched upstream pixel-for-pixel**: Cube,
  Sphere and Surface with/without shading, plus a MovingCamera viewport.
- Real 3D example: **84 frames, 640×360, 24 fps, 3.5 seconds**, fully decoded
  by FFmpeg and inspected as an image. Differences between sampled frames were
  **3.0330613425925925** and **20.426451099537037** mean RGB channel levels,
  confirming actual object/camera motion.
- All prior geometry, path alignment, composition/updater, text, graphing,
  media decoding and visual regression suites passed. The original standalone
  RTL mismatch remains explicitly recorded rather than claimed as parity.
- The exact versions and font hashes used by the upstream oracle are recorded
  in `compatibility/reference_environment.json`. All **177 installed Manim
  Python source files matched the pinned tag byte-for-byte**.

Native ASan/UBSan execution passed the core, text, alignment and 3D suites;
leak detection was disabled and system dependencies were not instrumented.
After resumption, **0.5 clean source archive extraction, manifest validation,
native compilation and complete `make check` passed**, including actual 3D
video rendering and decoding. The clean log and SHA-256 are in `releases/`.

## 0.4.0-dev — 2026-11-04 America/Mexico_City

- Core Lua regression: **16 groups, 321 checks passed**.
- Geometry/animation: **288 upstream cases, 12,884 scalar comparisons**;
  **48 real frame comparisons**, all with zero pixel error.
- Path construction/alignment: **8 builder states and 72 family/subpath
  Transform states**, **15,657 numerical/identity checks**. All **30 additional
  family/subpath reference frame pairs had zero pixel error**.
- Mathematical paths/updaters: **136 path cases, 25 arc transforms, 5 composition
  traces including backward evaluation, and 5 grouped motion states**;
  **10,284 numeric checks**, including actual source/target snapshot updaters.
- Existing text, numerical-graph, media and visual suites passed.
- Morph example: actual **120-frame, 640×360, 24 fps, five-second** animation
  transforming a square into a two-member group, then a compound path, then
  Uncreate. The export command completed; full decoding is recorded at release.

## 0.3.0-dev — 2026-11-04 America/Mexico_City

- Core Lua regression: **15 groups, 313 checks passed**.
- Graphing oracle: **40 numerical-line/axes cases, 37 open/closed spline cases
  and 6 parametric-function cases**. Actual Lua execution passed **12,264
  scalar/invalid-input checks**, including transformed mappings and helper APIs.
- Sine/axes/dot reference image: mean absolute RGBA error **0.006761188271604939**,
  fraction of pixels with any channel error >16 **0.00020833333333333335**.
  Both are within the unchanged geometric comparison tolerance.
- Plot animation: **108 frames, 640×360, 24 fps, 4.5 seconds**. Full FFmpeg
  decode passed and the final frame was opened and visually inspected.
- Existing 282 geometry/animation cases, 42 frame comparisons, typography
  comparisons and actual media decoding passed as part of `make check` before
  the final source release.

## 0.2.0-dev — 2026-11-04 America/Mexico_City

- Lua regression suite: **14 groups, 309 checks passed**.
- Upstream differential fixture: **282 cases, 12,584 scalar comparisons
  passed**. All **42 geometric/animation frame pairs had zero pixel error**.
- Native Unicode text: **14 cases, 78 checks**; 13 match original upstream,
  one records the original standalone-RTL clipping discrepancy and instead
  validates its glyphs against a specifically corrected Pango layout reference.
  This is not counted as complete original-upstream parity.
- Text images: 13 original references and one diagnostic reference passed;
  maximum measured RGBA MAE **0.0017708333333333332** on [0,255].
- Actual PNG, MP4, GIF and WebM outputs: decoded 160×90 motion fixtures,
  five frames each for the three animated formats, with strictly increasing
  measured object x-centers. PNG alpha contained both 0 and 255.
- Typography example: **84 frames, 640×360, 24 fps, 3.5 seconds**. FFprobe and
  full FFmpeg decoding passed, and the final PNG was opened and inspected.
- ASan/UBSan regression and native text suites passed. Leak detection disabled;
  system Lua/Cairo/Pango libraries were not rebuilt with instrumentation.

Clean source build verification for this version is recorded by its release
verification JSON and log after execution.

## 0.1.0-dev — 2026-11-04 America/Mexico_City

Environment: Linux/Arch, Lua 5.4.9, Cairo 1.18.6, Pango 1.58.2. Native C11
module built with `-Wall -Wextra -Werror -Wpedantic`.

Executed before final release verification:

- Initial Lua regression: 12 groups, 295 checks passed.
- Real Manim 0.22.1 generated 80 object, 100 rate-function, 60 path and
  30 animation-state cases.
- Lua differential execution: **270 cases, 11,984 scalar comparisons passed**,
  absolute tolerance 1e-9.
- **30 actual Lua/Cairo frames versus upstream Cairo frames passed**, with
  maximum measured mean absolute channel error **0**.
- Actual geometric example: **108 frames, 640×360, 24 fps, 4.5 seconds**.
  FFprobe confirmed dimensions/count/rate; FFmpeg decoded the complete video.
- Final still was opened and visually inspected.

The upstream comparison exposed and led to fixes for the VMobject bounding
semantics and Ellipse's inherited red default; assertions were retained.

Follow-up verification:

- Expanded regression suite: **13 groups, 302 checks passed**.
- ASan/UBSan-instrumented native backend executed those same 13 groups and
  302 checks successfully. Leak detection was disabled; Lua and system Cairo
  dependencies were not rebuilt with instrumentation.
- Final `make check`: regression, actual demo export/decode, 270 differential
  cases and all 30 visual comparisons passed.

Source-tarball verification: `make release` extracted the source-only archive,
verified every manifest checksum, compiled a fresh native module and passed
`make check` in the extracted directory. The clean build used the extracted
Lua and C module paths, with inherited `LUA_PATH`/`LUA_CPATH` removed.
Upstream TeX, SVG, 3D,
OpenGL and other unimplemented subsystems have no compatibility claim.
