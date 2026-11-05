"""Pinned Manim camera, 3D surface geometry, shading and real rendered references."""
import math
import manim as m
import numpy as np
from PIL import Image
from reference import lua,ROOT

assert m.__version__=='0.22.1'
points=np.array([[0.,0.,0.],[1,2,3],[-2,.3,-1],[1,0,22]])
projections=[]
for phi in [0,.4,1.1]:
    for theta in [-math.pi/2,-.7,.4]:
        for exponential in [False,True]:
            opts=dict(phi=phi,theta=theta,gamma=.2,zoom=1.3,focal_distance=20,
                      frame_center=[.2,-.3,.1],exponential_projection=exponential)
            camera=m.ThreeDCamera(**opts)
            projections.append(dict(options=opts,points=points,projected=camera.project_points(points),rotation=camera.get_rotation_matrix()))
def build(kind,opts):
    if kind=='Surface':return m.Surface(lambda u,v:np.array([u,v,.3*np.sin(u)*np.cos(v)]),**opts)
    return getattr(m,kind)(**opts)
def state(obj):
    return dict(points=[c.points for c in obj.get_family()],fill=[c.get_fill_color().to_rgba_with_alpha(c.get_fill_opacity()) for c in obj.get_family()],
                stroke=[c.get_stroke_color().to_rgba_with_alpha(c.get_stroke_opacity()) for c in obj.get_family()],
                widths=[c.get_stroke_width() for c in obj.get_family()])
objects=[]
for kind,opts in [('Cube',{}),('Cube',{'side_length':1.3,'fill_opacity':.4}),
                  ('Sphere',{'resolution':[6,4]}),('Sphere',{'resolution':[8,6],'radius':1.4,'center':[1,-.5,.2]}),
                  ('Surface',{'u_range':[-2,2],'v_range':[-1,1],'resolution':[4,3]}),
                  ('Surface',{'u_range':[-2,2],'v_range':[-1,1],'resolution':[4,3],'should_make_jagged':True,'checkerboard_colors':False})]:
    objects.append(dict(kind=kind,options=opts,expected=state(build(kind,opts))))
images=[];output=ROOT/'tests/reference_three_d_images';output.mkdir(exist_ok=True)
with m.tempconfig(dict(pixel_width=400,pixel_height=300,frame_height=8,frame_width=32/3)):
    for kind in ['Cube','Sphere','Surface']:
        for shading in [False,True]:
            opts={'resolution':[12,8]} if kind=='Sphere' else {'resolution':[12,8],'u_range':[-2,2],'v_range':[-2,2]} if kind=='Surface' else {}
            obj=build(kind,opts)
            camera_opts=dict(phi=1.1,theta=-.7,gamma=.1,should_apply_shading=shading)
            camera=m.ThreeDCamera(**camera_opts);camera.capture_mobjects([obj])
            name=f'{kind}_{shading}.png';Image.fromarray(camera.pixel_array).save(output/name)
            images.append(dict(kind=kind,options=opts,camera=camera_opts,image=name))
    camera=m.MovingCamera();camera.frame.scale(.6).shift(m.RIGHT)
    square=m.Square(color=m.BLUE,fill_opacity=.4);circle=m.Circle(color=m.GREEN).shift(2*m.RIGHT)
    camera.capture_mobjects([square,circle]);Image.fromarray(camera.pixel_array).save(output/'moving.png')
(ROOT/'tests/reference_three_d.lua').write_text('-- Real Manim 0.22.1 3D and camera oracle.\nreturn '+lua(dict(projections=projections,objects=objects,images=images))+'\n')
print(f'Generated {len(projections)} camera, {len(objects)} object, {len(images)+1} rendered reference cases')
