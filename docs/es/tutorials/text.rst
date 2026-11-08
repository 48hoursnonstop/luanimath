Texto, glifos y marcado
================================================================================

``Text`` compone UTF-8 mediante Pango e importa glifos vectoriales reales. Fija
la familia de fuente cuando necesites una distribución reproducible. El relleno
usa opacidad 1 y el borde grosor 0. El tamaño público predeterminado es 48.

.. luanimath-example:: text
   :alt: Texto luanimath en negrita y cursiva sobre una frase con degradado azul y verde.
   :video:

Selección y estilo
--------------------------------------------------------------------------------

``text.chars`` comparte los objetos de glifo reales. ``text:slice(1,3)`` selecciona
los tres primeros con índices inclusivos de Lua. Las ligaduras pueden combinar
varios caracteres en un glifo. ``disable_ligatures=true`` desactiva las funciones
OpenType admitidas e inserta objetos invisibles para espacios en Text. Algunas
fuentes aún pueden combinar caracteres mediante otras funciones de composición.

Los mapas de estilo usan subcadenas literales o selectores de Manim: ``t2c``
colores, ``t2f`` fuentes, ``t2s`` inclinaciones, ``t2w`` pesos y ``t2g`` degradados.
Sus nombres largos son ``text2color``, ``text2font``, ``text2slant``, ``text2weight``
y ``text2gradient`` y prevalecen sobre los cortos. A diferencia de las selecciones
Lua, ``"[0:3]"`` empieza desde cero y excluye el extremo final. Los límites
negativos cuentan desde el final. Los intervalos fuera de límites y los
selectores vacíos se rechazan.

Pueden solaparse atributos distintos; los estilos no predeterminados en conflicto
sobre un mismo atributo producen un error. Cada tramo se compone por separado,
como en los límites de kerning y ligaduras de upstream. ``gradient={RED,BLUE}``
crea tramos de color por carácter. Cambiar ``text.font_size`` escala la geometría
existente sin volver a componer la fuente.

MarkupText
--------------------------------------------------------------------------------

``MarkupText`` admite marcado Pango como ``<b>``, ``<i>``, ``<u>``, ``<s>``,
``<sup>``, ``<sub>`` y atributos ``<span>`` anidados. Escapa los caracteres XML
mediante ``&amp;``, ``&lt;`` y ``&gt;``. El marcado inválido se rechaza. Pango
distribuye los párrafos con el ancho de 500 unidades de upstream.

Faltan las etiquetas antiguas de color/degradado específicas de Manim. Text usa
composición de ancho natural y conserva la diferencia documentada con el recorte
árabe de upstream. Markup tiene un caso RTL de párrafo probado por separado.
