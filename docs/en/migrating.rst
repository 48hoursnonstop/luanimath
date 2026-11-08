Coming from Manim
================================================================================

The concepts are familiar; scene authoring follows Lua conventions. Import with
``local l=require('luanimath')`` and return ``l.Scene(function(s) ... end)``.
Constructors are functions receiving option tables, and object methods use
colon calls. There is no Python interpreter in scene execution.

.. list-table::
   :header-rows: 1

   * - Manim concept
     - Lua form
   * - A Scene subclass with construct
     - ``Scene(function(s) ... end)``
   * - Keyword arguments
     - ``Square{color=l.BLUE,fill_opacity=.5}``
   * - A group of objects
     - ``VGroup(a,b,c)``
   * - Polygon vertices
     - ``Polygon({a,b,c})``
   * - Animation builder
     - ``m:animate():shift(l.RIGHT)``
   * - play keyword options
     - ``s:play(animation,{run_time=2})``
   * - Python None for SVG height
     - ``height=false``
   * - A character/glyph slice
     - ``text:slice(1,3)``; inclusive Lua endpoints

Numeric arrays and dimensions use 1-based Lua indices. Bracket selector strings
inside text style maps retain upstream’s zero-based/exclusive grammar. Surface
u/v index metadata also retains upstream numbering. Angles remain radians.

What to check before porting a scene
--------------------------------------------------------------------------------

Read :doc:`compatibility` and look up each constructor’s supported options.
An exported class/factory name does not imply its complete upstream behavior.
MathTex/Tex, raster images, OpenGL, audio and many specialized families remain
pending. ``Vector`` currently aliases the numeric ``vec`` constructor; it is
not the upstream arrow Mobject.

Transform operates on real aligned vector families. Text glyph grouping,
ligatures and source font versions affect animation and layout. Plain Text has
a documented natural-width RTL difference. SVG follows several upstream importer
quirks instead of claiming complete SVG standards support.
