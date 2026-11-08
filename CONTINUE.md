# Development state

Project: /mnt/datos/luanimath
Repository: https://github.com/48hoursnonstop/luanimath
Manuals: https://48hoursnonstop.github.io/luanimath/en/ and /es/

0.9.0-dev is published with source, offline manuals, math video and actual
clean build report. Source SHA d6bde43f12e6627e4483320f63d54a61b6a7d9c9ed69ecdaa971e9c14f430d16.
Pages build/deploy run 42470400108 passed; both math tutorials were verified
HTTP 200 and contained the current API/video. A Typst download HTTP 504 was
resolved using the official asset API; the SHA-256 is still checked.

0.10.0 adds linear/logarithmic scales and all 89 Manim palette constants.
The final full regression suite passed. Scales: 20,602 checks; colors: 801.
Four new images and the existing sine plot now match exactly. The former tiny
plot mismatch was the wrong YELLOW constant, corrected to #F7D96F. Lossy-video
color detection now targets that source color, retaining frame/motion checks.
Both strict manuals passed with nine real gallery scenes, 273 function
bindings, 109 constants, 71 pages and 6437 links. Sanitizers and clean source
release verification are the current gate; inspect releases for actual results.

Next dependency work: rounded polygon geometry/ArcBetweenPoints and SVG rounded
rectangles, then broader SVG/assets, automatic coordinate labels, TeX and
matching-expression transforms. Keep English/Spanish docs alongside every API.

The 0.9 formula corpus retains six explicitly diagnosed original upstream
SVG-cache mismatches; do not treat their diagnostics as original parity. Native
Typst 0.15.1 and typst-py 0.15.2 use the same compiler engine. No Python runtime.

Availability: 217/5155 non-palette symbols available (211 partial, six verified),
plus 89 verified palette constants; do not report these as global completion.
The user authorized continued autonomous development through available usage,
with public GitHub updates. Preserve immutable releases and measured evidence.
