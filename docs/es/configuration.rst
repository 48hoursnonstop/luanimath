Configuración, CLI y salida
================================================================================

La CLI recibe un archivo que devuelve una Scene:

.. code-block:: console

   lua5.4 tools/luanimath.lua scene.lua --output scene.mp4 --width 640 --height 360 --fps 24
   lua5.4 tools/luanimath.lua scene.lua --output scene.png
   lua5.4 tools/luanimath.lua scene.lua --output scene.gif --keep-frames

Las opciones son ``--output``, ``--width``, ``--height``, ``--fps`` y
``--keep-frames``. Las opciones desconocidas y valores ausentes producen errores.
El ancho y alto de CLI son píxeles. Configura las dimensiones de mundo en el
constructor Scene o en las opciones de ``render``.

Valores y prioridad
--------------------------------------------------------------------------------

Se combinan ``l.config.defaults``, opciones del constructor y finalmente opciones
de renderizado. Los valores iniciales son 854×480 píxeles, 30 fps, ancho de mundo
128/9, alto 8, fondo negro y opacidad 1. La resolución no cambia automáticamente
la proporción del mundo. ``frame_center`` sitúa la cámara. Los colores admiten
nombres Manim compatibles, hexadecimal RGB(A) o tablas de componentes normalizados.

``render`` devuelve ``output``, ``frame_count``, ``duration`` y ``scene_time``.
Incluye ``frame_dir`` si se conservan fotogramas. La duración codificada equivale
a cantidad de fotogramas dividida por fps y puede diferir del tiempo lógico si
los tramos no duran cantidades enteras de fotogramas.

Formatos y archivos
--------------------------------------------------------------------------------

PNG guarda el estado lógico final y admite transparencia comprobada. MP4 usa
H.264/yuv420p y necesita dimensiones pares. FFmpeg también codifica GIF y WebM.
La fidelidad alpha en formatos codificados tiene menos cobertura que PNG.

Los fotogramas usan una carpeta temporal única junto a la salida. Si termina
bien se elimina salvo que se pida conservarla; si falla se mantiene para
diagnóstico. La salida codificada guarda además un PNG final, configurable con
``last_frame``. Siguen pendientes audio, caché de segmentos y presets de calidad.

Configuración temporal
--------------------------------------------------------------------------------

``l.config.with(opciones,function() ... end)`` valida y aplica temporalmente las
claves admitidas. Restaura la tabla original de valores predeterminados al volver
o producirse un error; permite anidación y devuelve los resultados del callback.
``Scene:render`` aplica su configuración resuelta al construir la escena, para
que los trazos de Typst usen las dimensiones de píxeles y mundo activas.
