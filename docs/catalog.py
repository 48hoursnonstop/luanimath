"""Reviewed bilingual API descriptions. Missing exports fail the docs check."""
API={
 'Mobject':('Create the common scene-object container. Geometry lives in points and children in submobjects; style options are listed below.','Crea el contenedor común de objetos. La geometría está en points y los hijos en submobjects; las opciones de estilo se describen abajo.'),
 'VMobject':('Create a vector object whose point array stores four points per cubic Bézier segment. It starts with no geometry.','Crea un objeto vectorial con cuatro puntos por segmento Bézier cúbico. Empieza sin geometría.'),
 'VGroup':('Group vector objects by identity. Pass objects as separate arguments; transformations and styles affect their shared children.','Agrupa objetos vectoriales por identidad. Recibe objetos como argumentos separados; las transformaciones y estilos afectan a los hijos compartidos.'),
 'Group':('Group arbitrary Mobjects without requiring vector geometry. Adding an object does not copy it.','Agrupa Mobjects sin exigir geometría vectorial. Añadir un objeto no lo copia.'),
 'Arc':('Construct an XY-plane circular arc. Angles are radians; num_components defaults to 9, giving eight cubic segments.','Construye un arco circular en el plano XY. Los ángulos están en radianes; num_components vale 9 y produce ocho segmentos cúbicos.'),
 'Circle':('Construct a full circular path, red by default, with radius 1 and eight cubic segments. Fill remains transparent unless requested.','Construye un círculo rojo de radio 1 con ocho segmentos cúbicos. El relleno es transparente salvo que se indique.'),
 'Dot':('Create a filled, stroke-free circle centered at point, defaulting to the origin. The default radius is 0.08.','Crea un círculo relleno y sin borde, centrado en point o en el origen. El radio predeterminado es 0.08.'),
 'Ellipse':('Create an ellipse with width 2 and height 1 by stretching circular geometry along the scene axes.','Crea una elipse de ancho 2 y alto 1 estirando geometría circular sobre los ejes de la escena.'),
 'Line':('Connect two 2D/3D points with a straight cubic segment. Defaults are LEFT and RIGHT; buff trims each end. Curved lines are rejected.','Une dos puntos 2D/3D mediante un segmento cúbico recto. Los extremos predeterminados son LEFT y RIGHT; buff recorta ambos extremos. Las líneas curvas se rechazan.'),
 'Polygon':('Construct a closed polygon from a sequence of at least three vertices. Vertices use Lua vectors or coordinate tables.','Construye un polígono cerrado a partir de una secuencia de al menos tres vértices, expresados como vectores o tablas de coordenadas.'),
 'Rectangle':('Construct a centered rectangle with width 4 and height 2. Its initial stroke is white and its fill is transparent.','Construye un rectángulo centrado de ancho 4 y alto 2. Su borde inicial es blanco y su relleno transparente.'),
 'Square':('Construct a centered square with side_length 2. Other supported style options are inherited from Mobject.','Construye un cuadrado centrado con side_length 2. Las demás opciones de estilo se comparten con Mobject.'),
 'RegularPolygon':('Construct an n-sided regular polygon, defaulting to n=6 and radius=1. start_angle controls its first vertex.','Construye un polígono regular de n lados, con n=6 y radius=1 por defecto. start_angle controla el primer vértice.'),
 'Triangle':('Construct the n=3 specialization of RegularPolygon. The default first vertex points upward.','Construye la especialización n=3 de RegularPolygon. El primer vértice apunta hacia arriba por defecto.'),
 'CubicBezier':('Construct one cubic Bézier path from an anchor, two control points and a final anchor.','Construye un trazado Bézier cúbico con un ancla inicial, dos controles y un ancla final.'),
 'ValueTracker':('Store one finite number in a Mobject so animation builders and updaters can interpolate it. Initial value defaults to zero.','Guarda un número finito en un Mobject para interpolarlo mediante animaciones y actualizadores. Su valor inicial es cero.'),
 'VectorizedPoint':('Create invisible single-point vector geometry. Artificial width and height default to 0.01 for layout queries.','Crea geometría vectorial invisible de un punto. El ancho y alto artificiales valen 0.01 para las consultas de posición.'),
 'Text':('Shape UTF-8 text with Pango and expose real glyph Mobjects. Supports fonts, style maps, gradients and optional ligature disabling.','Compone texto UTF-8 con Pango y expone Mobjects reales por glifo. Admite fuentes, mapas de estilo, degradados y desactivación opcional de ligaduras.'),
 'MarkupText':('Shape validated Pango markup, preserving nested font, size and foreground attributes. The paragraph width follows upstream at 500 Pango units.','Compone marcado Pango validado y conserva atributos anidados de fuente, tamaño y color. El párrafo usa el ancho de 500 unidades de upstream.'),
 'font_list':('Return a sorted sequence of font-family names available to the current Pango font map. Font installation remains external to the library.','Devuelve una secuencia ordenada de familias disponibles en Pango. La instalación de fuentes es externa a la biblioteca.'),
 'SVGMobject':('Decode an SVG file into real vector shapes. It centers and fits height 2 by default; height=false disables height fitting.','Decodifica un archivo SVG en formas vectoriales reales. Lo centra y ajusta a una altura de 2; height=false desactiva ese ajuste.'),
 'VMobjectFromSVGPath':('Convert SVG path data to cubic geometry. Supports absolute and relative M/L/H/V/C/S/Q/T/A/Z commands, including elliptical arcs.','Convierte datos de trazado SVG en geometría cúbica. Admite M/L/H/V/C/S/Q/T/A/Z absolutos y relativos, incluidos arcos elípticos.'),
 'NumberLine':('Build a numerical line with optional ticks and a triangular tip. Mapping follows later transformations; numeric text labels and nonlinear scales remain pending.','Construye una recta numérica con marcas y punta triangular opcionales. Su correspondencia sigue las transformaciones; faltan etiquetas numéricas y escalas no lineales.'),
 'Axes':('Build two NumberLines with independent ranges and lengths. Use coords_to_point to position objects in the transformed coordinate system.','Construye dos NumberLines con intervalos y longitudes independientes. Usa coords_to_point para colocar objetos en el sistema transformado.'),
 'ParametricFunction':('Sample fn(t), which must return a 2D/3D point, over t_range. Cubic smoothing is enabled unless use_smoothing=false.','Muestrea fn(t), que debe devolver un punto 2D/3D, sobre t_range. El suavizado cúbico está activo salvo use_smoothing=false.'),
 'FunctionGraph':('Construct the graph of a scalar Lua function y=fn(x). The default interval spans the world frame and the default color is yellow.','Construye la gráfica de una función escalar de Lua y=fn(x). El intervalo predeterminado cubre el encuadre y su color es amarillo.'),
 'always_redraw':('Evaluate fn immediately and add an updater that replaces the resulting object geometry with fn() on subsequent updates. fn must return a Mobject.','Evalúa fn inmediatamente y añade un actualizador que sustituye la geometría por fn() en las actualizaciones posteriores. fn debe devolver un Mobject.'),
 'Scene':('Create a scene from a construct callback and configuration table. The callback receives the scene; render executes it with deterministic frame sampling.','Crea una escena a partir de una función construct y una configuración. La función recibe la escena; render la ejecuta con muestreo determinista.'),
 'MovingCameraScene':('Create a Scene with a MovingCamera. Animate scene.camera.frame to pan, scale or rotate its viewport.','Crea una Scene con MovingCamera. Anima scene.camera.frame para mover, escalar o girar el encuadre.'),
 'ThreeDScene':('Create a Scene with ThreeDCamera, perspective projection, orientation trackers and optional shading.','Crea una Scene con ThreeDCamera, proyección en perspectiva, controles de orientación y sombreado opcional.'),
 'Camera':('Create a 2D camera with an invisible rectangular frame. World dimensions are independent of raster resolution.','Crea una cámara 2D con un marco rectangular invisible. Las dimensiones del mundo son independientes de la resolución de imagen.'),
 'MovingCamera':('Create an animated 2D camera. Its frame is a Mobject and can be moved with ordinary animation builders.','Crea una cámara 2D animable. Su frame es un Mobject que puede moverse con los constructores normales de animación.'),
 'ThreeDCamera':('Create a perspective camera. Orientation uses phi/theta/gamma in radians; focal_distance defaults to 20 and zoom to 1.','Crea una cámara en perspectiva. phi/theta/gamma usan radianes; focal_distance vale 20 y zoom vale 1 por defecto.'),
 'ThreeDVMobject':('Create a vector object with 3D shading enabled. Supply actual points with the same cubic path API as VMobject.','Crea un objeto vectorial con sombreado 3D activo. Añade puntos con la misma API de trazados cúbicos de VMobject.'),
 'Cube':('Construct six vector faces with side_length 2, blue fill and 0.75 opacity by default. Face depth and lighting use the 3D camera.','Construye seis caras vectoriales con side_length 2, relleno azul y opacidad 0.75. La cámara 3D determina profundidad e iluminación.'),
 'Sphere':('Construct a parametric spherical mesh with radius 1 and resolution {24,12}. center translates the resulting surface.','Construye una malla esférica paramétrica de radio 1 y resolución {24,12}. center traslada la superficie resultante.'),
 'Surface':('Build cubic mesh faces from fn(u,v). Ranges must increase; resolution may be one integer or {u_count,v_count}.','Construye caras cúbicas de malla a partir de fn(u,v). Los intervalos deben crecer; resolution puede ser un entero o {cantidad_u,cantidad_v}.'),
 'Animation':('Create the base animation lifecycle container. Concrete factories supply visible interpolation; run_time, rate_func and lag_ratio control scheduling.','Crea el contenedor base del ciclo de animación. Las funciones concretas aportan la interpolación visible; run_time, rate_func y lag_ratio controlan los tiempos.'),
 'Create':('Reveal a vector path progressively. Group members use lag_ratio=1 unless overridden; the object is introduced to the scene.','Revela progresivamente un trazado vectorial. Los grupos usan lag_ratio=1 salvo que se indique otro valor; el objeto se añade a la escena.'),
 'Uncreate':('Erase a vector path with reversed Create interpolation and remove it when finished. Default lag_ratio is 1.','Borra un trazado mediante Create invertido y lo retira al terminar. lag_ratio vale 1 por defecto.'),
 'Write':('Animate outlines followed by fills, with glyph-level lag for text. Default duration is 1 second below 15 family members, otherwise 2 seconds.','Anima primero los contornos y después los rellenos, con desfase por glifo en texto. Dura 1 segundo con menos de 15 miembros y 2 en los demás casos.'),
 'Unwrite':('Erase outlines and fills with reversed Write interpolation. reverse defaults to true and restores the original member order on finish.','Borra contornos y rellenos mediante Write invertido. reverse vale true y se restaura el orden original al terminar.'),
 'DrawBorderThenFill':('Draw the outline during the first half of each member’s eased interval, then interpolate to its original fill and stroke.','Dibuja el contorno en la primera mitad del intervalo suavizado de cada miembro y después recupera su relleno y borde originales.'),
 'FadeIn':('Interpolate from a transparent snapshot to the original geometry and style. Optional shift, scale or target_position control the starting state.','Interpola de una copia transparente al estado original. shift, scale o target_position controlan opcionalmente el estado inicial.'),
 'FadeOut':('Interpolate to transparency, optionally shifting or scaling, then remove the object from the scene.','Interpola hacia la transparencia, con traslado o escala opcionales, y retira el objeto de la escena.'),
 'Transform':('Align source and target vector families and interpolate their geometry and style. The source object retains its identity.','Alinea las familias vectoriales de origen y destino e interpola geometría y estilo. El objeto de origen conserva su identidad.'),
 'ReplacementTransform':('Perform Transform and replace the source with the actual target object in the scene when finished.','Ejecuta Transform y sustituye el origen por el objeto de destino real al terminar.'),
 'Rotate':('Interpolate an angle in radians about an axis and pivot. Defaults are PI, the OUT axis and the starting object center.','Interpola un ángulo en radianes alrededor de un eje y un pivote. Los valores iniciales son PI, el eje OUT y el centro inicial.'),
 'MoveAlongPath':('Move the whole object so its center follows a path’s point_from_proportion, including grouped objects.','Mueve el objeto completo para que su centro siga point_from_proportion de un trazado, incluidos los grupos.'),
 'AnimationGroup':('Schedule a nonempty sequence of animations together. lag_ratio controls stagger; backward interpolation is supported.','Programa una secuencia no vacía de animaciones en conjunto. lag_ratio controla el desfase y admite interpolación hacia atrás.'),
 'LaggedStart':('Construct AnimationGroup with default lag_ratio=0.05. Child durations determine natural staggered timing.','Construye AnimationGroup con lag_ratio=0.05. Las duraciones de los hijos determinan el desfase natural.'),
 'Succession':('Run a nonempty sequence of animations consecutively, beginning each child lazily. Evaluation must advance forward.','Ejecuta animaciones consecutivas e inicia cada hija cuando le corresponde. La evaluación debe avanzar hacia delante.'),
 'builder':('Create the low-level animation builder for a Mobject. Prefer object:animate(opts), then chain target operations before Scene:play.','Crea el constructor de animación de bajo nivel. Conviene usar object:animate(opts) y encadenar operaciones antes de Scene:play.'),
 'Renderer':('Own one native Cairo surface and camera. Render actual vector families to PNG; close releases the surface.','Mantiene una superficie Cairo nativa y una cámara. Renderiza familias vectoriales reales a PNG; close libera la superficie.'),
 'vec':('Construct a three-component vector from coordinates or a coordinate table. Missing components default to zero; arithmetic operators are available.','Construye un vector de tres componentes a partir de coordenadas o una tabla. Los componentes ausentes valen cero y admite operadores aritméticos.'),
 'parse':('Parse a supported Manim color name, RGB(A) hex string or unit RGB(A) table. Optional alpha replaces the stored alpha.','Interpreta un nombre de color admitido, hexadecimal RGB(A) o tabla RGB(A) normalizada. alpha sustituye opcionalmente la opacidad.'),
 'interpolate':('Linearly interpolate the four components of two supported colors. The interpolation parameter is not clamped.','Interpola linealmente los cuatro componentes de dos colores admitidos. El parámetro de interpolación no se limita al intervalo unidad.'),
 'color_gradient':('Return length colors interpolated across a nonempty palette. Zero length returns an empty list; a one-element result selects the final color.','Devuelve length colores interpolados sobre una paleta no vacía. Una longitud cero produce una lista vacía y una longitud uno selecciona el color final.'),
 'straight_path':('Return a path function that interpolates corresponding point arrays linearly. Call the returned function with start, finish and alpha.','Devuelve una función que interpola linealmente tablas de puntos correspondientes. Recibe inicio, final y alpha.'),
 'path_along_arc':('Return an array-valued interpolation function following circular arcs of angle radians around axis, defaulting to OUT.','Devuelve una función de interpolación de tablas que sigue arcos de angle radianes alrededor de axis, cuyo valor inicial es OUT.'),
 'path_along_circles':('Return a curved interpolation function using explicit arc centers and an axis. Centers are associated with corresponding points.','Devuelve una interpolación curva mediante centros explícitos de arco y un eje. Los centros corresponden a los puntos de las tablas.'),
 'clockwise_path':('Return path_along_arc(-PI), producing a half-circle clockwise interpolation.','Devuelve path_along_arc(-PI), una interpolación semicircular en sentido horario.'),
 'counterclockwise_path':('Return path_along_arc(PI), producing a half-circle counterclockwise interpolation.','Devuelve path_along_arc(PI), una interpolación semicircular en sentido antihorario.'),
 'linear':('Return the clamped input time unchanged; useful when a constant animation speed is required.','Devuelve el tiempo limitado al intervalo unidad sin modificarlo; sirve para una velocidad constante.'),
 'smooth':('Return normalized logistic easing with default inflection 10, preserving zero and one endpoints.','Devuelve suavizado logístico normalizado con inflexión 10 y conserva los extremos cero y uno.'),
 'smoothstep':('Return cubic easing t²(3−2t), with zero velocity at both endpoints.','Devuelve el suavizado cúbico t²(3−2t), con velocidad nula en ambos extremos.'),
 'smootherstep':('Return quintic easing t³(10−15t+6t²), with smooth endpoint derivatives.','Devuelve el suavizado de quinto grado t³(10−15t+6t²), con derivadas suaves en los extremos.'),
 'smoothererstep':('Return seventh-degree easing 35t⁴−84t⁵+70t⁶−20t⁷.','Devuelve el suavizado de séptimo grado 35t⁴−84t⁵+70t⁶−20t⁷.'),
 'rush_into':('Use the first half of smooth easing, rescaled to reach one; motion accelerates into the endpoint.','Usa la primera mitad del suavizado smooth, ajustada para llegar a uno; el movimiento acelera hacia el final.'),
 'rush_from':('Use the second half of smooth easing, rescaled from zero; motion decelerates toward the endpoint.','Usa la segunda mitad del suavizado smooth, ajustada desde cero; el movimiento desacelera hacia el final.'),
 'slow_into':('Return sqrt(1−(1−t)²), producing a circular ease-out profile.','Devuelve sqrt(1−(1−t)²), con desaceleración circular.'),
 'double_smooth':('Apply smooth separately to each half of the interval while preserving a continuous midpoint.','Aplica smooth a cada mitad del intervalo y conserva un punto medio continuo.'),
 'there_and_back':('Ease from zero to one at t=0.5 and back to zero. Used by groups that support backward evaluation.','Avanza suavemente de cero a uno en t=0.5 y regresa a cero. Se usa en grupos que permiten evaluación hacia atrás.'),
}

API.update({
 'Mobject:add':('Attach child objects by identity, rejecting hierarchy cycles and duplicate direct children. VGroup accepts only vector objects.','Añade hijos por identidad y rechaza ciclos y duplicados directos. VGroup solo admite objetos vectoriales.'),
 'Mobject:remove':('Remove the specified direct children without deleting their geometry or removing unrelated descendants.','Retira los hijos directos indicados sin borrar su geometría ni descendientes ajenos.'),
 'Mobject:copy':('Deep-copy the object graph while preserving shared references within the copy, including Text.chars glyph identity.','Copia el grafo de objetos en profundidad y conserva las referencias compartidas dentro de la copia, incluidos los glifos de Text.chars.'),
 'Mobject:get_family':('Return this object and all descendants once each, in depth-first order, with duplicate identities removed.','Devuelve este objeto y sus descendientes una vez por identidad, en orden de profundidad.'),
 'Mobject:family_members_with_points':('Return unique family members that currently contain geometry, excluding empty group containers.','Devuelve los miembros únicos de la familia que contienen geometría, sin contenedores vacíos.'),
 'Mobject:split':('Return the object sequence: this object if it has points, followed by its direct children. This matches Lua indexing and iteration.','Devuelve la secuencia formada por este objeto si tiene puntos, seguida de sus hijos directos. Coincide con los índices y la iteración de Lua.'),
 'Mobject:slice':('Return an identity-sharing group using inclusive 1-based endpoints and an optional nonzero integer step. Negative indices count from the end.','Devuelve un grupo de referencias compartidas con extremos inclusivos desde 1 y un paso entero distinto de cero. Los índices negativos cuentan desde el final.'),
 'Mobject:invert':('Reverse direct-child order. Pass {recursive=true} to reverse every descendant child sequence as well.','Invierte el orden de los hijos directos. Usa {recursive=true} para invertir también las secuencias de los descendientes.'),
 'Mobject:get_all_points':('Collect geometry recursively, retaining repeated occurrences of shared children as in upstream. The returned vectors are copies.','Recopila la geometría recursivamente y conserva las apariciones repetidas de hijos compartidos, como upstream. Los vectores devueltos son copias.'),
 'Mobject:get_points_defining_boundary':('Collect boundary anchors for vector objects; non-vector objects use all points. This differs from dimension queries, which include control points.','Recopila las anclas de borde de los objetos vectoriales; otros objetos usan todos sus puntos. Las consultas de dimensión incluyen además los controles.'),
 'Mobject:get_critical_point':('Return the bounding-box point indicated by direction. Zero direction components select the midpoint on that axis.','Devuelve el punto de la caja envolvente indicado por direction. Los componentes cero seleccionan el punto medio de ese eje.'),
 'Mobject:get_center':('Return the center of the boundary-anchor bounding box as a vector.','Devuelve como vector el centro de la caja de las anclas de borde.'),
 'Mobject:get_left':('Return the middle of the object’s left boundary, accounting for descendants.','Devuelve el punto medio del borde izquierdo, incluidos los descendientes.'),
 'Mobject:get_right':('Return the middle of the object’s right boundary, accounting for descendants.','Devuelve el punto medio del borde derecho, incluidos los descendientes.'),
 'Mobject:get_top':('Return the middle of the object’s upper boundary, accounting for descendants.','Devuelve el punto medio del borde superior, incluidos los descendientes.'),
 'Mobject:get_bottom':('Return the middle of the object’s lower boundary, accounting for descendants.','Devuelve el punto medio del borde inferior, incluidos los descendientes.'),
 'Mobject:length_over_dim':('Return the extent of all family control points on dimension 1, 2 or 3. An empty family has zero extent.','Devuelve la extensión de todos los controles de la familia en la dimensión 1, 2 o 3. Una familia vacía tiene extensión cero.'),
 'Mobject:get_width':('Return the x extent of family geometry. VectorizedPoint instead returns its artificial width.','Devuelve la extensión x de la geometría familiar. VectorizedPoint devuelve su ancho artificial.'),
 'Mobject:get_height':('Return the y extent of family geometry. VectorizedPoint instead returns its artificial height.','Devuelve la extensión y de la geometría familiar. VectorizedPoint devuelve su alto artificial.'),
 'Mobject:get_depth':('Return the z extent of all family control points; ordinary XY geometry has zero depth.','Devuelve la extensión z de los controles de la familia; la geometría XY tiene profundidad cero.'),
 'Mobject:apply_points_function':('Replace each unique family point with fn(copy_of_point). The result must be a finite 2D/3D coordinate table.','Sustituye cada punto único de la familia por fn(copia_del_punto). Debe devolver una tabla de coordenadas 2D/3D finitas.'),
 'Mobject:shift':('Translate the whole family by the sum of the supplied vectors. Shared descendants are transformed once.','Traslada la familia por la suma de los vectores indicados. Cada descendiente compartido se transforma una vez.'),
 'Mobject:move_to':('Move the selected aligned_edge to a point or another object’s matching boundary. coor_mask can restrict translated axes.','Mueve aligned_edge a un punto o al borde equivalente de otro objeto. coor_mask limita los ejes trasladados.'),
 'Mobject:scale':('Scale geometry uniformly about its center, or about_point/about_edge when supplied. Stroke widths remain unchanged.','Escala uniformemente alrededor del centro, o de about_point/about_edge. Los grosores de borde se conservan.'),
 'Mobject:stretch':('Scale one coordinate dimension, numbered 1=x, 2=y, 3=z, about the selected pivot.','Escala una dimensión: 1=x, 2=y, 3=z, alrededor del pivote seleccionado.'),
 'Mobject:rotate':('Rotate family geometry with Rodrigues’ formula. axis defaults to OUT; about_point/about_edge select the pivot.','Gira la geometría familiar con la fórmula de Rodrigues. axis vale OUT; about_point/about_edge seleccionan el pivote.'),
 'Mobject:apply_matrix':('Apply a finite square 2×2 or 3×3 matrix about the origin, or opts.about_point. A 2×2 matrix preserves z.','Aplica una matriz finita 2×2 o 3×3 alrededor del origen o de opts.about_point. Una matriz 2×2 conserva z.'),
 'Mobject:align_to':('Translate only the nonzero dimensions of direction so the matching boundary aligns with a point or object.','Traslada solo las dimensiones no nulas de direction para alinear el borde correspondiente con un punto u objeto.'),
 'Mobject:next_to':('Position beside a point or object in direction, with buff=0.25 by default. aligned_edge controls perpendicular alignment.','Coloca junto a un punto u objeto en direction, con buff=0.25. aligned_edge controla la alineación perpendicular.'),
 'Mobject:arrange':('Lay out direct children sequentially using next_to, then center the group unless opts.center=false.','Distribuye los hijos directos mediante next_to y centra el grupo salvo opts.center=false.'),
 'Mobject:set_fill':('Update fill color and/or opacity; nil retains the current component. Applies to the family unless opts.family=false.','Actualiza color y opacidad del relleno; nil conserva el componente actual. Afecta a la familia salvo opts.family=false.'),
 'Mobject:set_stroke':('Update stroke color, width and/or opacity; nil preserves each unspecified value. opts.family=false limits changes to this object.','Actualiza color, grosor y opacidad del borde; nil conserva cada valor ausente. opts.family=false limita el cambio a este objeto.'),
 'Mobject:set_color':('Set both fill and stroke color while preserving their opacities. Optional family=false restricts the operation.','Fija el color de relleno y borde y conserva sus opacidades. family=false limita la operación.'),
 'Mobject:set_color_by_gradient':('Distribute colors over geometry-bearing family members, preserving alpha. One color styles the whole family.','Distribuye colores entre los miembros con geometría y conserva alpha. Un color se aplica a toda la familia.'),
 'Mobject:set_opacity':('Set fill and stroke opacity throughout the family. Opacity must be in the unit interval.','Fija la opacidad del relleno y del borde de toda la familia, dentro del intervalo unidad.'),
 'Mobject:fade':('Multiply existing family opacities by 1−darkness. darkness=0 preserves appearance; darkness=1 makes it transparent.','Multiplica las opacidades por 1−darkness. Cero conserva la apariencia y uno la vuelve transparente.'),
 'Mobject:set_z_index':('Set a finite render-order value, including descendants unless family=false. Stable insertion order breaks ties.','Fija el orden de renderizado, incluidos los descendientes salvo family=false. Los empates conservan el orden de inserción.'),
 'Mobject:set_points':('Replace the point array with copied finite vectors. Vector paths require complete cubics or one pending initial anchor.','Sustituye los puntos por copias de vectores finitos. Los trazados requieren cúbicas completas o un ancla inicial pendiente.'),
 'Mobject:set_points_as_corners':('Replace geometry with straight cubic segments joining the supplied corners.','Sustituye la geometría por segmentos cúbicos rectos que unen los vértices indicados.'),
 'Mobject:get_start':('Return a copy of the first stored point; raises an error for empty geometry.','Devuelve una copia del primer punto almacenado y falla si no hay geometría.'),
 'Mobject:get_end':('Return the final path point, or the actual attached tip endpoint when a triangular tip exists.','Devuelve el punto final del trazado o el extremo real de la punta triangular añadida.'),
 'Mobject:get_length':('Return straight-line distance between the start and end. For curve length use get_arc_length.','Devuelve la distancia recta entre inicio y final. Usa get_arc_length para la longitud de una curva.'),
 'Mobject:get_angle':('Return the XY angle from the path start to its end, in radians.','Devuelve en radianes el ángulo XY entre el inicio y el final del trazado.'),
 'Mobject:get_num_curves':('Return the number of complete cubic segments; a pending anchor is not counted as a curve.','Devuelve el número de segmentos cúbicos completos; un ancla pendiente no cuenta como curva.'),
 'Mobject:get_arc_length':('Estimate path length by sampling each cubic, using ten samples per curve by default.','Estima la longitud del trazado muestreando cada cúbica, con diez muestras por curva por defecto.'),
 'Mobject:point_from_proportion':('Return a point at proportion alpha, weighted by estimated cubic lengths. alpha must lie between zero and one.','Devuelve el punto de proporción alpha, ponderado por las longitudes cúbicas estimadas. alpha debe estar entre cero y uno.'),
 'Mobject:pointwise_become_partial':('Replace this path with the portion of another between proportions a and b. The other object is preserved.','Sustituye este trazado por el tramo de otro entre las proporciones a y b. El otro objeto se conserva.'),
 'Mobject:get_subcurve':('Return an independent copy restricted to the selected parameter interval; closed paths support wrapped intervals.','Devuelve una copia independiente limitada al intervalo seleccionado; los trazados cerrados admiten intervalos que cruzan el cierre.'),
 'Mobject:reverse_direction':('Reverse the stored curve order and each cubic’s direction throughout the family.','Invierte el orden de las curvas almacenadas y el sentido de cada cúbica de la familia.'),
 'Mobject:get_subpaths':('Split the stored point array into connected cubic subpaths without changing geometry.','Separa los puntos almacenados en subtrazados cúbicos conectados sin modificar la geometría.'),
 'Mobject:clear_points':('Remove this object’s stored geometry while keeping children, style and updaters.','Elimina la geometría de este objeto y conserva hijos, estilo y actualizadores.'),
 'Mobject:append_points':('Append copied points to the current array, preserving existing subpath structure.','Añade copias de puntos al final y conserva la estructura de subtrazados existente.'),
 'Mobject:has_new_path_started':('Report whether the point array ends with one pending anchor after its complete cubic segments.','Indica si hay un ancla pendiente después de los segmentos cúbicos completos.'),
 'Mobject:get_last_point':('Return the last stored point, including a pending anchor. It can differ from an arrow’s visible tip endpoint.','Devuelve el último punto almacenado, incluida un ancla pendiente. Puede diferir del extremo visible de una flecha.'),
 'Mobject:start_new_path':('Append a pending anchor to begin a disconnected subpath. Complete any existing pending curve first.','Añade un ancla pendiente para iniciar un subtrazado desconectado. Completa antes cualquier curva pendiente.'),
 'Mobject:add_cubic_bezier_curve':('Append a complete cubic from two anchors and two handles. The existing array must end at a complete curve boundary.','Añade una cúbica completa con dos anclas y dos controles. La tabla existente debe terminar en una curva completa.'),
 'Mobject:add_cubic_bezier_curve_to':('Continue the current subpath using two handles and a new anchor, consuming a pending initial anchor if present.','Continúa el subtrazado con dos controles y un ancla nueva; consume el ancla inicial pendiente si existe.'),
 'Mobject:add_quadratic_bezier_curve_to':('Continue with a quadratic Bézier, elevated exactly to cubic form from one handle and a final anchor.','Continúa con una Bézier cuadrática elevada exactamente a cúbica mediante un control y un ancla final.'),
 'Mobject:add_line_to':('Continue the current subpath with a straight cubic ending at point.','Continúa el subtrazado con una cúbica recta que termina en point.'),
 'Mobject:add_points_as_corners':('Append successive straight segments to each supplied point, using the current final anchor as the start.','Añade segmentos rectos sucesivos a los puntos indicados desde el ancla final actual.'),
 'Mobject:add_subpath':('Append a disconnected point array containing only complete cubics.','Añade una tabla de puntos desconectada formada únicamente por cúbicas completas.'),
 'Mobject:is_closed':('Report whether the first and final stored points agree within the path closure tolerance.','Indica si el primer y último punto coinciden dentro de la tolerancia de cierre.'),
 'Mobject:close_path':('Close the current connected subpath with a line to its first anchor when needed.','Cierra el subtrazado actual con una línea hasta su primera ancla cuando hace falta.'),
 'Mobject:get_start_anchors':('Return the first point of every complete cubic, including a pending final start anchor.','Devuelve el primer punto de cada cúbica, incluida el ancla inicial final si está pendiente.'),
 'Mobject:get_end_anchors':('Return the last point of every complete cubic segment.','Devuelve el último punto de cada segmento cúbico completo.'),
 'Mobject:get_anchors':('Return the interleaved start and end anchors of complete curves, or the lone pending point.','Devuelve las anclas iniciales y finales intercaladas de las curvas completas, o el único punto pendiente.'),
 'Mobject:insert_n_curves':('Add n cubic segments by exact subdivision/remapping while preserving the represented path.','Añade n segmentos cúbicos mediante subdivisión o redistribución exacta sin cambiar el trazado representado.'),
 'Mobject:get_point_mobject':('Return invisible point geometry at center, defaulting to this object’s center; used for vector-family alignment.','Devuelve geometría puntual invisible en center o en el centro actual; se usa al alinear familias vectoriales.'),
 'Mobject:push_self_into_submobjects':('Move this object’s own geometry into a copied child, leaving the parent as an empty group container.','Mueve la geometría propia a un hijo copiado y deja el padre como contenedor vacío.'),
 'Mobject:add_n_more_submobjects':('Expand a vector family with faded duplicates or invisible point children according to upstream alignment rules.','Amplía una familia vectorial con duplicados transparentes o hijos puntuales según las reglas de alineación de upstream.'),
 'Mobject:align_points':('Equalize vector subpath and curve counts against another object, preserving shape through subdivision and null paths.','Iguala los subtrazados y curvas con otro objeto y conserva la forma mediante subdivisión y trazados nulos.'),
 'Mobject:align_data':('Align both vector family structure and geometry with another object. This mutates both and underpins Transform.','Alinea estructura familiar y geometría con otro objeto. Modifica ambos y sirve de base a Transform.'),
 'Mobject:set_points_smoothly':('Replace geometry with the source-derived open or closed cubic spline through the supplied anchors.','Sustituye la geometría por la spline cúbica abierta o cerrada que pasa por las anclas indicadas.'),
 'Mobject:make_smooth':('Rebuild connected subpaths as cubic splines through their current anchors.','Reconstruye los subtrazados conectados como splines cúbicas a través de sus anclas actuales.'),
 'Mobject:become':('Copy geometry and style recursively from another object while retaining this object’s identity and updater list.','Copia recursivamente geometría y estilo de otro objeto y conserva la identidad y los actualizadores del receptor.'),
 'Mobject:add_updater':('Append fn(object,dt). Pass {call_updater=true} to call it immediately with dt=0. Return this object.','Añade fn(objeto,dt). Usa {call_updater=true} para llamarla inmediatamente con dt=0. Devuelve este objeto.'),
 'Mobject:remove_updater':('Remove callbacks with the exact function identity supplied. Other registered callbacks are preserved.','Retira los callbacks con la identidad de función indicada y conserva los demás.'),
 'Mobject:clear_updaters':('Clear family updater lists; opts.recursive=false limits clearing to the receiver.','Vacía los actualizadores de la familia; opts.recursive=false limita el cambio al receptor.'),
 'Mobject:suspend_updating':('Suspend updater evaluation, recursively unless opts.recursive=false. Animations normally suspend their subject during interpolation.','Suspende los actualizadores, recursivamente salvo opts.recursive=false. Las animaciones suelen suspender su objeto durante la interpolación.'),
 'Mobject:resume_updating':('Resume updater evaluation and synchronize the object at dt=0, recursively by default.','Reanuda los actualizadores y sincroniza el objeto con dt=0, de forma recursiva por defecto.'),
 'Mobject:update':('Execute active updaters with finite dt and update children unless opts.recursive=false. Suspended objects are skipped.','Ejecuta actualizadores activos con dt finito y actualiza hijos salvo opts.recursive=false. Omite los objetos suspendidos.'),
 'Mobject:save_state':('Store a deep state snapshot for later restore. Subsequent edits do not modify the saved geometry.','Guarda una instantánea profunda para restore. Los cambios posteriores no modifican la geometría guardada.'),
 'Mobject:restore':('Restore the saved geometry/style while keeping this object’s identity; fails when no snapshot exists.','Restaura la geometría y estilo guardados y conserva la identidad; falla si no existe una instantánea.'),
 'Mobject:animate':('Return a builder that records chained operations on a copied target. Pass the builder to Scene:play.','Devuelve un constructor que aplica operaciones encadenadas a una copia de destino. Se entrega a Scene:play.'),
 'Mobject:get_font_size':('For nonempty Text/MarkupText, return the font size implied by current height relative to initial height.','En Text/MarkupText no vacíos, devuelve el tamaño de fuente derivado del alto actual respecto al inicial.'),
 'Mobject:set_font_size':('Resize nonempty Text/MarkupText geometrically to a positive finite size. The font_size property delegates to this method.','Ajusta geométricamente Text/MarkupText no vacíos a un tamaño positivo y finito. La propiedad font_size usa este método.'),
 'Mobject:get_location':('For VectorizedPoint, return a copy of its stored position.','En VectorizedPoint, devuelve una copia de su posición almacenada.'),
 'Mobject:set_location':('For VectorizedPoint, replace its position with a finite vector and return the point object.','En VectorizedPoint, sustituye la posición por un vector finito y devuelve el objeto.'),
 'Mobject:get_value':('For ValueTracker, return its current finite scalar value.','En ValueTracker, devuelve el valor escalar actual.'),
 'Mobject:set_value':('For ValueTracker, replace the stored scalar and return the tracker for chaining.','En ValueTracker, sustituye el escalar y devuelve el objeto para encadenar llamadas.'),
 'Mobject:increment_value':('For ValueTracker, add a finite scalar to the stored value and return the tracker.','En ValueTracker, suma un escalar finito al valor y devuelve el objeto.'),
 'Mobject:add_tip':('Attach one filled triangular tip to a straight XY path, shortening its stored line to the tip base. 3D tips are rejected.','Añade una punta triangular rellena a un trazado XY recto y recorta la línea hasta su base. Las puntas 3D se rechazan.'),
 'Mobject:number_to_point':('For NumberLine, map a scalar or sequence of numbers into scene points using the transformed axis endpoints.','En NumberLine, transforma un escalar o una secuencia de números en puntos usando los extremos transformados del eje.'),
 'Mobject:point_to_number':('For NumberLine, project one scene point or a point sequence onto the transformed numerical axis.','En NumberLine, proyecta un punto de escena o una secuencia sobre el eje numérico transformado.'),
 'Mobject:get_tick_range':('For NumberLine, return sorted numerical tick positions, honoring the origin-exclusion and tip options.','En NumberLine, devuelve las posiciones ordenadas de las marcas y respeta la exclusión del origen y la punta.'),
 'Mobject:get_tick':('For NumberLine, create a styled tick centered at number x, using tick_size unless an explicit size is supplied.','En NumberLine, crea una marca con estilo en el número x y usa tick_size salvo que se indique un tamaño.'),
 'Mobject:coords_to_point':('For Axes, map x,y or coordinate sequences to scene points. The mapping follows transformations applied to the axes.','En Axes, transforma x,y o secuencias de coordenadas en puntos. La correspondencia sigue las transformaciones de los ejes.'),
 'Mobject:point_to_coords':('For Axes, recover the two numerical coordinates of a scene point or a sequence of points.','En Axes, recupera las dos coordenadas numéricas de un punto o una secuencia de puntos.'),
 'Mobject:plot':('For Axes, sample y=fn(x) in the axes coordinate system. x_range optionally changes the interval and sampling step.','En Axes, muestrea y=fn(x) en sus coordenadas. x_range cambia opcionalmente el intervalo y el paso.'),
 'Mobject:get_axes':('For Axes, return its identity-sharing group containing x_axis and y_axis.','En Axes, devuelve el grupo de referencias compartidas que contiene x_axis e y_axis.'),
 'Mobject:get_origin':('For Axes, return the scene position corresponding to numerical coordinates {0,0}.','En Axes, devuelve la posición de escena correspondiente a las coordenadas {0,0}.'),
 'Mobject:get_tick_marks':('For NumberLine, return the actual group of generated tick Mobjects.','En NumberLine, devuelve el grupo real de Mobjects de marcas generadas.'),
 'Mobject:get_unit_size':('For NumberLine, return scene length per numerical unit using the current endpoint distance.','En NumberLine, devuelve la longitud de escena por unidad numérica usando la distancia actual entre extremos.'),
 'Mobject:get_function':('For parametric objects, return the validated Lua sampling function stored on the object.','En objetos paramétricos, devuelve la función de muestreo Lua validada que guarda el objeto.'),
 'Mobject:get_point_from_function':('Evaluate a parametric object’s stored sampling function at finite t and return its point.','Evalúa la función paramétrica almacenada en un t finito y devuelve su punto.'),
})

API.update({
 'Scene:add':('Add objects in render order, moving an already-present object to the end. Geometry is shared with the caller.','Añade objetos en orden de renderizado y mueve al final los ya presentes. La geometría se comparte con quien llama.'),
 'Scene:remove':('Remove objects and their family members from the scene. Unremoved siblings of affected groups remain visible.','Retira objetos y sus familias de la escena. Los hermanos no retirados de grupos afectados siguen visibles.'),
 'Scene:replace':('Replace a scene object or nested child with a new object, preserving its position in the scene hierarchy.','Sustituye un objeto de escena o un hijo anidado y conserva su posición en la jerarquía.'),
 'Scene:play':('Execute animations or builders. A final options table controls run_time, rate_func and lag_ratio; frames sample k/fps before the logical endpoint.','Ejecuta animaciones o constructores. Una tabla final controla run_time, rate_func y lag_ratio; los fotogramas muestrean k/fps antes del extremo lógico.'),
 'Scene:wait':('Advance logical time while evaluating active updaters and rendering frames. Duration defaults to one second and may be zero.','Avanza el tiempo lógico, ejecuta actualizadores y renderiza fotogramas. La duración predeterminada es un segundo y puede ser cero.'),
 'Scene:update_mobjects':('Evaluate active scene-family updaters once per object identity for the supplied dt.','Evalúa los actualizadores activos de la escena una vez por identidad con el dt indicado.'),
 'Scene:render':('Execute construct with resolved configuration and write actual PNG/MP4/GIF/WebM output. Return output, frame_count, duration, scene_time and optional frame_dir.','Ejecuta construct con la configuración resuelta y escribe PNG/MP4/GIF/WebM reales. Devuelve output, frame_count, duration, scene_time y opcionalmente frame_dir.'),
 'Scene:set_camera_orientation':('For ThreeDScene, set phi/theta/gamma, zoom, focal_distance and optionally frame_center without animation.','En ThreeDScene, fija phi/theta/gamma, zoom, focal_distance y opcionalmente frame_center sin animación.'),
 'Scene:move_camera':('For ThreeDScene, animate supplied camera trackers and optional frame_center using normal scene timing options.','En ThreeDScene, anima los controles de cámara y frame_center opcional con los tiempos normales de escena.'),
 'Scene:add_fixed_in_frame_mobjects':('Add objects and register their families as fixed camera overlays, unaffected by 3D projection.','Añade objetos y registra sus familias como elementos fijos de cámara, sin proyección 3D.'),
 'Renderer:render':('Clear the surface, collect unique geometry, sort by z/depth, apply camera projection and write one PNG file.','Limpia la superficie, recopila geometría única, ordena por z/profundidad, aplica la cámara y escribe un PNG.'),
 'Renderer:close':('Release the native Cairo context and surface. Repeated close calls are safe; further rendering raises an error.','Libera el contexto y la superficie Cairo. Se puede cerrar varias veces; renderizar después produce un error.'),
 'Renderer.encode':('Encode a numbered PNG frame directory with FFmpeg as MP4, GIF or WebM at fps. Call this static helper with a dot. MP4 uses yuv420p and requires even dimensions.','Codifica una carpeta de PNG numerados con FFmpeg a MP4, GIF o WebM. Esta función estática se llama con punto. MP4 usa yuv420p y exige dimensiones pares.'),
 'Camera:get_frame_center':('Return the current world frame center. ThreeDCamera uses its independent center tracker.','Devuelve el centro actual del encuadre. ThreeDCamera usa su control de centro independiente.'),
 'Camera:get_frame_width':('Return the current frame rectangle width in scene units.','Devuelve el ancho actual del marco en unidades de escena.'),
 'Camera:get_frame_height':('Return the current frame rectangle height in scene units.','Devuelve el alto actual del marco en unidades de escena.'),
 'Camera:copy':('Deep-copy camera state, trackers, frame and fixed-object registration tables.','Copia profundamente el estado de cámara, los controles, el marco y los registros de objetos fijos.'),
 'Camera:get_value_trackers':('For ThreeDCamera, return phi, theta, focal-distance, gamma and zoom trackers in that order.','En ThreeDCamera, devuelve los controles de phi, theta, distancia focal, gamma y zoom, en ese orden.'),
 'Camera:rotate_point':('Rotate a point into ThreeDCamera orientation without perspective division or frame-center subtraction.','Gira un punto a la orientación de ThreeDCamera sin división de perspectiva ni resta del centro.'),
 'Camera:generate_rotation_matrix':('For ThreeDCamera, return the 3×3 orientation matrix formed from the rotated basis vectors.','En ThreeDCamera, devuelve la matriz de orientación 3×3 formada por los vectores base girados.'),
 'Camera:project_point':('Project one world point through the 3D camera. The returned z is retained for depth; exact focal-plane points are rejected.','Proyecta un punto del mundo con la cámara 3D. Conserva z para profundidad y rechaza los puntos exactamente en el plano focal.'),
 'Camera:project_points':('Project a sequence of world points with the same 3D camera transformation.','Proyecta una secuencia de puntos con la misma transformación de cámara 3D.'),
 'Camera:transform_points':('Apply projection or the registered fixed-frame/fixed-orientation rule for the supplied object. 2D cameras preserve points.','Aplica la proyección o la regla fija registrada para el objeto. Las cámaras 2D conservan los puntos.'),
 'Camera:add_fixed_in_frame_mobjects':('Register whole object families as fixed overlays. Registration alone does not add objects to a Scene.','Registra familias completas como elementos fijos. El registro por sí solo no añade objetos a una Scene.'),
 'Camera:remove_fixed_in_frame_mobjects':('Unregister supplied object families so normal camera projection applies again.','Elimina el registro fijo de las familias indicadas para recuperar la proyección normal.'),
 'Camera:add_fixed_orientation_mobjects':('Keep each family member’s orientation fixed while translating its center by the camera projection.','Conserva la orientación de cada miembro y traslada su centro según la proyección de cámara.'),
 'Camera:depth':('Return the oriented center depth used to sort shaded 3D objects, or infinity for other objects.','Devuelve la profundidad del centro orientado para ordenar objetos 3D sombreados, o infinito para los demás.'),
 'Camera:shading':('Compute the renderer’s two-stop fill/stroke lighting gradient for shaded vector geometry. Returns nil when shading does not apply.','Calcula el degradado de iluminación de dos extremos para geometría sombreada. Devuelve nil cuando no corresponde.'),
 'Animation:begin':('Initialize snapshots and alignment, register with an optional scene, suspend subject updaters and evaluate alpha=0. An animation cannot be reused.','Inicializa copias y alineación, registra una escena opcional, suspende actualizadores y evalúa alpha=0. Una animación no puede reutilizarse.'),
 'Animation:interpolate':('Evaluate a begun animation at a finite alpha clamped to [0,1], applying per-member lag and the selected rate function.','Evalúa una animación iniciada con alpha finito limitado a [0,1], con desfase por miembro y la función de suavizado elegida.'),
 'Animation:finish':('Evaluate the endpoint once, resume updaters, perform remover/replacement cleanup and restore reversed family order.','Evalúa una vez el extremo, reanuda actualizadores, retira o sustituye objetos y restaura el orden invertido.'),
 'Animation:update_mobjects':('Run updaters on the animation’s starting/target snapshots with dt. The suspended subject is managed by the scene.','Ejecuta actualizadores de las copias iniciales y finales con dt. La escena gestiona el objeto suspendido.'),
 'AnimationGroup:begin':('Begin a composition once. Groups start all children; Succession starts each child only when its interval is reached.','Inicia una composición una vez. Los grupos inician todas las hijas; Succession las inicia al alcanzar sus intervalos.'),
 'AnimationGroup:interpolate':('Map alpha through the composition rate function to child intervals. Groups permit backward evaluation; Succession advances forward.','Transforma alpha mediante el suavizado de la composición y los intervalos de las hijas. Los grupos admiten retroceso; Succession avanza hacia delante.'),
 'AnimationGroup:finish':('Finish all started child animations and complete scene cleanup once.','Finaliza las animaciones hijas y completa una vez la limpieza de escena.'),
 'AnimationGroup:update_mobjects':('Update snapshots for started children; finished Succession children are skipped.','Actualiza las copias de las hijas iniciadas y omite las ya terminadas de Succession.'),
 'vec.dot':('Return the scalar dot product of two three-component vectors.','Devuelve el producto escalar de dos vectores de tres componentes.'),
 'vec.cross':('Return the right-handed cross product as a new vector.','Devuelve el producto vectorial según la regla de la mano derecha como un vector nuevo.'),
 'vec.norm':('Return Euclidean vector length computed from the dot product.','Devuelve la longitud euclidiana calculada a partir del producto escalar.'),
 'vec.normalize':('Return a unit vector in the same direction; a zero vector is rejected.','Devuelve un vector unitario con la misma dirección y rechaza el vector cero.'),
 'vec.lerp':('Linearly interpolate vector coordinates with parameter t. Values outside [0,1] extrapolate.','Interpola linealmente las coordenadas con t. Los valores fuera de [0,1] extrapolan.'),
 'vec.rotate':('Rotate a vector by angle radians around a normalized axis using Rodrigues’ formula.','Gira un vector angle radianes alrededor de un eje normalizado mediante la fórmula de Rodrigues.'),
 'vec.close':('Compare vector distance to tolerance; returns a boolean instead of changing either input.','Compara la distancia entre vectores con tolerance y devuelve un booleano sin modificarlos.'),
 'bezier.point':('Evaluate one four-point cubic Bézier with de Casteljau interpolation at t.','Evalúa una Bézier cúbica de cuatro puntos en t mediante interpolación de Casteljau.'),
 'bezier.split':('Split a cubic at t into two exact cubic point arrays.','Divide una cúbica en t y devuelve dos tablas cúbicas exactas.'),
 'bezier.partial':('Return the exact cubic representing a subinterval [a,b] of one curve.','Devuelve la cúbica exacta que representa el subintervalo [a,b] de una curva.'),
 'bezier.length':('Estimate one cubic’s length by a polyline with the requested sample count, defaulting to ten.','Estima la longitud de una cúbica mediante una polilínea con diez muestras por defecto.'),
 'bezier.curves':('Split a flat path array into independent four-point cubic arrays.','Divide una tabla plana de trazado en tablas cúbicas independientes de cuatro puntos.'),
 'bezier.append':('Append copied curve points to an existing flat point array in place.','Añade copias de los puntos de una curva a una tabla plana existente.'),
 'bezier.line':('Return the four cubic control points of the straight line joining a and b.','Devuelve los cuatro controles cúbicos de la recta entre a y b.'),
 'bezier.remap':('Redistribute an existing path to a larger requested cubic count using exact subdivision.','Redistribuye un trazado a una cantidad mayor de cúbicas mediante subdivisión exacta.'),
 'bezier.subpaths':('Partition flat cubic geometry at disconnected anchors and preserve one pending start anchor if present.','Divide geometría cúbica plana por sus anclas desconectadas y conserva un ancla pendiente si existe.'),
 'bezier.smooth':('Build a smooth cubic spline through open or closed anchors with the upstream linear-time handle solver.','Construye una spline cúbica suave por anclas abiertas o cerradas con el algoritmo lineal de controles de upstream.'),
 'bezier.partial_path':('Extract a multi-cubic path interval by curve proportion, supporting wrapped closed intervals.','Extrae un intervalo de trazado multicúbico por proporción de curvas y permite intervalos cerrados que cruzan el cierre.'),
 'config.resolve':('Merge options over config.defaults, validate raster/world dimensions and timing, and derive the background RGBA color.','Combina opciones con config.defaults, valida dimensiones y tiempos y obtiene el color RGBA de fondo.'),
})

for key,en,es in [
 ('phi','polar tilt angle in radians','ángulo de inclinación polar en radianes'),
 ('theta','azimuth angle in radians','ángulo azimutal en radianes'),
 ('gamma','camera roll angle in radians','ángulo de giro de la cámara en radianes'),
 ('zoom','dimensionless projection zoom','aumento adimensional de la proyección'),
 ('focal_distance','perspective focal distance in scene units','distancia focal en unidades de escena'),
]:
 API['Camera:get_'+key]=(f'Return the ThreeDCamera {en} from its ValueTracker.',f'Devuelve el {es} de ThreeDCamera desde su ValueTracker.')
 API['Camera:set_'+key]=(f'Set the finite ThreeDCamera {en} and return the camera. Focal distance must remain positive when projected.',f'Fija el {es} de ThreeDCamera y devuelve la cámara. La distancia focal debe ser positiva al proyectar.')

# Option rows: name, Lua type, default, English meaning, Spanish meaning.
STYLE=[
 ('color','color','WHITE','Base fill/stroke RGB; classes may override this default.','RGB base de relleno y borde; cada figura puede cambiar este valor.'),
 ('fill_color','color','color','Fill RGB, retaining the separate fill opacity.','RGB del relleno, separado de su opacidad.'),
 ('fill_opacity','number','0','Fill alpha in [0,1].','Opacidad del relleno en [0,1].'),
 ('stroke_color','color','color','Stroke RGB.','RGB del borde.'),
 ('stroke_width','number','4','Nonnegative stroke width; the Cairo world-unit factor is 0.01.','Grosor no negativo; el factor Cairo en unidades de mundo es 0.01.'),
 ('stroke_opacity','number','1','Stroke alpha in [0,1].','Opacidad del borde en [0,1].'),
 ('z_index','number','0','Stable render ordering, after the 3D depth key when applicable.','Orden estable de renderizado, después de la profundidad 3D cuando corresponda.'),
 ('joint_type','string','miter','One of miter, round or bevel.','Uno de miter, round o bevel.'),
 ('cap_style','string','butt','One of butt, round or square.','Uno de butt, round o square.'),
 ('shade_in_3d','boolean','false','Enable per-face 3D lighting and depth sorting.','Activa iluminación y orden por profundidad de caras 3D.'),
]
CONFIG=[
 ('pixel_width','integer','854','Raster width in pixels. Native surfaces allow at most 16384 per side and 64M total pixels.','Ancho de imagen en píxeles. Las superficies permiten hasta 16384 por lado y 64M píxeles en total.'),
 ('pixel_height','integer','480','Raster height in pixels. MP4 dimensions must be even.','Alto en píxeles. Las dimensiones de MP4 deben ser pares.'),
 ('frame_width','number','128/9','World width, independent of raster aspect ratio.','Ancho del mundo, independiente de la proporción de imagen.'),
 ('frame_height','number','8','World height; must be positive.','Alto del mundo; debe ser positivo.'),
 ('frame_rate','number','30','Frames per second, in (0,1000].','Fotogramas por segundo, en (0,1000].'),
 ('background_color','color','BLACK','Canvas RGB.','RGB del fondo.'),
 ('background_opacity','number','1','Canvas alpha; PNG transparency has executed coverage.','Opacidad del fondo; la transparencia PNG está comprobada.'),
 ('frame_center','vector','ORIGIN','Initial world center of the camera.','Centro inicial de la cámara en el mundo.'),
]
ANIMATION=[
 ('run_time','number','1','Nonnegative logical duration in seconds; individual factories can use another default.','Duración lógica no negativa en segundos; cada función puede usar otro valor predeterminado.'),
 ('rate_func','function','smooth','Maps normalized member time to interpolation alpha.','Transforma el tiempo normalizado de cada miembro en alpha.'),
 ('lag_ratio','number','0','Nonnegative stagger between geometry-bearing family members.','Desfase no negativo entre miembros familiares con geometría.'),
 ('suspend_mobject_updating','boolean','true','Suspend subject updaters while its animation is active.','Suspende los actualizadores del objeto durante la animación.'),
 ('reverse_rate_function','boolean','false','Evaluate the rate function at 1−member_time.','Evalúa la función temporal en 1−tiempo_del_miembro.'),
 ('remover','boolean','false','Remove the subject on completion; erasing factories use their own defaults.','Retira el objeto al terminar; las funciones de borrado tienen sus propios valores.'),
]
TRANSFORM=[
 ('path_arc','number','0','Curved interpolation angle in radians.','Ángulo de interpolación curva en radianes.'),
 ('path_arc_axis','vector','OUT','Axis of curved interpolation.','Eje de interpolación curva.'),
 ('path_arc_centers','vector or vector[]','nil','Explicit common or per-point circular centers.','Centros circulares comunes o por punto.'),
 ('path_func','function','derived from path_arc','Callback (start_points,end_points,alpha) returning an equally sized point array.','Callback (puntos_inicio,puntos_final,alpha) que devuelve una tabla del mismo tamaño.'),
]
TEXT=[
 ('font','string','""','Pango font family; an empty name uses the context default.','Familia Pango; el nombre vacío usa la del contexto.'),
 ('font_size','number','48','Positive public point size, up to 10000.','Tamaño público positivo, hasta 10000.'),
 ('weight','string','NORMAL','NORMAL, BOLD or LIGHT as constructor-level weights. Markup spans support Pango weights.','NORMAL, BOLD o LIGHT en el constructor. Los spans de marcado admiten los pesos de Pango.'),
 ('slant','string','NORMAL','NORMAL, ITALIC or OBLIQUE.','NORMAL, ITALIC u OBLIQUE.'),
 ('line_spacing','number','-1','Text line advance: size×1.3 by default, otherwise size×(1+value). Markup follows Pango.','Avance de línea Text: tamaño×1.3 por defecto o tamaño×(1+valor). Markup usa Pango.'),
 ('tab_width','integer','4','Text expands tabs before styling. Markup retains upstream Pango tab layout.','Text expande tabuladores antes del estilo. Markup conserva la distribución Pango de upstream.'),
 ('disable_ligatures','boolean','false','Disable liga/dlig/clig/hlig features. Text inserts invisible whitespace Mobjects.','Desactiva liga/dlig/clig/hlig. Text inserta Mobjects invisibles para espacios.'),
 ('should_center','boolean','true','Center the imported glyph group.','Centra el grupo de glifos importado.'),
 ('height','number','nil','Fit height; disables the ordinary 0.05 font-geometry scale.','Ajusta el alto y desactiva la escala ordinaria de geometría de fuente 0.05.'),
 ('width','number','nil','Fit width after height when supplied.','Ajusta el ancho después del alto si se indica.'),
 ('gradient','color[]','nil','Text colors separate shaping runs; MarkupText colors final glyph family members.','Text colorea tramos de composición separados; MarkupText colorea los miembros finales de la familia.'),
]
NUMBER_LINE=[
 ('x_range','number[]','{-7,7,1}','Increasing {minimum,maximum[,step]}; step must be positive.','{mínimo,máximo[,paso]} creciente; el paso debe ser positivo.'),
 ('length','number','range span × unit_size','World length before rotation.','Longitud de mundo antes de girar.'),
 ('unit_size','number','1','World length per numerical unit when length is omitted.','Longitud de mundo por unidad numérica si no se indica length.'),
 ('include_ticks','boolean','true','Generate tick submobjects.','Genera subobjetos de marcas.'),
 ('tick_size','number','0.1','Half-length of an ordinary tick.','Semilongitud de una marca normal.'),
 ('include_tip','boolean','false','Attach one triangular positive-end tip.','Añade una punta triangular al extremo positivo.'),
 ('exclude_origin_tick','boolean','false','Omit the zero tick.','Omite la marca del cero.'),
 ('numbers_with_elongated_ticks','number[]','{}','Numerical positions whose tick length is multiplied.','Posiciones cuyas marcas se alargan.'),
 ('longer_tick_multiple','number','2','Multiplier for designated long ticks.','Multiplicador de las marcas largas.'),
 ('rotation','number','0','Initial XY rotation in radians.','Giro XY inicial en radianes.'),
]
SURFACE=[
 ('u_range','number[]','{0,1}','Increasing two-endpoint u interval.','Intervalo u creciente de dos extremos.'),
 ('v_range','number[]','{0,1}','Increasing two-endpoint v interval.','Intervalo v creciente de dos extremos.'),
 ('resolution','integer or integer[]','32','Face counts per parameter, or {u_count,v_count}; at most 65536 faces.','Cantidad de caras por parámetro o {cantidad_u,cantidad_v}; hasta 65536 caras.'),
 ('checkerboard_colors','color[] or false','{BLUE_D,"#236B8E"}','Alternating face colors, or false to retain one fill.','Colores alternos de cara o false para conservar un relleno.'),
 ('should_make_jagged','boolean','false','Use straight face edges instead of derivative-based cubic handles.','Usa bordes rectos en lugar de controles cúbicos derivados.'),
 ('pre_function_handle_to_anchor_scale_factor','number','1e-5','Positive finite-difference step factor for curved faces.','Factor positivo de diferencia finita para caras curvas.'),
]
OPTIONS={
 'Mobject':STYLE,'VMobject':STYLE,'ThreeDVMobject':STYLE,
 'Arc':[('radius','number','1','Circle radius.','Radio del círculo.'),('angle','number','PI/2','Signed sweep in radians.','Barrido con signo en radianes.'),('start_angle','number','0','Starting direction.','Dirección inicial.'),('num_components','integer','9','At least two; cubic count is one less.','Al menos dos; la cantidad de cúbicas es uno menos.'),('arc_center','vector','ORIGIN','Center of the source circle.','Centro del círculo de origen.')]+STYLE,
 'Circle':[('radius','number','1','Circle radius.','Radio del círculo.')]+STYLE,
 'Dot':[('radius','number','0.08','Dot radius; zero creates invisible coincident geometry.','Radio; cero crea geometría coincidente invisible.')]+STYLE,
 'Ellipse':[('width','number','2','Horizontal diameter.','Diámetro horizontal.'),('height','number','1','Vertical diameter.','Diámetro vertical.')]+STYLE,
 'Line':[('buff','number','0','Nonnegative endpoint trimming distance.','Distancia no negativa de recorte de extremos.')]+STYLE,
 'Rectangle':[('width','number','4','Rectangle width.','Ancho del rectángulo.'),('height','number','2','Rectangle height.','Alto del rectángulo.')]+STYLE,
 'Square':[('side_length','number','2','Length of each side.','Longitud de cada lado.')]+STYLE,
 'Polygon':STYLE,'CubicBezier':STYLE,
 'RegularPolygon':[('n','integer','6','At least three sides.','Al menos tres lados.'),('radius','number','1','Circumradius.','Circunradio.'),('start_angle','number','parity-dependent','First vertex angle; zero for even n, PI/2 for odd n.','Ángulo del primer vértice: cero con n par y PI/2 con n impar.')]+STYLE,
 'VectorizedPoint':[('artificial_width','number','0.01','Width reported to layout.','Ancho usado para posicionamiento.'),('artificial_height','number','0.01','Height reported to layout.','Alto usado para posicionamiento.')],
 'Text':TEXT+STYLE,'MarkupText':TEXT+[('justify','boolean','false','Justify wrapped paragraph lines.','Justifica las líneas de párrafo.')]+STYLE,
 'NumberLine':NUMBER_LINE+STYLE,
 'Axes':[('x_range','number[]','{-7,7,1}','Horizontal numerical interval.','Intervalo numérico horizontal.'),('y_range','number[]','{-4,4,1}','Vertical numerical interval.','Intervalo numérico vertical.'),('x_length','number','12','Horizontal world length.','Longitud horizontal del mundo.'),('y_length','number','6','Vertical world length.','Longitud vertical del mundo.'),('tips','boolean','true','Enable axis tips.','Activa puntas de eje.'),('axis_config','table','{}','Shared NumberLine options.','Opciones NumberLine compartidas.'),('x_axis_config','table','{}','Horizontal axis overrides.','Cambios del eje horizontal.'),('y_axis_config','table','{}','Vertical axis overrides.','Cambios del eje vertical.')],
 'ParametricFunction':[('t_range','number[]','{0,1,0.01}','Parameter interval and sample step.','Intervalo del parámetro y paso.'),('use_smoothing','boolean','true','Fit cubic splines through samples.','Ajusta splines cúbicas a las muestras.'),('discontinuities','number[]','{}','Parameter values excluded by dt on both sides.','Valores excluidos con margen dt a ambos lados.'),('dt','number','1e-8','Positive discontinuity exclusion radius.','Radio positivo de exclusión.')]+STYLE,
 'Surface':SURFACE+STYLE,
 'Sphere':[('radius','number','1','Sphere radius.','Radio de esfera.'),('center','vector','ORIGIN','Sphere center.','Centro de esfera.')]+SURFACE+STYLE,
 'Cube':[('side_length','number','2','Length of each edge.','Longitud de cada arista.')]+STYLE,
 'Scene':CONFIG,'MovingCameraScene':CONFIG,'ThreeDScene':CONFIG,'Renderer':CONFIG,'Camera':CONFIG,'MovingCamera':CONFIG,
 'Scene:render':CONFIG+[('output','string','artifacts/scene.mp4','PNG, MP4, GIF or WebM path.','Ruta PNG, MP4, GIF o WebM.'),('keep_frames','boolean','false','Retain the generated numbered PNG directory.','Conserva la carpeta de PNG numerados.'),('last_frame','string','derived from output','Final logical-state PNG for encoded output.','PNG del estado lógico final para video codificado.')],
 'Scene:play':[('run_time','number','child durations','Override every supplied animation duration.','Sustituye la duración de cada animación.'),('rate_func','function','child easing','Override supplied animation rate functions.','Sustituye el suavizado de las animaciones.'),('lag_ratio','number','0','Stagger animations within this play call.','Desfasa las animaciones de esta llamada.')],
}
for key in ('Animation','Create','Uncreate','Write','Unwrite','DrawBorderThenFill','FadeIn','FadeOut','Transform','ReplacementTransform','Rotate','MoveAlongPath'):
 OPTIONS[key]=list(ANIMATION)
for key in ('Transform','ReplacementTransform'):OPTIONS[key]+=TRANSFORM
for key in ('Write','Unwrite'):
 OPTIONS[key]+=[('reverse','boolean','false for Write, true for Unwrite','Reverse member order during animation, restoring it on finish.','Invierte el orden de miembros durante la animación y lo restaura al terminar.')]
for key in ('FadeIn','FadeOut'):
 OPTIONS[key]+=[('shift','vector','ORIGIN','Translation of the transparent state.','Traslado del estado transparente.'),('scale','number','1','Scale of the transparent state.','Escala del estado transparente.'),('target_position','vector or Mobject','nil','Center used instead of shift.','Centro que sustituye a shift.')]
OPTIONS['Rotate']+= [('axis','vector','OUT','Rotation axis.','Eje de giro.'),('about_point','vector','starting center','Rotation pivot.','Pivote de giro.')]
for key in ('AnimationGroup','LaggedStart','Succession'):
 OPTIONS[key]=[('run_time','number','natural duration','Stretch the composition schedule to this duration.','Ajusta la programación a esta duración.'),('lag_ratio','number','0 / 0.05 / 1','Start-to-start child delay ratio for the respective factory.','Proporción de retraso entre inicios de cada función.'),('rate_func','function','linear','Easing of the whole composition timeline.','Suavizado de la línea temporal completa.')]
OPTIONS['ThreeDCamera']=CONFIG+[(key,'number',default,en,es) for key,default,en,es in [
 ('phi','0','Polar tilt in radians.','Inclinación polar en radianes.'),('theta','-PI/2','Azimuth in radians.','Azimut en radianes.'),('gamma','0','Roll in radians.','Giro en radianes.'),('zoom','1','Projection zoom.','Aumento de proyección.'),('focal_distance','20','Positive perspective distance.','Distancia positiva de perspectiva.')]]+[
 ('should_apply_shading','boolean','true','Enable lighting on shaded objects.','Activa iluminación en objetos sombreados.'),('exponential_projection','boolean','false','Use upstream exponential projection for nonnegative camera z.','Usa la proyección exponencial de upstream con z de cámara no negativa.'),('light_source_start_point','vector','{-7,-9,10}','World position of the point light.','Posición de la luz puntual en el mundo.')]
OPTIONS['ThreeDScene']=OPTIONS['ThreeDCamera']
OPTIONS['SVGMobject']=[('height','number or false','2','Fit height; false preserves source size.','Ajusta el alto; false conserva el tamaño original.'),('width','number','nil','Fit width after height.','Ajusta el ancho después del alto.'),('should_center','boolean','true','Center imported geometry.','Centra la geometría importada.'),('fill_color','color','SVG paint','Override imported fills.','Sustituye los rellenos importados.'),('fill_opacity','number','SVG opacity','Override imported fill alpha.','Sustituye su opacidad.'),('stroke_color','color','SVG paint','Override imported strokes.','Sustituye los bordes importados.'),('stroke_width','number','SVG width','Override stroke widths.','Sustituye grosores de borde.'),('stroke_opacity','number','SVG opacity','Override stroke alpha.','Sustituye la opacidad del borde.'),('svg_default','table','{}','Fallback SVG style keys; see the SVG guide.','Estilos SVG de reserva; consulta la guía SVG.')]

# Shape-specific defaults override the common Mobject row values.
DEFAULTS={
 'Circle':{'color':'RED'},'Ellipse':{'color':'RED'},'Polygon':{'color':'BLUE'},'RegularPolygon':{'color':'BLUE'},'Triangle':{'color':'BLUE'},
 'Dot':{'stroke_width':'0','fill_opacity':'1'},'Text':{'stroke_width':'0','fill_opacity':'1'},'MarkupText':{'stroke_width':'0','fill_opacity':'1'},
 'NumberLine':{'stroke_width':'2'},'FunctionGraph':{'color':'YELLOW'},'ThreeDVMobject':{'shade_in_3d':'true'},
 'Cube':{'fill_color':'BLUE','fill_opacity':'0.75','stroke_width':'0','joint_type':'bevel','shade_in_3d':'true'},
 'Surface':{'fill_color':'BLUE_D','fill_opacity':'1','stroke_color':'"#BBBBBB"','stroke_width':'0.5'},
 'Sphere':{'u_range':'{0,2*PI}','v_range':'{0,PI}','resolution':'{24,12}','fill_color':'BLUE_D','fill_opacity':'1','stroke_color':'"#BBBBBB"','stroke_width':'0.5'},
 'Create':{'lag_ratio':'1'},'Uncreate':{'lag_ratio':'1','reverse_rate_function':'true','remover':'true'},'FadeOut':{'remover':'true'},
 'Write':{'run_time':'1 or 2 by family size','rate_func':'linear','lag_ratio':'min(4/max(1,count),0.2)'},
 'Unwrite':{'run_time':'1 or 2 by family size','rate_func':'linear','lag_ratio':'min(4/max(1,count),0.2)','reverse_rate_function':'true','remover':'reverse'},
 'DrawBorderThenFill':{'run_time':'2','rate_func':'double_smooth'},
}
OPTIONS['Triangle']=OPTIONS['RegularPolygon']
OPTIONS['Triangle']=[row for row in OPTIONS['RegularPolygon'] if row[0]!='n']
OPTIONS['FunctionGraph']=list(OPTIONS['ParametricFunction'])
OPTIONS['FunctionGraph'][0]=('x_range','number[]','{-frame_width/2,frame_width/2,0.01}','x interval and step.','Intervalo x y paso.')

# Corrections deliberately describe the current implementation, not future parity.
API['Mobject:reverse_direction']=('Reverse this object’s stored curve order and cubic direction. Children are not reversed by this call.','Invierte el orden de curvas y el sentido cúbico de este objeto. Esta llamada no invierte los hijos.')
API['Mobject:start_new_path']=('Append a pending anchor for a disconnected subpath. An earlier pending anchor is completed as degenerate cubic geometry first.','Añade un ancla pendiente para un subtrazado desconectado. Un ancla pendiente anterior se completa antes como cúbica degenerada.')
API['Renderer:render']=('Clear, sort and draw the supplied families with camera projection. Optionally write PNG when path is supplied; return the renderer.','Limpia, ordena y dibuja las familias con la proyección de cámara. Escribe PNG si se indica path y devuelve el renderizador.')
for key in ('Surface','Sphere'):DEFAULTS[key]['shade_in_3d']='true'
for key in ('Text','MarkupText'):DEFAULTS[key]['stroke_color']='WHITE'
for short,kind,en,es in [
 ('t2c','color','Substring/range selector to color map.','Mapa de selectores de texto o intervalo a colores.'),
 ('t2f','string','Substring/range selector to font-family map.','Mapa de selectores a familias de fuente.'),
 ('t2s','string','Substring/range selector to slant map.','Mapa de selectores a inclinaciones.'),
 ('t2w','string','Substring/range selector to weight map.','Mapa de selectores a pesos.'),
 ('t2g','color[]','Substring/range selector to gradient palette map.','Mapa de selectores a paletas de degradado.'),
]:OPTIONS['Text'].append((short,f'table<string,{kind}>','{}',en,es))
NUMBER_LINE.extend([('tip_height','number','0.35','Triangle tip length.','Longitud de la punta triangular.'),('tip_width','number','0.35','Triangle base width.','Ancho de su base.')])
# OPTIONS copied NumberLine rows before the extra tip rows were appended.
OPTIONS['NumberLine']=NUMBER_LINE+STYLE
OPTIONS['FadeOut']=[row for row in OPTIONS['FadeOut'] if row[0]!='remover']
OPTIONS['VMobjectFromSVGPath']=STYLE

PIVOT=[('about_point','vector','object center','Explicit transformation pivot.','Pivote explícito de transformación.'),('about_edge','vector','ORIGIN','Boundary direction used when about_point is absent.','Dirección de borde si no se indica about_point.')]
for name in ('Mobject:scale','Mobject:stretch'):OPTIONS[name]=PIVOT
OPTIONS['Mobject:rotate']=PIVOT+[('axis','vector','OUT','Rotation axis.','Eje de giro.')]
OPTIONS['Mobject:apply_matrix']=[('about_point','vector','ORIGIN','Matrix transformation pivot.','Pivote de la transformación matricial.')]
OPTIONS['Mobject:move_to']=[('aligned_edge','vector','ORIGIN','Boundary to align with the target.','Borde que se alinea con el destino.'),('coor_mask','number[3]','{1,1,1}','Translation component mask.','Máscara de componentes del traslado.')]
OPTIONS['Mobject:next_to']=[('buff','number','0.25','Gap multiplied by direction.','Separación multiplicada por direction.'),('aligned_edge','vector','ORIGIN','Perpendicular alignment edge.','Borde de alineación perpendicular.')]
OPTIONS['Mobject:arrange']=OPTIONS['Mobject:next_to']+[('center','boolean','true','Center after arranging children.','Centra después de distribuir los hijos.')]
for name in ('Mobject:set_fill','Mobject:set_stroke','Mobject:set_color','Mobject:set_z_index'):
 OPTIONS[name]=[('family','boolean','true','Apply to descendants as well.','Aplica también a descendientes.')]
OPTIONS['Mobject:add_updater']=[('call_updater','boolean','false','Evaluate immediately at dt=0.','Evalúa inmediatamente con dt=0.')]
for name in ('Mobject:clear_updaters','Mobject:suspend_updating','Mobject:resume_updating','Mobject:update'):
 OPTIONS[name]=[('recursive','boolean','true','Include descendants.','Incluye descendientes.')]
OPTIONS['Mobject:align_data']=[('skip_point_alignment','boolean','false','Skip this object’s point alignment; child alignment still runs.','Omite la alineación de puntos propia; la de los hijos sigue ejecutándose.')]
OPTIONS['Mobject:add_tip']=[('tip_length','number','0.35','Positive length, shorter than the line.','Longitud positiva menor que la línea.'),('tip_width','number','0.35','Positive triangular base width.','Ancho positivo de base triangular.'),('stroke_width','number','0','Tip border width.','Grosor del borde de la punta.')]
