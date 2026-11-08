"""Glyph geometry and real per-letter Write frames from pinned Manim."""
import manim as m
from PIL import Image
from reference import ROOT,lua

assert m.__version__=='0.22.1'
specs=[('Lua',{}),('mañana',{}),('office fi fl',{}),('office fi fl',{'disable_ligatures':True}),
       (' A B ',{'disable_ligatures':True}),('A\tB',{'disable_ligatures':True}),
       ('Lua\nManim',{}),('Lua\nManim',{'line_spacing':.6}),('Lua',{'should_center':False}),
       ('Lua',{'height':1.5}),('Lua',{'width':3}),('Lua',{'font_size':72,'slant':'ITALIC'}),
       ('日本語',{'font':'Noto Sans CJK JP'}),('Lua مرحبا',{'font':'Noto Sans Arabic'}),
       ('e\u0301 ü',{}),('White',{ 'color':m.BLUE,'fill_opacity':.6,'stroke_width':2}),('',{}),
       ('office fi fl',{'font':'Noto Sans'}),('office fi fl',{'font':'Noto Sans','disable_ligatures':True})]
cases=[];states=[];resizes=[];out=ROOT/'tests/reference_glyph_images';out.mkdir(exist_ok=True)
def state(obj):
    return dict(points=[g.points for g in obj],fills=[g.get_fill_color().to_rgb() for g in obj],
                fill_opacity=[g.get_fill_opacity() for g in obj],strokes=[g.get_stroke_color().to_rgb() for g in obj],
                stroke_opacity=[g.get_stroke_opacity() for g in obj],widths=[g.get_stroke_width() for g in obj])
with m.tempconfig(dict(pixel_width=480,pixel_height=270,frame_height=8,frame_width=128/9,
                       media_dir=str(ROOT/'artifacts/oracle-glyphs'),verbosity='ERROR')):
    for text,extra in specs:
        options={'font':'Liberation Sans','font_size':48,**extra}
        obj=m.Text(text,**options)
        encoded={k:v.to_hex() if isinstance(v,m.ManimColor) else v for k,v in options.items()}
        cases.append(dict(text=text,options=encoded,**state(obj)))
    animations=[('plain','Lua',{},'Write',{}),('ligatures','office fi',{'font':'Noto Sans'},'Write',{}),
                ('spaces','A B',{'disable_ligatures':True},'Write',{}),
                ('reverse','Lua',{},'Write',{'reverse':True,'remover':False}),
                ('unwrite','Lua',{},'Unwrite',{}),('unwrite_forward','Lua',{},'Unwrite',{'reverse':False}),
                ('long','abcdefghijklmnopqrstuvwx',{},'Write',{})]
    for name,text,extra,kind,animation_options in animations:
        options={'font':'Liberation Sans',**extra}
        obj=m.Text(text,**options)
        animation=getattr(m,kind)(obj,**animation_options);animation.begin()
        for alpha in [0,.125,.25,.5,.75,1]:
            animation.interpolate(alpha)
            image=f'{name}_{int(alpha*1000):04}.png'
            camera=m.Camera();camera.capture_mobjects([obj]);Image.fromarray(camera.pixel_array).save(out/image)
            states.append(dict(text=text,options=options,alpha=alpha,kind=kind,
                               animation_options=animation_options,image=image,run_time=animation.run_time,
                               remover=animation.remover,lag_ratio=animation.lag_ratio,**state(obj)))
        animation.finish()
    for options in [{},{'height':1.5},{'width':3}]:
        obj=m.Text('Size',font='Liberation Sans',font_size=32,**options)
        obj.scale(1.25);before=obj.font_size;obj.font_size=72
        resizes.append(dict(options=options,before=before,after=obj.font_size,**state(obj)))
(ROOT/'tests/reference_glyphs.lua').write_text('-- Pinned Manim glyph and Write states.\nreturn '+lua(dict(cases=cases,states=states,resizes=resizes))+'\n')
print(f'Generated {len(cases)} glyph cases and {len(states)} Write states/images')
