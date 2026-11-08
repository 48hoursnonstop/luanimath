Arrows and growing tips
================================================================================

``Arrow(start,finish,opts)`` builds a real buffered shaft and triangular end tip
in two or three dimensions. Defaults are LEFT to RIGHT, endpoint ``buff=.25``,
stroke width 6 and requested tip length .35. Tip length and shaft width are
limited by ``max_tip_length_to_length_ratio=.25`` and
``max_stroke_width_to_length_ratio=5``. Ratios are nonnegative.

.. code-block:: lua

   local arrow = l.Arrow({-2,-1,0},{2,1,0},{buff=0,color=l.BLUE})
   s:play(l.GrowArrow(arrow))
   arrow:scale(2) -- keep the actual tip identity and size
   arrow:scale(.5,{scale_tips=true}) -- include the tip in geometric scaling

Scaling and tip identity
--------------------------------------------------------------------------------

Scaling the Arrow itself normally detaches its tip, scales the complete shaft,
then reattaches the same tip object. The shaft width is recalculated from its
initial width and current length. ``scale_tips=true`` scales tip geometry too.
Scaling a parent VGroup uses the group transformation and scales child tips;
individual Arrow overrides are not independently invoked.

``GrowArrow`` captures the tail at construction and collapses both shaft and tip
there in its starting snapshot. ``point_color`` and normal animation options
work. This differs from ordinary center growth, which invokes fixed-tip scaling.

.. luanimath-example:: arrows
   :alt: Two arrows grow in 3D, change scale and remain visible during camera movement.
   :video:

Tip objects and helpers
--------------------------------------------------------------------------------

``ArrowTriangleFilledTip`` is the default. Use ``tip_shape=l.ArrowTriangleTip``
for an outlined triangle. Both constructors accept ``length``, ``width`` and
normal vector-style options. ``tip_style`` on Arrow overrides the tip's style.
Both zero-length arrows and zero-sized tips have real geometry and test cases.

Tip ``base``, ``tip_point``, ``vector``, ``tip_angle`` and ``length`` are computed
read-only properties. ``base`` is the halfway point along the outline path.
``has_tip`` checks actual child membership. ``pop_tips`` returns a VGroup sharing
the detached tip and restores the complete shaft. Reattach it with
``arrow:add_tip{tip=tip}``. The inactive ``arrow.tip`` reference can remain after
popping, following upstream. ``get_normal_vector`` reads current tip geometry;
``reset_normal_vector`` updates the stored normal metadata.

Compatibility boundaries
--------------------------------------------------------------------------------

Starting tips, square/circle/stealth tips, curved Arrow constructor paths and
the complete inherited option surface remain pending. ``Vector`` still names
the existing numeric vector alias; use Arrow explicitly.

Six original fixed-tip scale states for shafts parallel to Z choose different
tip azimuths because tiny projected components influence atan2. Original arrays
remain in the corpus, and their mismatches are asserted. Separate rigid tip
registration compares shape, endpoint, style and length; it is not an original
orientation-compatibility pass. General 3D orientation and the eight rendered
Arrow/GrowArrow references match unmodified upstream in the recorded environment.
Angles are compared modulo 2*pi, including the equivalent signed-pi boundary.
Negative 3D fixed-tip scaling follows upstream's retained positioning-axis
behavior; use ``scale_tips=true`` to geometrically invert the whole tip.
