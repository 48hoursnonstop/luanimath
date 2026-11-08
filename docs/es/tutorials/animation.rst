Animación y tiempo
================================================================================

``Create`` revela trazados; ``Write`` dibuja contornos y rellenos y desfasa los
glifos. ``FadeIn`` y ``FadeOut`` cambian la transparencia. ``Transform`` alinea
familias vectoriales e interpola conservando la identidad del origen.
``ReplacementTransform`` instala el objeto de destino real al terminar.

Constructores y composición
--------------------------------------------------------------------------------

Usa ``object:animate():shift(...):rotate(...)`` dentro de ``Scene:play`` para
describir un destino. Varios argumentos de ``play`` se ejecutan juntos.
La tabla final admite ``run_time``, ``rate_func`` y ``lag_ratio``.
``AnimationGroup({a,b})`` recibe una secuencia; ``LaggedStart`` la desfasa y
``Succession`` la ejecuta consecutivamente. Succession requiere avanzar hacia
delante; los demás grupos admiten suavizado que retrocede.

.. luanimath-example:: paths
   :alt: Un punto amarillo que recorre un trazado Bézier cúbico azul.
   :video:

Fotogramas y actualizadores
--------------------------------------------------------------------------------

Cada tramo muestrea ``k/fps`` antes de su duración y después termina en el
extremo lógico. La imagen final puede diferir del último fotograma codificado.
Las duraciones no enteras en fotogramas se redondean hacia arriba.

Un actualizador recibe ``fn(objeto,dt)``. Anima un ``ValueTracker`` y léelo
desde una función para controlar geometría derivada. ``always_redraw``
reconstruye un objeto en cada actualización. Las animaciones suspenden por
defecto los actualizadores de su objeto; las copias iniciales y finales
ejecutan sus propios actualizadores.

Borrar objetos
--------------------------------------------------------------------------------

``Uncreate`` y ``Unwrite`` suelen retirar sus objetos. ``Uncreate`` admite
``remover=false`` para conservar el objeto final degenerado. ``FadeOut`` siempre
retira el suyo y rechaza ``remover`` explícito, como el constructor de upstream.
Write invertido restaura el orden de los hijos al terminar.

Crecimiento y entrada en espiral
--------------------------------------------------------------------------------

``GrowFromPoint(objeto,punto,opciones)`` introduce un objeto desde un punto;
puedes usar otro Mobject cuyo centro se lee al comenzar la animación.
``GrowFromCenter`` y ``GrowFromEdge(objeto,borde,opciones)`` capturan su origen
al construir la animación. Mover el objeto antes de ``begin`` cambia su destino,
pero mantiene ese origen capturado.

``point_color`` indica un color inicial opcional para la familia y lo interpola
hasta los colores originales, conservando la opacidad. ``lag_ratio`` desfasa los
miembros con geometría, incluidos los glifos reales. El crecimiento comparte las
instantáneas deterministas, funciones temporales y suspensión de actualizadores
de Transform. Añade automáticamente el objeto a la escena; ``remover=true`` lo
retira al terminar. Se rechaza ``introducer`` explícito, como el argumento fijo
del constructor de upstream.

.. luanimath-example:: growth
   :alt: Un título y tres figuras entran desde un punto, borde, centro y espiral.
   :video:

``SpinInFromNothing(objeto,{angle=PI/2})`` crece desde el centro capturado con
movimiento espiral alrededor de OUT. Los ángulos negativos invierten el giro;
aquí sí se admite una vuelta completa. Proporciona su propio recorrido y
rechaza ``path_func`` explícito. ``spiral_path(ángulo,eje)`` crea un recorrido
general de tablas de puntos para Transform: rota el desplazamiento por
``(alpha-1)*ángulo`` y lo escala por alpha. Una magnitud menor de .01 usa una
línea; un eje nulo usa OUT. Estos recorridos admiten alpha extrapolado; las
animaciones mantienen sus reglas normales de tiempo. Consulta :doc:`arrows` para GrowArrow y la escala con punta fija.
