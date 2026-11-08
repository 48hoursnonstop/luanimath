Mathematical expressions with Typst
================================================================================

Install the native Typst CLI and check ``typst --version``. Version 0.15.1 is
the tested reference. This optional dependency compiles formulas to SVG; the
library imports their actual paths and renders/animates them through Lua/Cairo.
Python is not involved. ``MathTex`` and ``Tex`` remain pending.

Create and select a formula
--------------------------------------------------------------------------------

.. code-block:: lua

   local l = require('luanimath')
   local equation = l.MathTypst('{{ a^2+b^2 : lhs }} = {{ c^2 }}', {
       font_size = 72, track_baselines = true
   })
   equation:select('lhs'):set_color(l.BLUE)
   equation:select(1):set_color(l.YELLOW)

The expression uses Typst math syntax: ``frac(a,b)``, ``sqrt(x)``,
``sum_(k=1)^n k`` and ``mat(1,2;3,4)``. It is not a LaTeX parser.
``Typst`` accepts document content instead, including markup and explicit math
delimiters: ``l.Typst('*Title* and $x^2$')``. ``typst_preamble`` adds document
definitions or style settings before the body.

``{{ body : label }}`` marks a named capture. ``{{ body }}`` marks an unnamed
capture, selected with Lua indices starting at 1. Named captures do not consume
the unnamed index counter. Nested and repeated labels are supported. Selection
returns a VGroup sharing the real leaves; color changes and animations affect
the original expression. Known captures containing only hidden content return
an empty group. Unknown names raise an error. Ordinary Typst SVG labels can
also be selected by name.

Animate the actual outlines
--------------------------------------------------------------------------------

.. luanimath-example:: math
   :alt: Pythagorean captures and a sum written as real vector outlines.
   :video:

``Write`` and ``Transform`` use the existing vector-family machinery. Automatic
expression/token matching has not been implemented. A capture may contain
several glyphs or path leaves; the API does not promise one leaf per character.

Sizing, strokes and baselines
--------------------------------------------------------------------------------

The default ``font_size`` is 48. Explicit ``height`` follows upstream's special
sizing path and bypasses initial font scaling; see :doc:`../reference_fields`
for the computed property. Source stroke widths are adapted to the active
pixel/world ratio and refreshed when scaling the root. An explicit
``stroke_width`` opts out of that preservation.

With ``track_baselines=true``, ``equation.baseline_frames`` returns affine
reference frames of nondegenerate leaves after translation, rotation and
scaling. ``equation:get_baseline_frame(leaf)`` returns three vectors. Changing
a leaf's point count invalidates its reference. These frames reproduce the
pinned importer semantics; they are not a text-layout engine or nonlinear fit.

Compilation and cache
--------------------------------------------------------------------------------

``typst_bin`` or ``LUANIMATH_TYPST`` selects the native executable. ``font_paths``
adds compiler font directories; ``root`` sets its project root. Source and SVG
are cached under ``.luanimath-cache/typst`` by default. ``cache_dir`` changes
that directory and ``use_cache=false`` forces compilation. Failed compilation
raises an error and reports the compiler diagnostic.

The key includes generated source, compiler version, font-path strings and root.
Generated SVG checksums detect corruption. Changes to external files or font
contents require clearing the cache or forcing compilation. Lua retains stroke
and baseline tracking when importing cached SVG; the pinned upstream loses
those lists on some cache hits. Six original reference states preserve and
separately diagnose this intentional difference in :doc:`../compatibility`.

See :doc:`../reference/typst` for the supported constructor/helper options.
