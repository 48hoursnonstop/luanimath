Si vienes de Manim
================================================================================

Los conceptos resultan familiares y las escenas siguen las convenciones de Lua.
Importa ``local l=require('luanimath')`` y devuelve ``l.Scene(function(s) ... end)``.
Los constructores reciben tablas de opciones y los métodos usan dos puntos.
La ejecución de escenas no contiene un intérprete Python.

.. list-table::
   :header-rows: 1

   * - Concepto de Manim
     - Forma Lua
   * - Subclase Scene con construct
     - ``Scene(function(s) ... end)``
   * - Argumentos por nombre
     - ``Square{color=l.BLUE,fill_opacity=.5}``
   * - Grupo de objetos
     - ``VGroup(a,b,c)``
   * - Vértices de polígono
     - ``Polygon({a,b,c})``
   * - Constructor de animación
     - ``m:animate():shift(l.RIGHT)``
   * - Opciones de play
     - ``s:play(animation,{run_time=2})``
   * - None de Python para alto SVG
     - ``height=false``
   * - Selección de caracteres/glifos
     - ``text:slice(1,3)``; extremos inclusivos de Lua

Las tablas numéricas y dimensiones empiezan desde 1. Los selectores de texto
entre corchetes conservan la gramática de upstream desde cero y con final
exclusivo. Los metadatos u/v de superficies también conservan su numeración.
Los ángulos siguen expresándose en radianes.

Antes de trasladar una escena
--------------------------------------------------------------------------------

Consulta :doc:`compatibility` y las opciones admitidas por cada constructor.
Un nombre exportado no implica todo el comportamiento de upstream. Siguen
pendientes MathTex/Tex, imágenes raster, OpenGL, audio y familias especializadas.
``Vector`` es actualmente un alias del constructor numérico ``vec``; no es
el Mobject de flecha de upstream.

Transform alinea familias vectoriales reales. Glifos, ligaduras y versiones de
fuentes afectan a animaciones y distribución. Text tiene una diferencia RTL
documentada de ancho natural. SVG conserva varias particularidades del
importador de upstream y no promete cumplir todo el estándar SVG.
