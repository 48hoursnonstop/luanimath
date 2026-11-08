# Development state

Project: /mnt/datos/luanimath
Repository: https://github.com/48hoursnonstop/luanimath
Manuals: https://48hoursnonstop.github.io/luanimath/en/ and /es/

0.12.0-dev is published: source SHA
49e443d4d0cfdfbe11ecb312a0439483e6ed5d343e624a368f9e932998ab0a61.
Pages run 42510597797 passed and both live growth tutorials were verified.
Prior immutable releases retain clean-build reports, source/offline docs and videos.

0.13 adds target generation and nine transform factories plus nonlinear
Bézier mapping/handle scaling. Actual tests cover 72 cases/360 states, 20 direct
operations and 27 exact original images. The final transform suite has 145040
checks, maximum absolute error 4.4408920985006262e-11. Full regressions passed;
14 sanitizer suites passed before the final numeric-only nonvector fixture.
Both strict manuals passed with 300 function bindings, 109 constants, 75 pages,
7068 links and twelve real gallery scenes. Clean-source release/publication
are the current gate; inspect releases for actual completed verification.

Two source-derived corrections: Text parent paints now follow the base color;
transform alignment acts on the live subject before taking its starting copy.
Immediate become/restore now align families, preserve old identities and retain
extra faded children, matching upstream. ApplyMethod uses explicit Lua subject,
method name/unbound function and argument table (table.pack supports nil).
Deferred targets, captured target references, latest saved states and matrix
origin capture have frozen oracle cases. No new source mismatches in this corpus.

Next: Arrow/tip geometry and scaling with GrowArrow, remaining transforms,
SVG/assets, automatic numerical labels, native TeX and expression matching.
Preserve old diagnosed differences: eleven rounding cases, six Typst SVG-cache
tracking cases, one standalone RTL layout case. Diagnostics are not original parity.

Availability: 245 non-palette symbols (239 partial, six verified), plus 89
verified RGB constants. No overall project-completion percentage is claimed.
Runtime is Lua/native libraries; Python is development-only. User authorized
continued autonomous work through available usage and public GitHub publication;
the prior 50-percent restriction was revoked. Preserve immutable release archives.
