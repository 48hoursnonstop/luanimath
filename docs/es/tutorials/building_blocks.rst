Objetos, vectores y grupos
================================================================================

Las coordenadas usan x hacia la derecha, y hacia arriba y z hacia fuera de la
pantalla. El mundo predeterminado mide 128/9 por 8 unidades. ``l.vec(x,y,z)`` crea
un vector y los componentes ausentes valen cero. Hay suma, resta, multiplicación
y división por escalares. ``RIGHT`` y ``UP`` también son vectores, de modo que
``2*l.RIGHT + l.UP`` expresa un punto o desplazamiento.

Mobjects
--------------------------------------------------------------------------------

Cada figura visible es un Mobject. Un VMobject contiene geometría vectorial
cúbica y los constructores geométricos aportan sus puntos iniciales. El estilo
usa colores RGB(A), opacidades separadas de relleno/borde y grosor de trazo.
Un relleno necesita ``fill_opacity`` mayor que cero. La mayoría de los métodos
de edición devuelven el objeto para encadenar llamadas.

Los grupos comparten hijos
--------------------------------------------------------------------------------

``VGroup(a,b,c)`` guarda los objetos reales, no copias. Mover el grupo transforma
cada descendiente único una vez. ``copy()`` crea un grafo independiente y
conserva las relaciones compartidas dentro de la copia.

.. luanimath-example:: objects
   :alt: Un círculo rojo, un cuadrado azul y un triángulo verde; dos figuras están más arriba.

``group[1]``, ``#group`` e ``ipairs(group)`` siguen los índices de Lua desde 1.
Un objeto con puntos propios se incluye primero, seguido de sus hijos.
``slice(2,3)`` devuelve un grupo que comparte los seleccionados, por lo que
sus transformaciones afectan a los originales. Los extremos son inclusivos
y los índices negativos cuentan desde el final.

Pivote y dimensiones
--------------------------------------------------------------------------------

``scale`` y ``rotate`` usan el centro; ``about_point`` o ``about_edge`` cambia el
pivote. ``apply_matrix`` usa el origen. Las dimensiones incluyen controles
Bézier, mientras los puntos críticos de borde usan anclas vectoriales.
El grosor del trazo no aumenta al escalar la geometría.
