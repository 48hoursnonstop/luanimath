Escenas tridimensionales
================================================================================

Usa ``ThreeDScene`` para obtener una cámara en perspectiva. Sus ángulos están
en radianes; multiplica grados por ``DEGREES`` cuando sea más cómodo. ``phi``
controla la inclinación polar, ``theta`` el azimut y ``gamma`` el giro.

.. luanimath-example:: three_d
   :alt: Un cubo azul y una esfera ajedrezada vistos por una cámara en perspectiva que se mueve.
   :video:

``move_camera`` anima orientación, aumento, distancia focal o centro de encuadre.
``add_fixed_in_frame_mobjects`` añade elementos fijos en coordenadas de cámara.
Para cámara móvil 2D, usa ``MovingCameraScene`` y anima ``camera.frame``.

Superficies
--------------------------------------------------------------------------------

``Surface(fn,opts)`` transforma una cuadrícula mediante ``fn(u,v)``. Cada resultado
es un punto 2D/3D finito. La resolución controla las caras, no los píxeles.
Las caras curvas usan la construcción cúbica por diferencia finita de upstream.
``should_make_jagged`` genera bordes rectos. ``Sphere`` aporta una parametrización
esférica y ``Cube`` construye seis caras vectoriales.

Cairo ordena caras por profundidad y aplica degradados de iluminación por cara.
Es el backend vectorial implementado. Siguen pendientes OpenGL, texturas, recorte
completo y otras familias 3D. Se rechaza un punto exactamente en el plano focal.
Los metadatos ``u_index``/``v_index`` conservan índices desde cero de upstream;
las secuencias Lua siguen empezando desde 1.
