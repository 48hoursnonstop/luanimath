Tu primera escena
================================================================================

Un archivo de escena devuelve una Scene construida con una función de Lua.
La escena llama a esa función al renderizar. Añade objetos con ``s:add`` y
programa animaciones con ``s:play``. Las duraciones se expresan en segundos.

Este ejemplo completo crea un cuadrado y después lo mueve y gira:

.. luanimath-example:: quickstart
   :alt: Un cuadrado azul relleno trasladado a la derecha y girado cuarenta y cinco grados.
   :video:

Guarda el código como ``scene.lua`` y ejecuta:

.. code-block:: console

   lua5.4 tools/luanimath.lua scene.lua --output animation.mp4 --width 640 --height 360 --fps 24

Un constructor de animación trabaja sobre una copia de destino. El cuadrado
cambia cuando ``s:play`` evalúa ese constructor. Conserva su identidad y puedes
seguir usando la misma variable en las operaciones posteriores.

El comando también guarda un PNG del estado lógico final. Usa ``--output image.png``
para una imagen fija. Consulta :doc:`../configuration` para tiempos y formatos.
