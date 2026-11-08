Resolución de problemas
================================================================================

Lua no encuentra luanimath o su módulo nativo
--------------------------------------------------------------------------------

Usa ``lua5.4 tools/luanimath.lua`` desde el árbol fuente o configura las rutas
de :doc:`installation`. Recompila con ``make``. No está soportado cargar un
módulo compilado para Lua 5.4 en otra ABI.

La figura tiene borde pero no relleno
--------------------------------------------------------------------------------

La geometría suele empezar con relleno transparente. Fija ``fill_opacity`` o
usa ``set_fill(color,opacity)``. Text y Dot usan relleno por defecto.

El texto o número de glifos cambia
--------------------------------------------------------------------------------

Comprueba ``font_list()``, la familia y la versión instalada. Las ligaduras y
marcas combinadas hacen que caracteres y glifos no siempre se correspondan.
``disable_ligatures`` desactiva ciertas funciones OpenType, no todas las
sustituciones posibles. La diferencia RTL está registrada en compatibilidad.

Falla la codificación MP4
--------------------------------------------------------------------------------

Comprueba FFmpeg y que ancho/alto sean pares. Se conserva la carpeta de fotogramas
del error. Revisa extensión y permisos de la carpeta de salida.

Una función SVG produce un error
--------------------------------------------------------------------------------

Consulta el subconjunto de :doc:`tutorials/svg`. Entre los casos no admitidos
están degradados, recorte y texto/imágenes incrustados.

El PNG final difiere del último fotograma del video
--------------------------------------------------------------------------------

La imagen fija captura el extremo lógico. El video muestrea tiempos anteriores
al extremo de cada tramo. Es el muestreo determinista previsto; consulta
:doc:`configuration`.

Falla la compilación matemática
--------------------------------------------------------------------------------

Ejecuta ``typst --version`` y comprueba la sintaxis: MathTypst usa matemáticas
Typst. ``typst_bin`` selecciona otro ejecutable. La caché predeterminada está en
``.luanimath-cache/typst``; ``use_cache=false`` fuerza la compilación. Si cambia
una fuente o un archivo externo, limpia la caché o fuerza la compilación: su
contenido externo no forma parte de la clave.
