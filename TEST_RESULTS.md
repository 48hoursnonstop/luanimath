# Executed test results

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
