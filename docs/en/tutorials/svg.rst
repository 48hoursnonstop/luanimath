SVG and cubic paths
================================================================================

``SVGMobject(filename,opts)`` decodes a real SVG file. The default centers its
geometry and fits height 2. Set ``height=false`` to preserve source size, or
``should_center=false`` to preserve the importer’s source positioning.

.. luanimath-example:: svg
   :alt: Two imported blue glyph-like shapes beside a yellow cubic path.

The supported elements are path, line, rectangle, circle, ellipse, polygon and
polyline. Groups, affine transforms, local ``use`` references and named ID
lookup work. Fill/stroke paints accept named CSS colors, hex and RGB forms.
``id_to_vgroup_dict`` contains identity-sharing groups for imported IDs.

``VMobjectFromSVGPath`` accepts command data directly. Quadratic segments are
elevated to cubics; elliptical arcs follow the pinned upstream approximation.
Ordinary VMobjects also provide line, quadratic and cubic path builders.

Compatibility boundaries
--------------------------------------------------------------------------------

The importer follows Manim’s root viewBox/transform discard, byte alpha rounding
and ignored group-opacity behavior. Rounded rectangles, stylesheet rules,
gradients, clipping, masks, filters, physical/percentage units and SVG-embedded
text/images are not implemented. Unsupported drawing features raise errors.
Local references work; external references and DTD declarations are rejected.
SVG input is limited to 16 MiB and bounded tree/reference depth.
