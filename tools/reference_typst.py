"""Pinned upstream Typst geometry, label captures and affine baseline frames."""
import importlib.metadata
import json
import manim as m
from PIL import Image
from reference import ROOT,lua

assert m.__version__=='0.22.1'
assert importlib.metadata.version('typst')=='0.15.2'
specs=[
 ('Typst','*Hello* from _Typst!_',{},[]),
 ('Typst','Hello',{'font_size':72},[]),
 ('Typst','#text(fill: blue)[Blue] and black',{'color':m.RED},[]),
 ('Typst','#box[a] <left> + #box[b] <right>',{},['left','right']),
 ('Typst','#let pick(body) = [#box(body) <picked>]\n#pick[a] #pick[b]',{},['picked']),
 ('MathTypst','a^2 + b^2 = c^2',{},[]),
 ('MathTypst','frac(1,x+1)',{},[]),
 ('MathTypst','sum_(k=1)^n k = frac(n(n+1),2)',{},[]),
 ('MathTypst','integral_0^1 x^2 dif x = 1/3',{},[]),
 ('MathTypst','sqrt(x^2+y^2)',{},[]),
 ('MathTypst','mat(1,2;3,4)',{},[]),
 ('MathTypst','{{ a^2+b^2 : lhs }} = {{ c^2 }}',{},['lhs',0]),
 ('MathTypst','{{ a + {{ b }} : outer }}',{},['outer',0]),
 ('MathTypst','{{ a : same }} + {{ b : same }}',{},['same']),
 ('MathTypst','{{ #hide[$x$] : hidden }} + y',{},['hidden']),
 ('MathTypst','frac(a,b)',{'height':1.5},[]),
 ('MathTypst','frac(a,b)',{'width':3},[]),
 ('MathTypst','frac(a,b)',{'stroke_width':2},[]),
 ('MathTypst','a+b',{'should_center':False},[]),
 ('MathTypst','a+b',{'color':m.BLUE,'font_size':64},[]),
 ('MathTypst','frac(a,b)',{'typst_preamble':'#set text(fill: red)'},[]),
 ('MathTypst','',{},[]),
]
cases=[];parsers=[];out=ROOT/'tests/reference_typst_images';out.mkdir(exist_ok=True)
diagnostics=ROOT/'tests/reference_typst_diagnostic_images';diagnostics.mkdir(exist_ok=True)
def state(obj):
    return dict(points=[s.points for s in obj.submobjects],fills=[s.get_fill_color().to_rgb() for s in obj.submobjects],
        fill_opacity=[s.get_fill_opacity() for s in obj.submobjects],strokes=[s.get_stroke_color().to_rgb() for s in obj.submobjects],
        stroke_opacity=[s.get_stroke_opacity() for s in obj.submobjects],widths=[s.get_stroke_width() for s in obj.submobjects],
        baselines=obj.baseline_frames,font_size=obj.font_size if obj.height else 0)
parser_inputs=['{{ a^2+b^2 : lhs }} = {{ c^2 }}','{{ a + {{ b }} : outer }}',
               'text("{{literal}}") + [{{kept}}] + {{ x }}','{{unclosed','plain',
               '{{ {{a}} + {{b}} }}','{{ x : with-dash }}','{{ x : λ }}',
               '"escaped \\" {{ literal }}" + {{y}}','{{ [{{ literal }}] : block }}']
for text in parser_inputs:
    processed,labels=m.MathTypst._preprocess_groups(text)
    parsers.append(dict(input=text,processed=processed,labels=labels))
with m.tempconfig(dict(pixel_width=480,pixel_height=270,frame_height=8,frame_width=128/9,
                       media_dir=str(ROOT/'artifacts/oracle-typst'),verbosity='ERROR')):
    for index,(kind,text,extra,selections) in enumerate(specs,1):
        options={'track_baselines':True,**extra}
        obj=getattr(m,kind)(text,**options)
        uncached=getattr(m,kind)(text,**options,use_svg_cache=False)
        cache_difference=len(obj.baseline_frames)!=len(uncached.baseline_frames)
        selection=[]
        for key in selections:
            chosen=obj.select(key)
            indices=[next(i+1 for i,leaf in enumerate(obj.submobjects) if leaf is s) for s in chosen]
            selection.append(dict(key=key+1 if isinstance(key,int) else key,indices=indices))
        for pose in [0,1]:
            current=obj.copy()
            if pose:current.rotate(.23).scale(1.2).shift(m.RIGHT*.3)
            image=f'typst_{index:02}_{pose}.png'
            record=dict(kind=kind,text=text,options={k:v.to_hex() if isinstance(v,m.ManimColor) else v for k,v in options.items()},pose=pose,image=image,selections=selection,**state(current))
            cases.append(record)
            camera=m.Camera();camera.capture_mobjects([current]);Image.fromarray(camera.pixel_array).save(out/image)
            if cache_difference:
                corrected=uncached.copy()
                if pose:corrected.rotate(.23).scale(1.2).shift(m.RIGHT*.3)
                record['known_difference']='Upstream SVG cache hits omit Typst baseline/stroke tracking lists. Lua preserves tracking; the diagnostic changes only use_svg_cache=False.'
                record['diagnostic']=dict(image=image,**state(corrected))
                camera=m.Camera();camera.capture_mobjects([corrected]);Image.fromarray(camera.pixel_array).save(diagnostics/image)
(ROOT/'tests/reference_typst.lua').write_text('-- Real Manim 0.22.1 / Typst 0.15.1 engine.\nreturn '+lua(dict(cases=cases,parsers=parsers))+'\n')
(ROOT/'tests/reference_typst_cases.json').write_text(json.dumps([dict(image=c['image'],diagnostic='diagnostic' in c) for c in cases],indent=2)+'\n')
print(f'Generated {len(cases)} Typst/MathTypst states/images, {len(parsers)} parser cases; {sum("diagnostic" in c for c in cases)} diagnosed cache states')
