"""Pinned Manim circular arcs, endpoint placement, polygon rounding and SVG radii."""
import json
import tempfile
import warnings
from pathlib import Path
import manim as m
import numpy as np
from PIL import Image
from reference import ROOT,lua

assert m.__version__=='0.22.1'
def state(obj):return dict(points=obj.points,center=obj.get_center(),width=obj.width,height=obj.height)
arcs=[];polygons=[];placements=[];svgs=[]
for options in [{},{'angle':-.7},{'angle':np.pi},{'angle':0},{'angle':1e-5},
                {'angle':3.3,'num_components':4},{'radius':1.5},{'radius':-1.5},{'radius':1}]:
    for start,end in [([-1,0,0],[1,0,0]),([.3,-.2,1],[2,1,2])]:
        if options.get('radius')==1 and start[2]!=0:continue
        obj=m.ArcBetweenPoints(start,end,**options)
        center=obj.get_arc_center(warning=False)
        arcs.append(dict(start=start,finish=end,options=options,expected=state(obj),arc_center=center,stop_angle=obj.stop_angle(),
                         center_issue=options.get('angle')==0 and np.linalg.norm(center)>1e12))
vertices=[[[1,1,0],[-1,1,0],[-1,-1,0],[1,-1,0]],
          [[0,1,0],[-1,-1,0],[1,-1,0]],
          [[-2,-1,0],[0,-1,0],[0,0,0],[2,0,0],[2,1,0],[-2,1,0]],
          [[-1,0,0],[1,0,0],[0,0,0]]]
for index,v in enumerate(vertices):
    for radius in [0,.2,-.2,10]:
        for options in [{},{'evenly_distribute_anchors':True},{'components_per_rounded_corner':3,'evenly_distribute_anchors':True}]:
            obj=m.Polygon(*v);obj.round_corners(radius=radius,**options)
            record=dict(groups=[v],radius=radius,options=options,expected=state(obj),vertices=obj.get_vertices(),vertex_groups=obj.get_vertex_groups())
            if radius==10 and options.get('evenly_distribute_anchors') and index in [0,1,2]:
                curves=obj.points.reshape((-1,4,3))
                kept=[curve for curve in curves if np.max(np.linalg.norm(curve-curve[0],axis=1))>1e-12]
                canonical=obj.copy().set_points(np.concatenate(kept))
                record['degenerate_subdivision_issue']=dict(expected=state(canonical),vertices=canonical.get_vertices(),vertex_groups=canonical.get_vertex_groups())
            polygons.append(record)
for radii in [[.1,.3],[0,.2,0,.1]]:
    obj=m.Polygon(*vertices[0]).round_corners(radii)
    polygons.append(dict(groups=[vertices[0]],radius=radii,options={},expected=state(obj),vertices=obj.get_vertices(),vertex_groups=obj.get_vertex_groups()))
obj=m.Polygram(vertices[1],[[x+3,y,z] for x,y,z in vertices[1]]).round_corners(.15)
polygons.append(dict(groups=[vertices[1],[[x+3,y,z] for x,y,z in vertices[1]]],radius=.15,options={},expected=state(obj),vertices=obj.get_vertices(),vertex_groups=obj.get_vertex_groups()))
for start,end in [([0,0,0],[2,1,0]),([1,2,3],[2,-1,4]),([1,0,0],[-1,0,0]),([1,2,0],[1,2,0])]:
    for kind in ['Line','Circle']:
        obj=getattr(m,kind)();obj.put_start_and_end_on(start,end)
        record=dict(kind=kind,start=start,finish=end,expected=state(obj))
        if kind=='Circle':record['closed_loop_issue']=state(m.Circle().shift(np.array(start)-m.RIGHT))
        placements.append(record)
out=ROOT/'tests/reference_rounding_images';out.mkdir(exist_ok=True)
svg_texts=[f'<rect x="1" y="2" width="10" height="6" {attrs} fill="#58c4dd" stroke="#f7d96f" stroke-width=".2"/>'
           for attrs in ['rx="1"','ry="2"','rx="2" ry="1"','rx="20"','rx="2" ry="0"','rx="0" ry="2"']]
svg_texts+=['<g transform="translate(3,4) rotate(25) scale(1.2,.7)"><rect width="10" height="6" rx="1.5" fill="red"/></g>']
with m.tempconfig(dict(pixel_width=480,pixel_height=270,frame_height=8,frame_width=128/9,verbosity='ERROR')):
    with tempfile.TemporaryDirectory() as tmp:
        for i,text in enumerate(svg_texts,1):
            code='<svg xmlns="http://www.w3.org/2000/svg">'+text+'</svg>'
            file=Path(tmp)/f'round-{i}.svg';file.write_text(code)
            obj=m.SVGMobject(file)
            svgs.append(dict(code=code,expected=[state(s) for s in obj.submobjects]))
            camera=m.Camera();camera.capture_mobjects([obj]);Image.fromarray(camera.pixel_array).save(out/f'svg_{i}.png')
    for i,radius in enumerate([.2,-.2,2],1):
        obj=m.RoundedRectangle(width=4,height=2,corner_radius=radius,color=m.BLUE,fill_opacity=.3)
        camera=m.Camera();camera.capture_mobjects([obj]);Image.fromarray(camera.pixel_array).save(out/f'rounded_{i}.png')
    obj=m.ArcBetweenPoints([-2,-1,0],[2,1,0],angle=2,color=m.YELLOW)
    camera=m.Camera();camera.capture_mobjects([obj]);Image.fromarray(camera.pixel_array).save(out/'arc.png')
(ROOT/'tests/reference_rounding.lua').write_text('-- Actual Manim 0.22.1 rounded geometry.\nreturn '+lua(dict(arcs=arcs,polygons=polygons,placements=placements,svgs=svgs))+'\n')
print(f'Generated {len(arcs)} arcs, {len(polygons)} rounded polygons, {len(placements)} placements, {len(svgs)} SVGs and 11 images')
