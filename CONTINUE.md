# Development state

Current project name and directory: **luanimath**, `/mnt/datos/luanimath`.
Lua entrypoint: `require('luanimath')`; CLI: `tools/luanimath.lua`.

0.8 is a clean-verified historical release. 0.8.1 renames the module tree,
native ABI, CLI, examples, caches and source package. Its complete regression
suite passed; clean source packaging remains the release gate.

Mathematical typography is next. Native Typst 0.15.1 is installed under
/mnt/datos/Tools and available as `typst`. The development oracle uses
`typst-py` 0.15.2, which embeds the same Typst 0.15.1 engine. An actual formula
produced byte-identical CLI/oracle SVG. Private native compilation/cache and
SHA-256 are working; public Typst/MathTypst objects, labeled selection,
stroke-width scaling and compatibility tests remain in progress.

Continue from ROADMAP.md. Preserve existing releases and actual evidence.
No overall parity percentage or production readiness is claimed.
