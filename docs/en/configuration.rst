Configuration, CLI and output
================================================================================

The CLI accepts one scene file returning a Scene:

.. code-block:: console

   lua5.4 tools/luanimath.lua scene.lua --output scene.mp4 --width 640 --height 360 --fps 24
   lua5.4 tools/luanimath.lua scene.lua --output scene.png
   lua5.4 tools/luanimath.lua scene.lua --output scene.gif --keep-frames

Supported options are ``--output``, ``--width``, ``--height``, ``--fps`` and
``--keep-frames``. Unknown options and missing values are errors. Width and
height here are pixel dimensions. Set world dimensions in the Scene constructor
or its programmatic ``render`` options.

Defaults and precedence
--------------------------------------------------------------------------------

Configuration is resolved from ``l.config.defaults``, constructor options, then
render-time options. Defaults are 854×480 pixels, 30 fps, world width 128/9,
world height 8, black background and opacity 1. Pixel resolution does not
automatically change the world aspect ratio. ``frame_center`` positions the
camera. Colors accept supported Manim names, RGB(A) hex or unit component tables.

``render`` returns a report containing ``output``, ``frame_count``, ``duration``
and ``scene_time``. ``frame_dir`` is included when frames are retained. Encoded
duration equals frame count divided by fps and may differ from logical time
when segment durations are not integer frame counts.

Formats and retained files
--------------------------------------------------------------------------------

PNG stores the final logical state and supports checked transparency. MP4 uses
H.264/yuv420p and needs even pixel dimensions. GIF and WebM are also encoded by
FFmpeg. Encoded-format alpha fidelity has less coverage than PNG transparency.

Frames use a unique temporary directory beside the output. Successful rendering
removes its own directory unless retained; a failed render keeps it for diagnosis.
Encoded output also writes a final PNG, whose path can be changed with
``last_frame``. Audio, caching of scene segments and upstream quality presets
remain pending.
