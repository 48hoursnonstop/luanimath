Objects, vectors and groups
================================================================================

Scene coordinates use x to the right, y upward and z out of the screen. The
default world frame is 128/9 units wide and 8 high. ``l.vec(x,y,z)`` creates a
vector; missing components are zero. Vectors support addition, subtraction,
scalar multiplication and division. ``RIGHT``, ``UP`` and other constants are
vectors, so ``2*l.RIGHT + l.UP`` describes a point or displacement.

Mobjects
--------------------------------------------------------------------------------

Every visible shape is a Mobject. A VMobject stores cubic vector geometry;
geometric constructors supply its initial points. Style uses RGB(A) colors,
separate fill/stroke alpha and a stroke width. Filling a shape requires nonzero
``fill_opacity``. Most editing methods return the object for chaining.

Groups share their children
--------------------------------------------------------------------------------

``VGroup(a,b,c)`` stores the actual objects, rather than copies. Moving the group
moves each unique descendant once. ``copy()`` creates an independent object
graph while preserving shared relationships inside that copy.

.. luanimath-example:: objects
   :alt: A red circle, blue square and green triangle, with two shapes shifted upward.

``group[1]``, ``#group`` and ``ipairs(group)`` use Lua’s 1-based sequence
conventions. An object with its own points includes itself first, followed by
its children. ``slice(2,3)`` returns a group sharing the selected objects, so
its transformations affect the originals. Slice endpoints are inclusive and
negative indices count from the end.

Pivot and dimensions
--------------------------------------------------------------------------------

``scale`` and ``rotate`` default to the object center; ``about_point`` or
``about_edge`` changes the pivot. ``apply_matrix`` instead defaults to the
origin. Dimensions include Bézier controls, while critical boundary points
use vector anchors. Stroke widths do not grow when geometry is scaled.
