Troubleshooting
================================================================================

Lua cannot find luanimath or the native module
--------------------------------------------------------------------------------

Use ``lua5.4 tools/luanimath.lua`` from the source tree, or set the Lua module
paths described in :doc:`installation`. Rebuild with ``make``. Loading a module
built for Lua 5.4 into another Lua ABI is unsupported.

My shape has an outline but no fill
--------------------------------------------------------------------------------

Geometric shapes normally start with transparent fill. Set ``fill_opacity``
or call ``set_fill(color,opacity)``. Text and Dot use filled defaults.

Text layout or glyph count differs
--------------------------------------------------------------------------------

Check ``font_list()``, the requested family and installed font version. Ligatures
and combining marks mean that characters and glyphs need not correspond.
``disable_ligatures`` disables specific OpenType features, not every possible
font substitution. The standalone RTL mismatch is recorded in compatibility.

MP4 encoding fails
--------------------------------------------------------------------------------

Check that FFmpeg is available and width/height are even. The error retains its
generated frame directory. Verify the extension and output directory permissions.

An SVG feature raises an error
--------------------------------------------------------------------------------

Check :doc:`tutorials/svg` for the supported subset. Gradients, clipping, rounded
rectangles and embedded text/images are among the explicitly unsupported cases.

The final PNG differs from the final video frame
--------------------------------------------------------------------------------

The still captures the logical endpoint, while the encoded sequence samples
times strictly before each segment endpoint. This is intentional deterministic
sampling; see :doc:`configuration`.
