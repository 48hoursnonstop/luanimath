"""Shared parameter meanings; operation-specific overrides remove ambiguity."""
PARAMS={
 'code':('string','Typst markup body in valid UTF-8.','Cuerpo de marcado Typst en UTF-8 válido.'),
 'body':('string','Typst source body, without page-template rules.','Cuerpo Typst sin las reglas de plantilla de página.'),
 'expression':('string','Typst math source without outer dollar delimiters.','Expresión matemática Typst sin dólares exteriores.'),
 'key':('string or integer','Label or 1-based automatic capture index.','Etiqueta o índice automático de captura desde 1.'),
 'shape':('Mobject','A tracked nondegenerate leaf of this Typst object.','Hoja no degenerada seguida de este objeto Typst.'),
 'opts':('table or nil','Optional supported settings, listed below when applicable.','Opciones admitidas, descritas abajo cuando corresponda.'),
 'construct':('function','Callback receiving the scene; add objects and schedule animation here.','Función que recibe la escena para añadir objetos y programar animaciones.'),
 'm':('Mobject','Subject whose geometry or state is animated.','Objeto cuya geometría o estado se anima.'),
 'target':('Mobject or vector','Target object or scene point, as required by this operation.','Objeto o punto de destino, según la operación.'),
 'other':('Mobject','Reference object; alignment operations may also mutate it.','Objeto de referencia; las operaciones de alineación pueden modificarlo.'),
 'old':('Mobject','Object currently in the scene hierarchy.','Objeto presente en la jerarquía de escena.'),
 'new':('Mobject','Object that replaces old without copying.','Objeto que sustituye a old sin copiarse.'),
 'point':('vector','Finite scene coordinates; z defaults to zero.','Coordenadas finitas de escena; z vale cero por defecto.'),
 'points':('vector[]','Ordered coordinate sequence; cubic paths use groups of four.','Secuencia de coordenadas; los trazados cúbicos usan grupos de cuatro.'),
 'vertices':('vector[]','At least three polygon vertices, without repeating the closing vertex.','Al menos tres vértices, sin repetir el de cierre.'),
 'start':('vector','Initial endpoint; defaults to LEFT for Line.','Extremo inicial; LEFT por defecto en Line.'),
 'finish':('vector','Final endpoint; defaults to RIGHT for Line.','Extremo final; RIGHT por defecto en Line.'),
 'location':('vector or nil','Initial point location, defaulting to ORIGIN.','Posición inicial, ORIGIN por defecto.'),
 'center':('vector or nil','Optional center; defaults to the receiver’s current center.','Centro opcional; usa el centro actual por defecto.'),
 'centers':('vector or vector[]','One common arc center or one center per corresponding point.','Un centro de arco común o un centro por punto.'),
 'direction':('vector or nil','Boundary/layout direction; RIGHT is used by next_to and arrange.','Dirección de borde o distribución; next_to y arrange usan RIGHT.'),
 'axis':('vector or nil','Rotation axis, normally OUT; normalization is handled internally.','Eje de giro, normalmente OUT; se normaliza internamente.'),
 'angle':('number','Signed rotation or arc sweep in radians.','Giro o barrido con signo en radianes.'),
 'factor':('number','Finite geometric scale factor.','Factor finito de escala geométrica.'),
 'matrix':('number[][]','Finite square 2×2 or 3×3 matrix.','Matriz cuadrada finita 2×2 o 3×3.'),
 'dim':('integer','Coordinate dimension: 1=x, 2=y, 3=z.','Dimensión: 1=x, 2=y, 3=z.'),
 'color':('color or nil','Supported color; nil preserves current color where allowed.','Color admitido; nil conserva el actual cuando se permite.'),
 'colors':('color[]','Ordered reference-color palette.','Paleta ordenada de colores de referencia.'),
 'opacity':('number or nil','Alpha in [0,1]; nil preserves existing alpha where allowed.','Opacidad en [0,1]; nil conserva la actual cuando se permite.'),
 'width':('number or nil','Nonnegative stroke width; nil preserves the existing width.','Grosor no negativo; nil conserva el actual.'),
 'darkness':('number','Fade amount in [0,1].','Cantidad de desvanecimiento en [0,1].'),
 't':('number','Finite interpolation time or function parameter.','Tiempo de interpolación o parámetro finito.'),
 'alpha':('number','Normalized interpolation proportion in [0,1], unless described otherwise.','Proporción normalizada en [0,1], salvo indicación contraria.'),
 'dt':('number','Finite elapsed logical time in seconds.','Tiempo lógico transcurrido en segundos finitos.'),
 'duration':('number or nil','Nonnegative seconds; wait defaults to one second.','Segundos no negativos; wait usa uno por defecto.'),
 'samples':('integer or nil','At least two; defaults to ten samples per cubic.','Al menos dos; usa diez muestras por cúbica por defecto.'),
 'n':('integer','Nonnegative number of curves or children to add.','Cantidad no negativa de curvas o hijos que se añaden.'),
 'count':('integer','Requested total cubic count, at least the current count.','Cantidad total de cúbicas, al menos la actual.'),
 'length':('integer','Nonnegative output color count.','Cantidad no negativa de colores de salida.'),
 'first':('integer or nil','Inclusive first Lua index; negative values count from the end.','Primer índice inclusivo de Lua; los negativos cuentan desde el final.'),
 'last':('integer or nil','Inclusive last Lua index; negative values count from the end.','Último índice inclusivo de Lua; los negativos cuentan desde el final.'),
 'step':('integer or nil','Nonzero slice increment, defaulting to 1.','Paso de selección distinto de cero, 1 por defecto.'),
 'size':('number','Positive font size or tick half-length, according to the method.','Tamaño positivo de fuente o semilongitud de marca según el método.'),
 'value':('number','Finite scalar value stored by the object or camera tracker.','Escalar finito almacenado en el objeto o control de cámara.'),
 'number':('number or number[]','Numerical coordinate or batch of coordinates.','Coordenada numérica o secuencia de coordenadas.'),
 'x':('number or table','x coordinate; Axes also accepts coordinate tables/batches.','Coordenada x; Axes también acepta tablas o secuencias de coordenadas.'),
 'y':('number or nil','y coordinate, defaulting to zero for vectors.','Coordenada y, cero por defecto en vectores.'),
 'z':('number or nil','z coordinate or finite z-index, according to the operation.','Coordenada z u orden z finito, según la operación.'),
 'fn':('function','Lua callback; see the operation description for argument and result shape.','Función de Lua; la descripción indica los argumentos y resultados esperados.'),
 'text':('string','UTF-8 text, or validated Pango markup for MarkupText.','Texto UTF-8 o marcado Pango validado en MarkupText.'),
 'data':('string','SVG path-command data, not an SVG filename.','Datos de comandos SVG, no un nombre de archivo SVG.'),
 'filename':('string','Path of an existing SVG file.','Ruta de un archivo SVG existente.'),
 'path':('Mobject or string','Motion path for MoveAlongPath; optional PNG filename for Renderer:render.','Trazado en MoveAlongPath; nombre PNG opcional en Renderer:render.'),
 'mobjects':('Mobject[]','Ordered sequence of scene roots to render.','Secuencia ordenada de raíces que se renderizan.'),
 'camera':('Camera or nil','Optional camera; defaults to a newly constructed 2D Camera.','Cámara opcional; usa una Camera 2D nueva por defecto.'),
 'scene':('Scene or nil','Optional scene registration and cleanup context.','Contexto opcional de registro y limpieza de escena.'),
 'output':('string','Encoded output filename with a supported extension.','Nombre de salida con extensión admitida.'),
 'frame_dir':('string','Directory containing frame_000000.png and following frames.','Carpeta con frame_000000.png y los fotogramas siguientes.'),
 'fps':('number','Positive encoding frame rate.','Fotogramas por segundo positivos para la codificación.'),
 'anchor':('vector','Final anchor of the appended curve.','Ancla final de la curva añadida.'),
 'anchor1':('vector','Initial anchor of the new cubic.','Ancla inicial de la cúbica.'),
 'anchor2':('vector','Final anchor of the new cubic.','Ancla final de la cúbica.'),
 'handle':('vector','Quadratic control point.','Control de la cuadrática.'),
 'handle1':('vector','First cubic control point.','Primer control cúbico.'),
 'handle2':('vector','Second cubic control point.','Segundo control cúbico.'),
 'anchors':('vector[]','Ordered interpolation anchors; repeat the first anchor to close a spline.','Anclas de interpolación ordenadas; repite la primera para cerrar una spline.'),
 'tolerance':('number or nil','Nonnegative distance tolerance; vec.close defaults to 1e-6.','Tolerancia de distancia no negativa; vec.close usa 1e-6.'),
 'k':('number or nil','Logistic inflection parameter, defaulting to 10.','Parámetro de inflexión logística, 10 por defecto.'),
 'p':('vector','Point/vector to rotate.','Punto o vector que se gira.'),
}
SPECIAL={
 'config.with':{'fn':('function','Zero-argument callback whose results are forwarded.','Función sin argumentos cuyos resultados se reenvían.')},
 'AnimationGroup':{'a':('Animation[]','Nonempty sequence of child animations.','Secuencia no vacía de animaciones hijas.')},
 'LaggedStart':{'a':('Animation[]','Nonempty sequence of child animations.','Secuencia no vacía de animaciones hijas.')},
 'Succession':{'a':('Animation[]','Nonempty sequence of child animations.','Secuencia no vacía de animaciones hijas.')},
 'CubicBezier':{k:('vector',en,es) for k,en,es in [('a','Initial anchor.','Ancla inicial.'),('b','First handle.','Primer control.'),('c','Second handle.','Segundo control.'),('d','Final anchor.','Ancla final.')]},
 'parse':{'c':('color','Supported color representation.','Representación admitida de color.'),'alpha':('number or nil','Replacement alpha in [0,1].','Opacidad de sustitución en [0,1].')},
 'interpolate':{k:('color',en,es) for k,en,es in [('a','Initial color.','Color inicial.'),('b','Final color.','Color final.')]},
}
for name in ('vec.dot','vec.cross','vec.lerp','vec.close'):
 SPECIAL[name]={k:('vector',en,es) for k,en,es in [('a','First vector.','Primer vector.'),('b','Second vector.','Segundo vector.')]}
for name in ('vec.norm','vec.normalize'):
 SPECIAL[name]={'a':('vector','Input vector.','Vector de entrada.')}
SPECIAL['bezier.line']={k:('vector',en,es) for k,en,es in [('a','Initial endpoint.','Extremo inicial.'),('b','Final endpoint.','Extremo final.')]}
for name in ('bezier.point','bezier.split','bezier.partial','bezier.length','bezier.append'):
 SPECIAL[name]={'c':('vector[4]','Four-point cubic curve.','Curva cúbica de cuatro puntos.')}
for name in ('Mobject:get_subcurve','Mobject:pointwise_become_partial','bezier.partial','bezier.partial_path'):
 SPECIAL.setdefault(name,{}).update({k:('number',en,es) for k,en,es in [('a','Initial normalized proportion.','Proporción normalizada inicial.'),('b','Final normalized proportion.','Proporción normalizada final.')]})

def parameter(name,key):
    return SPECIAL.get(name,{}).get(key,PARAMS.get(key))

for name in ('Scale:map','Scale:inverse'):
 SPECIAL[name]={'value':('number or number[]','Finite scalar or nested numerical sequence.','Escalar finito o secuencia numérica anidada.')}
