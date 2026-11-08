Three-dimensional scenes
================================================================================

Use ``ThreeDScene`` to get a perspective camera. Camera angles are radians;
multiply degrees by ``DEGREES`` when that is more convenient. ``phi`` controls
polar tilt, ``theta`` azimuth and ``gamma`` roll.

.. luanimath-example:: three_d
   :alt: A blue cube and a checkerboard sphere viewed by a moving perspective camera.
   :video:

``move_camera`` animates orientation, zoom, focal distance or frame center.
``add_fixed_in_frame_mobjects`` adds overlays that stay in camera coordinates.
For a 2D moving camera, use ``MovingCameraScene`` and animate ``camera.frame``.

Surfaces
--------------------------------------------------------------------------------

``Surface(fn,opts)`` maps a parameter grid through ``fn(u,v)``. Each result is a
finite 2D/3D point. Resolution controls face counts, not pixel size. Curved faces
use the upstream finite-difference cubic construction. ``should_make_jagged``
uses straight face edges. ``Sphere`` supplies a spherical parameterization;
``Cube`` constructs six vector faces.

Cairo sorts faces by depth and applies per-face lighting gradients. This is
the implemented vector rendering backend. OpenGL, textures, full clipping and
other 3D families remain pending. A point exactly on the camera’s focal plane
is rejected. Surface ``u_index``/``v_index`` metadata stays zero-based to match
upstream; Lua sequences use ordinary 1-based indices.
