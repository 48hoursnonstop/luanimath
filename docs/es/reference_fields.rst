Estado de objetos y resultados
================================================================================

Notación de tipos
--------------------------------------------------------------------------------

``vector`` es un vector Lua de tres componentes; los puntos suelen admitir
también tablas de dos o tres coordenadas. ``color`` admite los nombres,
hexadecimal o componentes normalizados compatibles. ``RGBA`` es una tabla de
cuatro valores en [0,1]. ``T[]`` indica una secuencia Lua de T y ``vector[4]``
describe cuatro controles cúbicos. Son tipos del manual, no constructores nuevos.

Datos de Mobject
--------------------------------------------------------------------------------

* ``points``: tabla de vectores. La geometría guarda cuatro puntos por cúbica y
  puede terminar en un ancla pendiente. La API de trazados conserva estas reglas.
* ``submobjects``: hijos directos. ``add`` evita ciclos e identidades directas
  duplicadas; los grupos pueden compartir hijos.
* ``fill_color`` / ``stroke_color``: tablas RGBA de cuatro componentes normalizados.
  Los métodos de estilo los validan y conservan los valores no indicados.
* ``stroke_width``: grosor no negativo que no cambia al escalar geometría.
* ``z_index``: orden finito de renderizado; la profundidad 3D lo precede cuando corresponde.
* ``updaters``: funciones que reciben el objeto y segundos lógicos transcurridos.
* ``kind``: nombre de tipo conceptual; ``is_vector`` indica geometría vectorial.

Texto
--------------------------------------------------------------------------------

``Text.chars`` y ``MarkupText.chars`` son VGroups que comparten los glifos reales.
``original_text`` conserva el texto suministrado y ``font`` la familia pedida.
``font_size`` es una propiedad calculada de lectura y escritura: escalar cambia
el tamaño medido y asignar un tamaño positivo reescala la geometría.
Se rechazan las consultas de tamaño de fuente en texto vacío.

Escenas y cámaras
--------------------------------------------------------------------------------

``scene.mobjects`` contiene las raíces ordenadas. ``scene.camera`` es la cámara,
``time`` el tiempo lógico y ``frame_count`` la cantidad de fotogramas muestreados.
``scene.config`` contiene las opciones resueltas. ``camera.frame`` es el marco
que MovingCameraScene puede animar. ThreeDCamera añade ValueTrackers para
orientación, distancia focal y aumento.

RenderReport
--------------------------------------------------------------------------------

``Scene:render`` devuelve una tabla:

* ``output``: nombre de archivo solicitado.
* ``frame_count``: cantidad de fotogramas generados.
* ``duration``: duración codificada, frame_count/frame_rate.
* ``scene_time``: tiempo lógico final.
* ``frame_dir``: carpeta temporal conservada si keep_frames está activo.

El PNG final contiene el extremo lógico y puede diferir de la última muestra
codificada. Consulta :doc:`configuration`.
