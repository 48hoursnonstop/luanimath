# Changelog

## 0.5.0-dev — unreleased checkpoint

Stopped at the user's 50% weekly-remaining limit. Development tests and native
sanitizers passed; the 0.5 source release and clean extraction/rebuild have
**not** been executed. The latest clean-verified packaged release is 0.4.0-dev.

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
