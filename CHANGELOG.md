# Changelog

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
