Your first scene
================================================================================

A scene file returns a Scene constructed from a Lua callback. The scene calls
that function when you render. Add visible objects with ``s:add`` and schedule
animations with ``s:play``. Every duration is measured in seconds.

This complete example creates a square, then moves and rotates it:

.. luanimath-example:: quickstart
   :alt: A filled blue square moved right and rotated by forty-five degrees.
   :video:

Save the code as ``scene.lua`` and run:

.. code-block:: console

   lua5.4 tools/luanimath.lua scene.lua --output animation.mp4 --width 640 --height 360 --fps 24

An animation builder works on a copied target. The square changes when
``s:play`` evaluates the builder. The square keeps its identity, so later
operations can keep using the same variable.

The command also saves a PNG of the final logical state. Use ``--output image.png``
for a still image. See :doc:`../configuration` for timing and output details.
