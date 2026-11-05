"""Actual upstream path-building and family/subpath transformation oracle."""
import manim as m
import numpy as np
from PIL import Image
from reference import lua,ROOT

assert m.__version__=='0.22.1'
def make(spec):
    kind=spec['kind'];opts=spec.get('options',{})
    if kind=='VGroup':obj=m.VGroup(*(make(s) for s in spec.get('children',[])))
    elif kind=='VMobject':
        obj=m.VMobject(**opts)
        for command in spec.get('commands',[]):
            args=[np.asarray(v,dtype=float) if isinstance(v,list) else v for v in command[1:]]
            getattr(obj,command[0])(*args)
    elif kind=='VectorizedPoint':obj=m.VectorizedPoint(spec.get('location',[0,0,0]),**opts)
    else:obj=getattr(m,kind)(**opts)
    if 'shift' in spec:obj.shift(spec['shift'])
    return obj
def state(obj):
    return dict(points=[c.points for c in obj.get_family()],
                fill=[c.get_fill_opacity() for c in obj.get_family()],
                stroke=[c.get_stroke_opacity() for c in obj.get_family()],
                widths=[c.get_stroke_width() for c in obj.get_family()])
paths=[
    [['start_new_path',[0,0,0]]],
    [['start_new_path',[0,0,0]],['add_line_to',[1,2,0]]],
    [['start_new_path',[0,0,0]],['start_new_path',[2,0,0]],['add_line_to',[3,1,0]]],
    [['start_new_path',[0,0,0]],['add_cubic_bezier_curve_to',[1,2,0],[2,-1,0],[3,0,0]]],
    [['start_new_path',[0,0,0]],['add_quadratic_bezier_curve_to',[1,2,0],[3,0,0]]],
    [['start_new_path',[0,0,0]],['add_points_as_corners',[[1,0,0],[1,1,0],[0,1,0]]],['close_path']],
    [['start_new_path',[0,0,0]],['add_line_to',[1,0,0]],['start_new_path',[2,0,0]]],
    [['start_new_path',[0,0,0]],['add_line_to',[1,0,0]],['start_new_path',[2,0,0]],['add_line_to',[3,1,0]]],
]
builders=[]
for commands in paths:
    obj=make(dict(kind='VMobject',commands=commands))
    builders.append(dict(commands=commands,points=obj.points,pending=obj.has_new_path_started(),curves=obj.get_num_curves(),
                         subpaths=obj.get_subpaths()))
circle={'kind':'Circle','shift':[-1,0,0]};square={'kind':'Square','shift':[1,0,0]}
triangle={'kind':'Triangle','shift':[0,1,0]}
group1={'kind':'VGroup','children':[circle]};group2={'kind':'VGroup','children':[square,triangle]}
nested={'kind':'VGroup','children':[group1,group2]}
empty={'kind':'VGroup'};emptyvm={'kind':'VMobject'}
compound={'kind':'VMobject','commands':paths[-1]}
threepaths={'kind':'VMobject','commands':paths[-1]+[['start_new_path',[-1,2,0]],['add_line_to',[-2,3,0]]]}
pairs=[(circle,square),(circle,group2),(group2,circle),(empty,group2),(emptyvm,circle),
       (group1,group2),(group2,group1),(nested,group2),(compound,square),(compound,threepaths),
       ({'kind':'VectorizedPoint','location':[1,1,0]},circle),
       ({'kind':'VMobject','commands':paths[-2]},circle)]
cases=[]
images=ROOT/'tests/reference_alignment_images';images.mkdir(exist_ok=True)
for index,(a,b) in enumerate(pairs):
    for alpha in [0,.125,.25,.5,.75,1]:
        obj,target=make(a),make(b)
        animation=m.Transform(obj,target,rate_func=m.linear);animation.begin();animation.interpolate(alpha)
        case=dict(source=a,target=b,alpha=alpha,expected=state(obj))
        if index in [1,3,7,8,9]:
            image=f'align_{index:02}_{alpha:.3f}.png';case['image']=image
            with m.tempconfig(dict(pixel_width=320,pixel_height=180,frame_height=8,frame_width=128/9)):
                camera=m.Camera();camera.capture_mobjects([obj]);Image.fromarray(camera.pixel_array).save(images/image)
        cases.append(case)
(ROOT/'tests/reference_alignment.lua').write_text('-- Real Manim 0.22.1 path and family oracle.\nreturn '+lua(dict(builders=builders,cases=cases))+'\n')
print(f'Generated {len(builders)} path-builder states and {len(cases)} family/subpath Transform states')
