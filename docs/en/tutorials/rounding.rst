Circular arcs and rounded polygons
================================================================================

``ArcBetweenPoints(start,finish,opts)`` creates actual cubic circular geometry
with the requested endpoints. ``angle`` defaults to PI/2; a signed ``radius``
overrides it and must have magnitude at least half the chord length. Negative
radii reverse orientation. Zero angle gives a line. Use Circle for a complete
turn; an endpoint arc with an exact full-turn angle is rejected.

.. code-block:: lua

   local arc = l.ArcBetweenPoints({-2,-1},{2,1},{angle=2,color=l.YELLOW})
   local shape = l.RoundedRectangle {
       width=4, height=2, corner_radius=.4, fill_opacity=.3
   }

Round an existing polygon
--------------------------------------------------------------------------------

``polygon:round_corners(radius,opts)`` replaces closed vertex groups with cubic
arcs and connecting lines. Negative radii give concave corners. Cutoffs are
clamped to half the shorter neighboring edge so large radii stay bounded.
``components_per_rounded_corner`` defaults to two anchors (one cubic).
``evenly_distribute_anchors=true`` subdivides remaining straight edges according
to the mean corner-curve length. Construction is limited to 100,000 curves;
very small radii with dense subdivision can exceed that limit.

A radius table repeats for each loop; its length must divide the vertex count,
following upstream's strict iteration. ``Polygram({loop1,loop2},opts)`` constructs
multiple closed loops in one Mobject. ``get_vertices`` returns cubic start
anchors; ``get_vertex_groups`` collects them into closed loops. Rounded curves
contribute anchors, so these are not an immutable copy of the original vertices.

.. luanimath-example:: rounding
   :alt: Rounded corners change curvature while a dot follows a circular arc.
   :video:

Centers and endpoint placement
--------------------------------------------------------------------------------

``get_arc_center`` intersects tangent normals of the first cubic in XY.
``move_arc_center_to(point)`` translates that computed center; ``stop_angle``
returns the final polar angle modulo 2*pi. Undefined or nonplanar intersections
return ORIGIN and set ``_failed_to_get_center``. This is not a general 3D circle
fit. A collapsed arc returns its point.

``put_start_and_end_on`` scales, rotates and translates open geometry. A closed
loop shifts its starting point and keeps its size. Endpoint placement recognizes
closure within the existing 1e-6 point tolerance. It excludes circular open arcs
from that test, preserving small sweeps.

Recorded source differences
--------------------------------------------------------------------------------

The corpus retains all original upstream states. One straight arc gets a
spurious center near 6e15 upstream; Lua reports the undefined-center fallback.
Six clamped-rounding cases acquire extra degenerate curves through
``ceil(positive roundoff)`` upstream. Lua adds no subdivisions to gaps <=1e-12;
separate comparisons remove only geometrically zero-length curves and verify
the remaining geometry. Four closed-circle endpoint placements amplify tiny
closure roundoff upstream; separate diagnostics execute its intended shift.
These eleven original differences are asserted and are not counted as original
behavioral parity. All eleven rendered reference images match exactly in the
recorded environment. See :doc:`../compatibility`.
