Flechas y crecimiento de puntas
================================================================================

``Arrow(inicio,fin,opciones)`` construye un cuerpo con separación de extremos y
punta triangular real en dos o tres dimensiones. Por defecto va de LEFT a RIGHT,
con ``buff=.25``, grosor 6 y longitud de punta solicitada .35. Los límites son
``max_tip_length_to_length_ratio=.25`` y ``max_stroke_width_to_length_ratio=5``.
Las proporciones deben ser no negativas.

.. code-block:: lua

   local arrow = l.Arrow({-2,-1,0},{2,1,0},{buff=0,color=l.BLUE})
   s:play(l.GrowArrow(arrow))
   arrow:scale(2) -- conserva identidad y tamaño de la punta
   arrow:scale(.5,{scale_tips=true}) -- escala también la punta

Escala e identidad
--------------------------------------------------------------------------------

Escalar Arrow normalmente retira la punta, escala el cuerpo completo y vuelve
a colocar la misma punta. Recalcula el grosor según el valor inicial y la
longitud actual. ``scale_tips=true`` escala también su geometría. Escalar un
VGroup padre transforma directamente todos sus puntos, incluidas las puntas;
no llama por separado a la operación especial de cada Arrow.

``GrowArrow`` captura el inicio al construir y colapsa allí cuerpo y punta para
su instantánea inicial. Admite ``point_color`` y opciones habituales de animación.
El crecimiento ordinario desde el centro utiliza la escala de punta fija.

.. luanimath-example:: arrows
   :alt: Dos flechas crecen en 3D, cambian de escala y se ven mientras gira la cámara.
   :video:

Objetos de punta y auxiliares
--------------------------------------------------------------------------------

``ArrowTriangleFilledTip`` es la punta predeterminada. Usa
``tip_shape=l.ArrowTriangleTip`` para un contorno. Sus constructores admiten
``length``, ``width`` y estilo vectorial. ``tip_style`` en Arrow cambia ese estilo.
Las flechas de longitud nula y las puntas de tamaño cero tienen geometría real
y casos ejecutados.

``base``, ``tip_point``, ``vector``, ``tip_angle`` y ``length`` son propiedades
calculadas de solo lectura. ``base`` es el punto a media longitud del contorno.
``has_tip`` comprueba que la punta sea un hijo real. ``pop_tips`` devuelve un
VGroup que comparte la punta retirada y restaura el cuerpo completo. Reutilízala
con ``arrow:add_tip{tip=punta}``. La referencia inactiva ``arrow.tip`` puede
permanecer, como en upstream. ``get_normal_vector`` lee la geometría de punta;
``reset_normal_vector`` actualiza la normal guardada.

Límites de compatibilidad
--------------------------------------------------------------------------------

Siguen pendientes puntas iniciales, cuadradas, circulares y stealth, trayectorias
curvas del constructor Arrow y el conjunto completo de opciones heredadas.
``Vector`` sigue siendo el alias numérico existente: usa Arrow explícitamente.

Seis estados originales de escala con punta fija para cuerpos paralelos a Z
eligen otro giro de punta: componentes proyectadas diminutas afectan a atan2.
Se conservan y comprueban esas diferencias. Un registro rígido separado compara
forma, extremos, estilo y longitud; no cuenta como compatibilidad original de
orientación. La orientación 3D general y las ocho imágenes de referencia Arrow
y GrowArrow coinciden con upstream en el entorno registrado. Los ángulos se
comparan módulo 2*pi, incluido el límite equivalente de pi con signo.
La escala 3D negativa de punta fija conserva el eje de posicionamiento de
upstream; usa ``scale_tips=true`` para invertir geométricamente toda la punta.
