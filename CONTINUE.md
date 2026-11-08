# Development state

Project: /mnt/datos/luanimath
Repository: https://github.com/48hoursnonstop/luanimath
Manuals: https://48hoursnonstop.github.io/luanimath/en/ and /es/

0.9.0-dev and 0.10.0-dev are published with clean-verified source, offline
manuals, verification reports and actual example videos. Pages deployment
42471245387 passed for 0.10, and the public logarithmic tutorial was verified.
The Typst compiler download uses the verified official asset API after HTTP504.

0.11.0 adds actual endpoint arcs, polygon rounding/Polygram/RoundedRectangle,
XY arc-center methods, endpoint placement and rounded SVG rx/ry. Complete
regressions and both strict manuals passed: 16,106 new checks, eleven exact
images; 283 function bindings, 109 constants, 73 HTML pages and 6729 links.
Ten real gallery scenes fully decode. Sanitizers and clean source release
are the current gate; inspect releases/logs for actual executed results.

Preserve the original rounding corpus differences and separate diagnostics:
one straight-arc undefined center, six degenerate-subdivision counts and four
closed-circle endpoint placements. Eleven images match the originals exactly,
but those eleven behavioral differences are NOT original parity passes.
The Typst corpus separately retains six cache-tracking differences, plus the
older single standalone RTL layout difference. Never fold these into parity.

Next dependency work: more animation families (growth, transforms and state
restoration), SVG/assets, automatic coordinate labels, native TeX adapter and
matching-expression transforms. Keep English/Spanish docs with every API.

Availability: 227 non-palette symbols (221 partial, six verified), plus 89
verified RGB color constants. Do not report constant counts as engine progress
or imply global completion. Source execution remains Lua + native libraries;
Python is development-only. Preserve immutable prior release archives.

The user authorized continued autonomous work through available usage and
public GitHub publication. There is no remaining 50-percent quota restriction.
