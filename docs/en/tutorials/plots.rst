Plots and updaters
================================================================================

``NumberLine`` maps numerical values onto a transformed line. ``Axes`` combines
two such lines; numerical coordinates and scene coordinates are distinct. Use
``axes:coords_to_point(x,y)`` or ``axes:c2p(x,y)`` to position a scene object.
The inverse is ``point_to_coords`` or ``p2c``.

.. luanimath-example:: plots
   :alt: A yellow tracker-driven point on a blue sine curve and white axes.
   :video:

``axes:plot(fn,{x_range={minimum,maximum,step}})`` samples a scalar function in
that coordinate system. ``ParametricFunction`` instead expects ``fn(t)`` to
return a 2D/3D point. Results must be finite. Cubic smoothing is enabled by
default; set ``use_smoothing=false`` for straight sample connections.

Discontinuities
--------------------------------------------------------------------------------

ParametricFunction accepts ``discontinuities`` and positive ``dt``. It splits
the sampled path around each listed parameter rather than connecting across
the gap. Choose the step and exclusion radius for the function’s behavior.

The example animates a ValueTracker and rebuilds a Dot with ``always_redraw``.
It does not rebuild the axes or the whole scene. Native mathematical labels,
nonlinear coordinate scales and specialized statistical plots remain pending.
