Text, glyphs and markup
================================================================================

``Text`` shapes UTF-8 through Pango and imports real vector glyphs. Set a font
family explicitly when repeatable layout matters. Text has fill opacity 1 and
stroke width 0 by default. The public font size defaults to 48.

.. luanimath-example:: text
   :alt: Bold and italic luanimath text above a blue-to-green sentence.
   :video:

Selecting and styling text
--------------------------------------------------------------------------------

``text.chars`` shares the actual glyph objects. ``text:slice(1,3)`` selects the
first three glyphs with inclusive Lua indices. Ligatures can combine multiple
characters into one glyph. ``disable_ligatures=true`` disables the supported
OpenType ligature features and inserts invisible whitespace objects in Text.
Some fonts can still combine characters through other shaping features.

Text style maps use literal substrings or Manim-style bracket selectors:
``t2c`` colors, ``t2f`` fonts, ``t2s`` slants, ``t2w`` weights and ``t2g`` gradients.
The long names are ``text2color``, ``text2font``, ``text2slant``, ``text2weight``
and ``text2gradient``; they take precedence over short names. Unlike Lua slices,
selector strings such as ``"[0:3]"`` use zero-based starts and exclusive ends.
Negative selector bounds count from the end. Unsupported out-of-bounds ranges
and empty selectors raise an error.

Styles on different attributes may overlap; conflicting nondefault styles on
the same attribute raise an error. Each style run is shaped independently,
matching upstream kerning and ligature boundaries. ``gradient={RED,BLUE}``
creates per-character color runs. Changing ``text.font_size`` scales existing
geometry; it does not reshape the font.

MarkupText
--------------------------------------------------------------------------------

``MarkupText`` accepts Pango markup such as ``<b>``, ``<i>``, ``<u>``, ``<s>``,
``<sup>``, ``<sub>`` and nested ``<span>`` attributes. Escape literal XML special
characters with ``&amp;``, ``&lt;`` and ``&gt;``. Invalid markup is rejected.
Pango controls paragraph layout, using the pinned upstream width of 500 units.

The deprecated Manim-specific color/gradient tags are not implemented. Plain
Text uses natural-width shaping; the documented standalone Arabic clipping
difference from upstream remains. Markup has its own tested RTL paragraph case.
