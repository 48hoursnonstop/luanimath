import math
import random
import manim as m
import svgelements as se
from PIL import Image
from reference import lua,ROOT

assert m.__version__=='0.22.1'
paths=['M0 0 L3 1 2 4z','m1 2h3v4h-3z','M0 0C1 2 3 -1 4 0 S7 2 8 0',
       'M0 0 Q1 3 3 0 T6 0','M1e-2-.5L2.5.3','M0 0L1 0ZM2 2l1 1',
       'M0 0A3 2 30 0 1 5 2','M0 0a3 2 30 1 0 5 2','M0 0A0 2 0 0 1 3 1',
       'M1 1A1 1 0 1 1 1 1','M0 0A5 5 0 0110 0',
       'M0 0A0 2 0 0 1 3 1L4 5','M0 0A0 2 0 0 1 3 1C4 2 5 2 6 1']
random.seed(2216)
for _ in range(60):
    x,y=[random.uniform(-3,3) for _ in range(2)]
    endx,endy=[random.uniform(-3,3) for _ in range(2)]
    rx,ry=[random.uniform(.1,4) for _ in range(2)]
    paths.append(f'M{x} {y}A{rx} {ry} {random.uniform(-180,180)} {random.randrange(2)} {random.randrange(2)} {endx} {endy}')
path_cases=[]
for data in paths:
    obj=m.VMobjectFromSVGPath(se.Path(data))
    path_cases.append(dict(data=data,points=obj.points))
assets=ROOT/'tests/svg_assets';assets.mkdir(exist_ok=True)
contents={
 'path':'<path d="M0 0 C10 20 20 -10 30 0 L30 20H0Z" fill="#58c4dd"/>',
 'shapes':'<rect x="1" y="2" width="12" height="8" fill="red"/><circle cx="24" cy="8" r="5" fill="blue"/><ellipse cx="10" cy="22" rx="7" ry="3" fill="green"/>',
 'lines':'<polyline points="0,0 10,5 20,0" fill="none" stroke="blue" stroke-width="2"/><polygon points="0,10 10,20 20,10" fill="gold"/><line x1="25" y1="0" x2="25" y2="20" stroke="red" stroke-width="1"/>',
 'transform':'<g transform="translate(3 4) rotate(20) scale(1.2 .8)"><path d="M0 0Q10 15 20 0T40 0" fill="none" stroke="#58c4dd" stroke-width="2"/></g>',
 'use':'<defs><path id="glyph" d="M0 0L5 0 5 8 0 8Z"/></defs><g id="letters" fill="purple"><use href="#glyph"/><use href="#glyph" x="10" y="3" transform="rotate(10)"/></g>',
 'inline':'<g fill="red" fill-opacity=".5"><rect width="10" height="10"/><rect x="15" width="10" height="10" style="fill:blue;fill-opacity:0.8"/></g>',
 'arcs':'<path d="M0 0 A10 5 30 0 1 20 0 A10 5 -30 1 0 30 15" fill="none" stroke="orange" stroke-width="2"/>',
 'paints':'<g opacity=".3"><rect width="10" height="8" fill="rgba(255,0,0,.5)"/><rect x="15" width="10" height="8" fill="rgb(20%,50%,80%)" fill-opacity=".3"/><path d="M0 15L25 15" stroke="#ABC8" stroke-opacity=".7" stroke-width="2"/></g>',
 'non_scaling':'<g transform="matrix(2 .3 .2 1.4 4 5)"><path d="M0 0L10 0L5 10Z" fill="none" stroke="teal" stroke-width="2" vector-effect="non-scaling-stroke"/></g>',
 'skew':'<g transform="skewX(15),skewY(-10) translate(2)"><rect width="10px" height="8px" fill="#ac4"/></g>',
 'visibility':'<g style="display:none"><rect width="10" height="10"/></g><rect x="15" width="10" height="10" fill="cornflowerblue"/>',
 'root_style':'<rect width="10" height="8"/><path d="M15 0L25 8" fill="none" stroke="blue"/>',
}
cases=[];images=ROOT/'tests/reference_svg_images';images.mkdir(exist_ok=True)
for name,content in contents.items():
    root_style=' viewBox="0 0 100 50" transform="scale(3)" style="fill:red;fill-opacity:.4;stroke-width:2"' if name=='root_style' else ''
    (assets/(name+'.svg')).write_text('<svg xmlns="http://www.w3.org/2000/svg"'+root_style+'>'+content+'</svg>')
    for options in [{},{'height':None,'should_center':False}]:
        obj=m.SVGMobject(assets/(name+'.svg'),**options)
        family=obj.submobjects
        cases.append(dict(file=name+'.svg',options={k:False if v is None else v for k,v in options.items()},
            points=[s.points for s in family],fills=[s.get_fill_color().to_rgb() for s in family],
            fill_opacity=[s.get_fill_opacity() for s in family],strokes=[s.get_stroke_color().to_rgb() for s in family],
            stroke_opacity=[s.get_stroke_opacity() for s in family],widths=[s.get_stroke_width() for s in family]))
    with m.tempconfig(dict(pixel_width=400,pixel_height=300,frame_width=32/3,frame_height=8)):
        camera=m.Camera();camera.capture_mobjects([m.SVGMobject(assets/(name+'.svg'))])
        Image.fromarray(camera.pixel_array).save(images/(name+'.png'))
(ROOT/'tests/reference_svg.lua').write_text('-- Real Manim 0.22.1 SVG geometry and style.\nreturn '+lua(dict(paths=path_cases,objects=cases))+'\n')
print(f'Generated {len(path_cases)} path and {len(cases)} SVG object cases; {len(contents)} reference frames')
