Instalación
================================================================================

Compilar en Linux
--------------------------------------------------------------------------------

Necesitas Lua 5.4 y sus cabeceras, un compilador C11, make, pkg-config, Cairo,
Pango, libxml2 y FFmpeg. Comprueba las herramientas existentes antes de instalar.
En Arch, los paquetes relevantes son ``lua54 cairo pango libxml2 ffmpeg gcc make
pkgconf``. Solo se ha probado la ABI de Lua 5.4; ``lua`` puede ser otra versión.

.. code-block:: console

   git clone https://github.com/48hoursnonstop/luanimath.git
   cd luanimath
   make
   make test
   lua5.4 tools/luanimath.lua docs/examples/quickstart.lua --output animation.mp4

La CLI localiza los módulos respecto a su archivo fuente. Para un programa Lua
propio, configura ``LUA_PATH`` como ``lua/?.lua;lua/?/init.lua;;`` y ``LUA_CPATH``
como ``build/?.so;;``. Usa rutas absolutas si ejecutas fuera del proyecto.

Dependencias durante la ejecución
--------------------------------------------------------------------------------

Las escenas usan Lua y el módulo nativo Cairo/Pango/libxml2. FFmpeg es necesario
para codificar animaciones. Python y Manim son herramientas de desarrollo para
comparaciones y documentación; no ejecutan las escenas Lua. Los objetos públicos
de matemáticas mediante TeX/Typst siguen en desarrollo en esta versión.

Fuentes
--------------------------------------------------------------------------------

Los ejemplos usan Liberation Sans y Noto Sans. Los de CJK y árabe necesitan las
familias Noto correspondientes. ``font_list()`` informa de las familias de Pango.
La sustitución de fuentes puede cambiar la distribución; el entorno de referencia
registra las huellas de las fuentes probadas.

Archivos fuente
--------------------------------------------------------------------------------

Los tarballs incluyen código, pruebas y referencias congeladas. Extrae uno,
entra en su carpeta y ejecuta ``make``. Cada versión de desarrollo verificada
incluye SHA-256 y un informe de recompilación limpia.
