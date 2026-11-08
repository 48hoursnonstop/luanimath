Arcos circulares y polígonos redondeados
================================================================================

``ArcBetweenPoints(inicio,fin,opciones)`` crea geometría circular cúbica real
entre los extremos indicados. ``angle`` vale PI/2 por defecto; ``radius`` con
signo lo sustituye y su magnitud debe ser al menos media cuerda. Un radio
negativo invierte la orientación. Un ángulo nulo produce una línea. Usa Circle
para una vuelta completa; se rechazan ángulos de vuelta completa en este objeto.

.. code-block:: lua

   local arc = l.ArcBetweenPoints({-2,-1},{2,1},{angle=2,color=l.YELLOW})
   local shape = l.RoundedRectangle {
       width=4, height=2, corner_radius=.4, fill_opacity=.3
   }

Redondear un polígono existente
--------------------------------------------------------------------------------

``poligono:round_corners(radio,opciones)`` sustituye grupos cerrados por arcos
cúbicos y líneas. Los radios negativos crean esquinas cóncavas. Los recortes
se limitan a media arista adyacente más corta, manteniendo acotados los radios
grandes. ``components_per_rounded_corner`` vale dos anclas por defecto (una
cúbica). ``evenly_distribute_anchors=true`` subdivide los lados restantes según
la longitud media de las curvas. La construcción se limita a 100,000 curvas;
un radio muy pequeño con subdivisión densa puede exceder ese límite.

Una tabla de radios se repite por bucle y su longitud debe dividir el número
de vértices, como exige la iteración estricta de Manim.
``Polygram({bucle1,bucle2},opciones)`` crea varios bucles en un Mobject.
``get_vertices`` devuelve anclas iniciales de cúbicas y ``get_vertex_groups``
las agrupa en bucles cerrados. Los redondeos también aportan anclas: no son
una copia inmutable de los vértices originales.

.. luanimath-example:: rounding
   :alt: Las esquinas cambian de curvatura mientras un punto recorre un arco.
   :video:

Centros y ajuste de extremos
--------------------------------------------------------------------------------

``get_arc_center`` interseca las normales a tangentes de la primera cúbica en
XY. ``move_arc_center_to(punto)`` traslada ese centro; ``stop_angle`` devuelve
el ángulo final módulo 2*pi. Una intersección indefinida o fuera del plano
devuelve ORIGIN y activa ``_failed_to_get_center``. No ajusta círculos 3D en
general. Un arco colapsado devuelve su punto.

``put_start_and_end_on`` escala, rota y traslada geometría abierta. Un bucle
cerrado traslada su inicio y mantiene su tamaño. La detección usa la tolerancia
existente de 1e-6 para cierre; excluye los arcos circulares abiertos para
conservar barridos pequeños.

Diferencias originales registradas
--------------------------------------------------------------------------------

El corpus conserva todos los estados originales. Un arco recto obtiene en
Manim un centro espurio de alrededor de 6e15; Lua usa el resultado de centro
indefinido. Seis redondeos con recorte máximo añaden curvas degeneradas por
``ceil(error positivo)``. Lua no subdivide huecos <=1e-12; las comparaciones
separadas eliminan únicamente curvas de longitud geométrica nula y verifican
el resto. Cuatro ajustes de extremos en círculos amplifican el error de cierre
en upstream; sus diagnósticos ejecutan la traslación prevista.
Estas once diferencias se comprueban y no se cuentan como compatibilidad
original. Las once imágenes de referencia coinciden exactamente en el entorno
registrado. Consulta :doc:`../compatibility`.
