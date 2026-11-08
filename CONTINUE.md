# Development state

Project: luanimath, /mnt/datos/luanimath.
Public repository: https://github.com/48hoursnonstop/luanimath
0.8.1 is published with a clean-verified source archive and real example videos.
0.8.2 passed clean source extraction/rebuild/regression and both strict manuals;
the final package and GitHub Pages publication are being completed.

Active task: the user requires Manim-style documentation maintained alongside
the library, primarily in English and also in Spanish. The 0.8.2 manual has
261 function bindings (243 distinct + 18 aliases), 35 constants, reviewed
bilingual descriptions/parameters/options/results, tutorials and seven real
scene examples. Strict final builds passed 67 HTML pages and 5879 local links. Object-state
and return contracts are included. English/Spanish browser search worked.
GitHub Pages is enabled with workflow builds; publish the prepared workflow
and verify the actual public pages before reporting them as live.

One source-derived fix is included: Uncreate accepts remover=false; FadeOut
rejects explicit remover because upstream hardcodes that constructor keyword.
The actual upstream probe and Lua regression passed.

Then resume mathematical typography. Native Typst 0.15.1 is installed under
/mnt/datos/Tools; typst-py 0.15.2 embeds the same engine for the dev oracle.
A real formula produced identical CLI/oracle SVG. Private compilation/cache
and SHA-256 work; public Typst/MathTypst objects, labels, stroke scaling and
behavioral/visual tests are still pending.

The user authorized continued work through available usage. Preserve releases
and actual evidence; no overall completion percentage is claimed.
