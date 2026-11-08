Desarrollo y documentación
================================================================================

La referencia es Manim Community 0.22.1 fijado. Inspecciona su código antes de
implementar, ejecuta la API Lua real y registra diferencias numéricas y visuales.
El inventario separa disponibilidad, comportamiento parcial, verificado y bloqueado.

Comprobaciones
--------------------------------------------------------------------------------

``make check`` ejecuta pruebas funcionales, diferencias congeladas, imágenes y
archivos multimedia reales. Las comparaciones necesitan Python, NumPy y Pillow.
``make sanitize`` prueba interfaces nativas con ASan/UBSan y restaura la compilación
normal. ``make reference`` regenera datos con el entorno aislado de upstream.

La documentación forma parte de la función
--------------------------------------------------------------------------------

Para cada ampliación pública:

1. Añade descripciones precisas en inglés y español en ``docs/catalog.py`` y
   significados de parámetros en ``docs/parameters.py``.
2. Describe opciones, valores iniciales, resultados y límites de compatibilidad.
3. Actualiza el tutorial y el ejemplo completo de escena cuando corresponda.
4. Ejecuta pruebas y la comprobación de API documentada. Detecta símbolos nuevos,
   descripciones obsoletas y parámetros sin traducción.
5. Compila ambos manuales tratando avisos como errores. Se renderizan y decodifican
   las escenas de galería y se comprueban enlaces y anclas locales.

Instala ``docs/requirements.txt`` en un entorno virtual de desarrollo. Ejecuta
``tools/docs.py check`` para comprobar API y ``tools/docs.py build`` con el Python
del entorno para construir ambos manuales HTML.

Evidencia de entrega
--------------------------------------------------------------------------------

Las versiones fuente deben pasar compilación, ejemplos reales, regresiones,
documentación, manifiesto SHA-256 y extracción/recompilación limpia. No marques
una API como completa por su nombre o por un único ejemplo correcto.
