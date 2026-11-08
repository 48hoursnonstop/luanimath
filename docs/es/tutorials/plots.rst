Gráficas y actualizadores
================================================================================

``NumberLine`` convierte valores numéricos en una línea transformada. ``Axes``
combina dos líneas; las coordenadas numéricas y las de escena son distintas.
Usa ``axes:coords_to_point(x,y)`` o ``axes:c2p(x,y)`` para colocar objetos.
La operación inversa es ``point_to_coords`` o ``p2c``.

.. luanimath-example:: plots
   :alt: Un punto amarillo controlado por un tracker recorre una senoide azul sobre ejes blancos.
   :video:

``axes:plot(fn,{x_range={mínimo,máximo,paso}})`` muestrea una función escalar en
esas coordenadas. ``ParametricFunction`` espera que ``fn(t)`` devuelva un punto
2D/3D. Los resultados deben ser finitos. El suavizado cúbico está activo por
defecto; usa ``use_smoothing=false`` para unir las muestras con rectas.

Discontinuidades
--------------------------------------------------------------------------------

ParametricFunction admite ``discontinuities`` y ``dt`` positivo. Divide el
trazado alrededor de cada parámetro indicado en lugar de cruzar el hueco.
Elige el paso y el radio de exclusión según el comportamiento de la función.

El ejemplo anima un ValueTracker y reconstruye un Dot mediante ``always_redraw``.
No reconstruye los ejes ni toda la escena. Siguen pendientes las etiquetas
matemáticas, las escalas no lineales y las gráficas estadísticas especializadas.
