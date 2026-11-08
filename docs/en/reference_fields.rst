Object state and render results
================================================================================

Type notation
--------------------------------------------------------------------------------

``vector`` means a three-component Lua vector; point inputs commonly also accept
plain two-/three-component tables. ``color`` accepts the supported named/hex or
unit component forms. ``RGBA`` is a four-component table in [0,1]. ``T[]`` denotes
a Lua sequence of T, and fixed lengths such as ``vector[4]`` describe cubic
control arrays. These are documentation types, not additional constructors.

Mobject data
--------------------------------------------------------------------------------

* ``points``: vector array. Vector geometry stores four points per cubic and
  may end in one pending anchor. Use the path API to retain these invariants.
* ``submobjects``: direct-child sequence. ``add`` prevents cycles and duplicate
  direct identities; children can be shared between groups.
* ``fill_color`` / ``stroke_color``: normalized four-component RGBA tables.
  The supported setters validate components and preserve unspecified values.
* ``stroke_width``: nonnegative stroke width, unchanged by geometric scaling.
* ``z_index``: finite render-order key. 3D depth precedes it when applicable.
* ``updaters``: callbacks receiving the object and elapsed logical seconds.
* ``kind``: conceptual type name; ``is_vector`` indicates vector geometry.

Text
--------------------------------------------------------------------------------

``Text.chars`` and ``MarkupText.chars`` are VGroups sharing the actual glyphs.
``original_text`` retains the supplied string. ``font`` identifies the requested
font family. ``font_size`` is a computed read/write property: scaling geometry
changes its measured size, and assigning a positive size rescales the geometry.
Font-size queries on empty text are rejected.

Scenes and cameras
--------------------------------------------------------------------------------

``scene.mobjects`` is the ordered scene-root list. ``scene.camera`` is the active
camera, ``time`` the logical time and ``frame_count`` the number of sampled
frames. ``scene.config`` holds resolved options. ``camera.frame`` is the view
rectangle; MovingCameraScene animates it directly. ThreeDCamera additionally
has orientation, focal-distance and zoom ValueTrackers.

RenderReport
--------------------------------------------------------------------------------

``Scene:render`` returns a table:

* ``output``: requested output filename.
* ``frame_count``: number of generated frames.
* ``duration``: encoded duration, equal to frame_count/frame_rate.
* ``scene_time``: final logical scene time.
* ``frame_dir``: retained temporary directory when keep_frames is enabled.

The generated final PNG contains the logical endpoint, which can differ from
the last encoded sample. See :doc:`configuration`.

Typst objects
--------------------------------------------------------------------------------

``typst_code`` stores the compiled source, with math delimiters/capture helpers
when applicable. ``typst_preamble`` stores the effective preamble. With
``track_baselines=true``, ``baseline_frames`` is a newly computed sequence of
three-point affine frames for nondegenerate imported leaves. ``get_baseline_frame``
returns the origin, x-axis endpoint and y-axis endpoint as three values.
Point-count changes invalidate that leaf's reference; nonlinear deformations
are outside the affine tracking contract.

``font_size`` follows upstream's 960-times-relative-height measurement. Explicit
``height`` bypasses initial font scaling; changing ``font_size`` scales the whole
object. Zero-height objects cannot report a meaningful font size. Unlike normal
geometry, unoverridden Typst stroke widths are refreshed when scaling the root.
``select`` returns a VGroup sharing the actual leaves; styling it changes the
formula. Numeric capture indices start at 1; explicit names remain strings.

``m.color`` / ``m:get_color()`` returns an opaque RGB color, choosing visible
fill before stroke; an object with both paints equal to transparent black
returns nil. Assigning ``m.color`` applies ``set_color`` to its family.
