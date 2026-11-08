# Development state

Project: /mnt/datos/luanimath
Repository: https://github.com/48hoursnonstop/luanimath
Manuals: https://48hoursnonstop.github.io/luanimath/en/ and /es/

0.14.0-dev is published: source SHA
4d93d1ba0a93fd02a82e71e6b830a4d502ec9b31f90c173fb3d0ab91022ebba5.
Source/offline-docs release assets and all checksums are uploaded. Pages run
42514087790 passed; English and Spanish Arrow tutorials were verified live.
All previous immutable releases retain source/offline docs, reports and videos.

0.14 adds Arrow, triangular tips and GrowArrow with real buffered 2D/3D geometry,
fixed-tip and whole-tip scaling, length limits, normals and detach/reattach.
84 states, twelve growth traces, eight standalone tip cases, 14425 checks and
eight exact original images passed. Six Z-pole fixed-tip azimuth differences
are asserted against retained originals; rigid registration diagnostics remain
separate. Negative 3D fixed-tip scaling retains source positioning-axis behavior.
Full regression and fifteen sanitizer suites passed. Strict bilingual manuals
passed 309 function bindings, 109 constants, 77 pages and 7363 links; thirteen
real gallery scenes fully decoded. The Arrow example camera was subsequently
adjusted for visible tip faces and rerendered/inspected. Clean source extraction, integrity checks, compilation, all regressions and
both strict manuals passed; the 0.14 source/archive/video release is public.
Working tree and release verification are complete at this checkpoint.

Architecture additions: private computed-property and scale/tip handlers extend
the common Mobject model. Generic group scaling remains generic, as upstream.
Native Vector remains the documented numeric alias; Arrow-derived Vector,
start/double tips, curved Arrow/tip families and remaining geometry are pending.
Continue with these foundations, assets, coordinate labels, native TeX and
expression matching; maintain English/Spanish docs with every feature.

Preserve old diagnosed original differences: six Arrow pole azimuth states,
eleven rounding cases, six Typst SVG-cache tracking states and one RTL layout.
Do not merge diagnostics into original parity counts. 0.13 deferred transforms,
state restoration and nonlinear mapping have their own exact numeric/visual corpus.

Availability: 260 non-palette symbols (254 partial, six verified), plus 89 RGB
constants. These are inventory counts, not overall project-completion estimates.
Runtime is Lua/native libraries; Python is development-only. User authorized
continued work through available usage and public GitHub publication. The old
50-percent restriction was revoked. Preserve immutable release artifacts.
