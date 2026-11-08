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
