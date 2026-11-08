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
numéricas automáticas y las gráficas estadísticas especializadas.

Escalas lineales y logarítmicas
--------------------------------------------------------------------------------

``LinearBase{scale_factor=2}`` multiplica los valores; su inversa los divide.
``LogBase{base=2}`` transforma exponentes en potencias y utiliza una inversa
logarítmica. ``escala:map(valor)`` / ``escala:inverse(valor)`` admiten escalares
o tablas numéricas anidadas. Entradas y resultados deben ser finitos; la inversa
logarítmica exige entradas positivas. Las bases son positivas y distintas de 1;
los factores lineales, distintos de cero. Se admiten bases fraccionarias y
factores negativos. Lua rechaza tablas logarítmicas con algún valor no positivo,
incluso donde la comprobación de upstream deja producir NaN.

.. code-block:: lua

   local ax = l.Axes {
       x_range = {0,4,1}, y_range = {-1,3,1},
       y_axis_config = {scaling=l.LogBase{base=2}}
   }
   local punto = ax:c2p(2,4) -- y vale 4, cuyo exponente es 2

Los intervalos conservan el dominio sin transformar: ``y_range={-1,3,1}``
produce marcas ``{0.5,1,2,4,8}`` con base 2 y sin punta. Una punta omite la
marca final. Las coordenadas de ``c2p`` / ``n2p`` son los valores transformados.
El centrado y la marca del origen siguen las reglas de escala de Manim.
``get_origin()`` solicita el cero numérico y no está definido para una coordenada
logarítmica; indica coordenadas positivas explícitas.

``ParametricFunction(...,{scaling=escala})`` transforma los tiempos antes de
llamar a la función. Su función guardada/getter sigue aceptando el parámetro
real. ``Axes:plot`` hereda la escala del eje x y muestrea los intervalos
logarítmicos en el espacio de exponentes. La correspondencia sigue las
transformaciones geométricas posteriores.

.. luanimath-example:: scales
   :alt: Eje logarítmico de base dos con etiquetas explícitas y un punto animado.
   :video:

El ejemplo construye etiquetas con MathTypst y las coloca junto al eje.
``include_numbers`` y las etiquetas automáticas LogBase siguen pendientes;
el campo ``custom_labels`` se conserva como metadato y todavía no las activa.
