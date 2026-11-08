SVG y trazados cúbicos
================================================================================

``SVGMobject(nombre,opts)`` decodifica un SVG real. Por defecto centra su geometría
y la ajusta a altura 2. Usa ``height=false`` para conservar el tamaño original
o ``should_center=false`` para conservar la posición del importador.

.. luanimath-example:: svg
   :alt: Dos formas azules importadas junto a una curva cúbica amarilla.

Se admiten path, line, rectángulo, círculo, elipse, polígono y polilínea.
Funcionan los grupos, transformaciones afines, referencias ``use`` locales y
búsqueda por ID. Los colores de relleno/borde admiten nombres CSS, hexadecimal
y RGB. ``id_to_vgroup_dict`` contiene grupos compartidos para los ID importados.

``VMobjectFromSVGPath`` recibe comandos directamente. Los segmentos cuadráticos
se elevan a cúbicos y los arcos elípticos usan la aproximación de upstream.
Los VMobjects también tienen constructores de líneas, cuadráticas y cúbicas.

Límites de compatibilidad
--------------------------------------------------------------------------------

El importador conserva el descarte de viewBox/transform raíz, el redondeo de
alpha y la omisión de opacidad de grupo de Manim. Faltan hojas de estilo, degradados, recorte, máscaras, filtros, unidades físicas o
porcentuales y texto/imágenes dentro del SVG. Lo no admitido produce un error.
Las referencias son locales; se rechazan referencias externas y declaraciones
DTD. El SVG se limita a 16 MiB y se acotan las profundidades de árbol y referencias.

Los rectángulos SVG redondeados admiten rx/ry con valores heredados entre sí y
limitados a media anchura/altura. Los radios elípticos usan el mismo procedimiento
de redondear y estirar de Manim. Un radio nulo produce esquinas cuadradas.
Se rechazan radios SVG negativos, aunque la dependencia fijada los acepta como
geometría cóncava. Consulta :doc:`rounding` para las figuras Lua.
