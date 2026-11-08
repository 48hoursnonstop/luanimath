Destinos, estado guardado y transformación de puntos
================================================================================

``save_state`` guarda una instantánea profunda de geometría y estilo.
``restore`` la aplica de inmediato; ``Restore`` anima el cambio.
``generate_target`` crea y devuelve una copia editable. ``MoveToTarget`` anima
el objeto hasta esa copia.

.. code-block:: lua

   local object = l.Square {color=l.BLUE,fill_opacity=.4}
   object:save_state()
   object:generate_target():shift(l.RIGHT*2):set_color(l.TEAL)
   s:play(l.MoveToTarget(object))
   s:play(l.Restore(object))

Cada ``generate_target`` sustituye el destino anterior sin acumular una cadena
de copias. ``MoveToTarget`` captura el objeto de destino al construirse:
editarlo antes de comenzar modifica el resultado, pero generar después otro
destino no sustituye el capturado. ``Restore`` lee la instantánea más reciente
al comenzar. Guardar de nuevo sustituye la instantánea anterior.

La restauración conserva identidad, tipo y actualizadores. ``become`` alinea
ambas familias antes de copiar puntos y estilo; puede modificar la otra
jerarquía. Si un grupo creció después de guardar, sus hijos adicionales permanecen
alineados y transparentes, como en Manim. Restaurar no los elimina.

Métodos y funciones
--------------------------------------------------------------------------------

``ApplyMethod(objeto,"set_fill",{l.PURPLE,.6},opciones)`` aplica un método a una
copia profunda al comenzar. Lua indica objeto, nombre del método y tabla de
argumentos explícitos. También admite una función sin ligar cuyo primer argumento
es la copia. ``table.pack`` conserva argumentos nil finales. El resultado del
método se ignora, como en upstream.

``ApplyFunction(fn,objeto,opciones)`` exige que ``fn(copia)`` devuelva un Mobject;
puede ser otra jerarquía. El destino se crea una vez al comenzar: mover el objeto
después de construir la animación modifica la geometría que recibirá la función.
Devolver nil produce un error.

``FadeToColor``, ``ScaleInPlace`` y ``ShrinkToCenter`` también crean el destino
al comenzar. Se admiten escalas negativas y nulas. Shrink mantiene el objeto
degenerado en la escena salvo ``remover=true``.

.. luanimath-example:: state_transforms
   :alt: Un rectángulo guardado cambia de destino, se deforma, cambia color y se restaura.
   :video:

Transformaciones de puntos y matrices
--------------------------------------------------------------------------------

``ApplyPointwiseFunction(fn,objeto,opciones)`` transforma puntos finitos 2D/3D
de una copia. ``ApplyMatrix(matriz,objeto,{about_point=...})`` admite matrices
2x2 o 3x3; las primeras conservan z. Duran tres segundos por defecto. La matriz
se copia al construir la animación; la tabla del punto de referencia se lee
al generar el destino.

``objeto:apply_function(fn)`` aplica el cambio de inmediato. En objetos vectoriales
acerca temporalmente los controles Bézier a sus anclas y vuelve a separarlos
después de transformar, conservando tangentes.
``pre_function_handle_to_anchor_scale_factor`` vale .01, o 1e-5 en Surface;
debe ser finito y distinto de cero. ``make_smooth_after_applying_functions=true``
reconstruye controles suaves al terminar. ``scale_handle_to_anchor_distances``
permite aplicar esa escala de controles directamente.

Se requieren cúbicas completas u objetos de un punto; se rechazan anclas
pendientes después de una curva. Los Mobjects no vectoriales transforman puntos
directamente. Los cambios inmediatos modifican geometría durante la ejecución;
los errores no garantizan reversión. Las opciones de ajuste de tamaño de
``become`` y el resto de la familia de transformaciones siguen pendientes.
