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
