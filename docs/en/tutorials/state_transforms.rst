Targets, saved state and point transforms
================================================================================

``save_state`` stores a deep geometry/style snapshot. ``restore`` applies it
immediately; ``Restore`` animates the change. ``generate_target`` creates and
returns a separate editable copy. ``MoveToTarget`` animates to that copy.

.. code-block:: lua

   local object = l.Square {color=l.BLUE,fill_opacity=.4}
   object:save_state()
   object:generate_target():shift(l.RIGHT*2):set_color(l.TEAL)
   s:play(l.MoveToTarget(object))
   s:play(l.Restore(object))

Each ``generate_target`` replaces the previous target and prevents an accumulating
chain of old targets. ``MoveToTarget`` captures the target object at construction:
editing that object before begin changes its destination, while generating a
different target later does not replace the captured one. ``Restore`` reads the
latest saved state at begin. Repeated saves replace the old snapshot.

Restoration keeps the subject's identity, kind and updater functions. ``become``
aligns both families before copying points/styles; it can mutate the other
hierarchy. When a group grew after saving, extra children remain as aligned,
transparent children, following upstream. Restoration does not delete them.

Methods and callbacks
--------------------------------------------------------------------------------

``ApplyMethod(object,"set_fill",{l.PURPLE,.6},options)`` applies a method to a
deep copy when the animation begins. Lua uses an explicit subject, method name
and argument table in place of Python bound methods. An unbound function is
also accepted: its first argument is the copy. Use ``table.pack`` when arguments
contain trailing nil values. Method return values are ignored, as upstream.

``ApplyFunction(fn,object,options)`` instead requires ``fn(copy)`` to return a
Mobject. It may return a different hierarchy. Target creation occurs once at
begin; moving the subject after constructing the animation changes the starting
geometry used by these callbacks. Returning nil raises an error.

``FadeToColor``, ``ScaleInPlace`` and ``ShrinkToCenter`` use this same deferred
target construction. Negative and zero scales are supported. Shrink leaves the
degenerate subject in the scene unless ``remover=true``.

.. luanimath-example:: state_transforms
   :alt: A saved rounded rectangle changes target, shears, warps, recolors and restores.
   :video:

Pointwise mapping and matrices
--------------------------------------------------------------------------------

``ApplyPointwiseFunction(fn,object,options)`` applies a finite 2D/3D point mapping
to a copy. ``ApplyMatrix(matrix,object,{about_point=...})`` accepts 2x2 or 3x3
matrices; 2x2 leaves z unchanged. Their default duration is three seconds. The
matrix is copied at construction; a supplied about-point table is read when
the target is generated.

For an immediate change, call ``object:apply_function(fn)``. Vector objects
temporarily shorten Bézier handles before mapping, then expand them to preserve
tangent behavior. ``pre_function_handle_to_anchor_scale_factor`` defaults to
.01, or 1e-5 for Surface. It must be finite and nonzero when mapping.
``make_smooth_after_applying_functions=true`` rebuilds smooth handles afterward.
``scale_handle_to_anchor_distances(factor)`` exposes handle scaling directly.

These mappings require complete cubics or one-point vector objects; a pending
anchor after a complete curve is rejected. Non-vector Mobjects use direct point
mapping. Immediate callbacks mutate geometry as they run; errors do not promise
transactional rollback. Match-size ``become`` options and the full upstream
transform family remain pending; check the reference and compatibility records.
