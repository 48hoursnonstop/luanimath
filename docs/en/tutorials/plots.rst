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
It does not rebuild the axes or the whole scene. Automatic numeric labels and
specialized statistical plots remain pending.

Linear and logarithmic scales
--------------------------------------------------------------------------------

``LinearBase{scale_factor=2}`` multiplies numerical values and divides them in
the inverse map. ``LogBase{base=2}`` maps exponents to powers and uses a
logarithmic inverse. Call ``scale:map(value)`` / ``scale:inverse(value)`` with
scalars or nested numerical tables. Every input/result must be finite;
logarithmic inverse inputs must be positive. Bases are positive and different
from 1; linear factors are nonzero. Fractional bases and negative linear factors
are supported. Lua rejects mixed positive/nonpositive logarithmic arrays,
including cases where upstream's array-domain check yields NaN instead.

.. code-block:: lua

   local ax = l.Axes {
       x_range = {0,4,1}, y_range = {-1,3,1},
       y_axis_config = {scaling=l.LogBase{base=2}}
   }
   local point = ax:c2p(2,4) -- y is the value 4, whose exponent is 2

Ranges remain in the unscaled domain: ``y_range={-1,3,1}`` produces ticks at
``{0.5,1,2,4,8}`` for base 2 without a tip; a tip suppresses the final tick.
Coordinates supplied to ``c2p`` / ``n2p`` are
the scaled values. Axis centering and the origin tick follow the pinned
upstream scale rules. ``get_origin()`` requests numerical zero and is therefore
undefined for a logarithmic coordinate; use positive coordinates explicitly.

``ParametricFunction(...,{scaling=scale})`` maps sample times before calling
the function. Its stored/getter function still accepts the actual parameter.
``Axes:plot`` inherits the x-axis scale so logarithmic x-ranges sample in
exponent space. The mapping continues to follow object transformations.

.. luanimath-example:: scales
   :alt: Base-two logarithmic axis with explicit formula labels and a moving dot.
   :video:

The example constructs labels explicitly with MathTypst and positions them
beside the axis. ``include_numbers`` and automatic LogBase custom labels remain
pending; the retained ``custom_labels`` field does not enable them yet.
