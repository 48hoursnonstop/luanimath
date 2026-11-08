Expresiones matemáticas con Typst
================================================================================

Instala la CLI nativa Typst y ejecuta ``typst --version``. La referencia probada
es 0.15.1. Esta dependencia opcional compila fórmulas a SVG; la biblioteca
importa sus curvas reales y las anima/renderiza con Lua/Cairo. No interviene
Python. ``MathTex`` y ``Tex`` siguen pendientes.

Crear y seleccionar una fórmula
--------------------------------------------------------------------------------

.. code-block:: lua

   local l = require('luanimath')
   local equation = l.MathTypst('{{ a^2+b^2 : lhs }} = {{ c^2 }}', {
       font_size = 72, track_baselines = true
   })
   equation:select('lhs'):set_color(l.BLUE)
   equation:select(1):set_color(l.YELLOW)

La expresión usa sintaxis matemática Typst: ``frac(a,b)``, ``sqrt(x)``,
``sum_(k=1)^n k`` y ``mat(1,2;3,4)``. No interpreta LaTeX.
``Typst`` acepta contenido de documento, con marcado y delimitadores explícitos:
``l.Typst('*Title* and $x^2$')``. ``typst_preamble`` añade definiciones o reglas
de estilo antes del cuerpo.

``{{ cuerpo : nombre }}`` marca una captura nombrada; ``{{ cuerpo }}``, una
captura anónima, seleccionable con índices Lua desde 1. Las capturas nombradas
no consumen índices anónimos. Se admiten anidación y nombres repetidos. El
VGroup devuelto comparte las hojas reales: colorearlo o animarlo modifica la
expresión original. Una captura conocida que solo contiene contenido oculto
devuelve un grupo vacío; un nombre desconocido produce un error. También puedes
seleccionar por nombre las etiquetas SVG del contenido Typst ordinario.

Animar los contornos reales
--------------------------------------------------------------------------------

.. luanimath-example:: math
   :alt: Capturas de Pitágoras y una suma escritas con contornos vectoriales reales.
   :video:

``Write`` y ``Transform`` usan el sistema existente de familias vectoriales.
La correspondencia automática de expresiones/tokens sigue pendiente. Una captura
puede incluir varios glifos o curvas; no se garantiza una hoja por carácter.

Tamaño, trazos y líneas base
--------------------------------------------------------------------------------

``font_size`` vale 48 por defecto. ``height`` explícito sigue la ruta especial
de Manim y omite el escalado inicial de fuente; consulta
:doc:`../reference_fields` para su medida calculada. Los trazos originales se
adaptan a la proporción activa de píxeles/mundo y se actualizan al escalar la
raíz. ``stroke_width`` explícito desactiva esa conservación.

Con ``track_baselines=true``, ``equation.baseline_frames`` devuelve marcos afines
de las hojas no degeneradas después de trasladar, rotar y escalar.
``equation:get_baseline_frame(hoja)`` devuelve tres vectores. Cambiar el número
de puntos invalida la referencia. Estos marcos reproducen la semántica del
importador fijado; no constituyen un motor de distribución ni un ajuste no lineal.

Compilación y caché
--------------------------------------------------------------------------------

``typst_bin`` o ``LUANIMATH_TYPST`` selecciona el ejecutable. ``font_paths`` añade
directorios de fuentes; ``root`` establece la raíz del proyecto del compilador.
La caché predeterminada es ``.luanimath-cache/typst``; ``cache_dir`` la cambia y
``use_cache=false`` fuerza la compilación. Los errores conservan el diagnóstico
del compilador.

La clave incluye código generado, versión del compilador, rutas de fuentes y
raíz. Las huellas del SVG detectan corrupción. Cambiar fuentes o archivos
externos requiere limpiar la caché o forzar la compilación. Lua conserva el
seguimiento de trazos y líneas base al importar SVG en caché; Manim lo pierde
en algunos aciertos. Seis estados originales conservan y diagnostican por
separado esta diferencia intencional en :doc:`../compatibility`.

Consulta :doc:`../reference/typst` para las opciones admitidas.
