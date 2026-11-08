Animation and time
================================================================================

``Create`` reveals paths; ``Write`` draws outlines then fills and staggers text
glyphs. ``FadeIn`` and ``FadeOut`` change transparency. ``Transform`` aligns
vector families before interpolating, retaining the source identity.
``ReplacementTransform`` installs the actual target when finished.

Builders and composition
--------------------------------------------------------------------------------

Use ``object:animate():shift(...):rotate(...)`` inside ``Scene:play`` to describe
a target. Multiple arguments to ``play`` run together. Its final table can set
``run_time``, ``rate_func`` and ``lag_ratio``. ``AnimationGroup({a,b})`` accepts
a sequence; ``LaggedStart`` staggers it and ``Succession`` runs it consecutively.
Succession requires forward evaluation; other groups support backward easing.

.. luanimath-example:: paths
   :alt: A yellow point moving along a blue cubic Bézier path.
   :video:

Frames and updaters
--------------------------------------------------------------------------------

Each segment samples times ``k/fps`` strictly before its duration, then finishes
at the logical endpoint. The final still can differ from the last encoded
frame. Nonintegral frame durations use the rounded-up number of frames.

An updater receives ``fn(object,dt)``. Animate a ``ValueTracker`` and read it
from a callback to control derived geometry. ``always_redraw`` rebuilds an
object from a callback on update. Animations suspend subject updaters by default;
starting/target snapshots execute their own updaters.

Erasing objects
--------------------------------------------------------------------------------

``Uncreate`` and ``Unwrite`` normally remove their subjects. ``Uncreate`` accepts
``remover=false`` to retain the degenerate final object. ``FadeOut`` always
removes its subject and rejects an explicit ``remover`` option, matching the
pinned upstream constructor. Reverse Write restores child order on finish.

Growth and spiral entry
--------------------------------------------------------------------------------

``GrowFromPoint(object,point,opts)`` introduces an object from a point;
``point`` can also be a Mobject whose center is read at animation begin.
``GrowFromCenter`` and ``GrowFromEdge(object,edge,opts)`` capture their origin
when constructing the animation. Moving the subject before ``begin`` therefore
changes its destination without changing those captured origins.

``point_color`` optionally sets the starting family color, interpolating back
to each original paint while preserving opacity. ``lag_ratio`` staggers
geometry-bearing family members, including actual text glyphs. Growth uses the
same deterministic snapshots, rate functions and updater suspension as Transform.
Subjects are added to the scene automatically; ``remover=true`` removes them at
completion. An explicit ``introducer`` option is rejected, matching upstream's
hardcoded constructor argument.

.. luanimath-example:: growth
   :alt: A title and three vector shapes enter from a point, edge, center and spiral.
   :video:

``SpinInFromNothing(object,{angle=PI/2})`` grows from the captured center with
spiral motion around OUT. Negative angles reverse it; a full turn is allowed
here. It supplies its own path and rejects an explicit ``path_func``.
``spiral_path(angle,axis)`` returns a general point-array path for Transform.
It rotates the source-to-target displacement by ``(alpha-1)*angle`` and scales
it by alpha; an angle with magnitude below .01 uses a straight path. Zero axes
fall back to OUT. General paths allow extrapolated alpha values; animations
still apply their normal time/rate-function rules. GrowArrow remains pending.
