# Development state

Project: luanimath, /mnt/datos/luanimath.
Public repository: https://github.com/48hoursnonstop/luanimath
English: https://48hoursnonstop.github.io/luanimath/en/
Spanish: https://48hoursnonstop.github.io/luanimath/es/

0.8.2 is published; its bilingual GitHub Pages deployment was verified live.
0.9.0 adds native Typst math with actual differential/rendered tests and
English/Spanish tutorials/reference. Full make check, nine ASan/UBSan suites
and both strict manuals passed. The source package clean rebuild and GitHub
publication are the current release gate; inspect releases for actual results.

The formula corpus has 44 original states and 10 capture parser cases; six
original SVG-cache states lose baseline/stroke tracking upstream. Lua retains
tracking. Preserve those original mismatches and their separately diagnosed
use_svg_cache=False data. Do not count diagnostics as original compatibility.
The actual Lua suite has 63,893 checks; 38 original and six diagnostic images
measured zero error. Native Typst 0.15.1 is under /mnt/datos/Tools, with a
user PATH symlink. typst-py 0.15.2 embeds the same engine for the dev oracle.

Continue dependency-ordered development after release: numerical scales,
coordinate labels, remaining plots, native TeX adapter, SVG/assets and
matching-expression transforms. Maintain English and Spanish API contracts,
tutorials and real rendered examples as features grow. No overall completion
percentage is claimed: availability is currently 211/5155 symbols (4.09%),
205 partial plus six verified, with all limitations recorded.

The user authorized continued work through available usage and public GitHub
updates. Preserve immutable prior archives and actual evidence.
