"""Generate real upstream text images/metrics; requires installed matching fonts."""
import json
import manim as m
import manimpango
from PIL import Image
from reference import lua, ROOT

assert m.__version__=='0.22.1'
cases=[]
specs=[('Lua',{}),('mañana',{}),('office fi fl',{}),('日本語',{'font':'Noto Sans CJK JP'}),
       ('مرحبا',{'font':'Noto Sans Arabic'}),('Lua\nManim',{}),('A\tB',{}),('',{}),
       ('Native',{'font_size':24}),('Native',{'font_size':72}),
       ('Bold',{'weight':'BOLD'}),('Italic',{'slant':'ITALIC'}),
       ('office',{'disable_ligatures':True}),('Lua مرحبا',{'font':'Noto Sans Arabic'})]
output=ROOT/'tests/reference_text_images';output.mkdir(exist_ok=True)
with m.tempconfig(dict(pixel_width=480,pixel_height=270,frame_height=8,frame_width=128/9,
                       media_dir=str(ROOT/'artifacts/oracle-text'),verbosity='ERROR')):
    for i,(text,extra) in enumerate(specs,1):
        opts={'font':'Liberation Sans','font_size':48,**extra}
        obj=m.Text(text,**opts)
        case=dict(text=text,options=opts,width=obj.width,height=obj.height,center=obj.get_center(),image=f'text_{i:02}.png')
        cases.append(case)
        camera=m.Camera();camera.capture_mobjects([obj]);Image.fromarray(camera.pixel_array).save(output/f'text_{i:02}.png')
        if text=='مرحبا':
            assert obj.width==0 and obj.height==0,'re-audit known upstream RTL clipping if behavior changes'
            original=manimpango.text2svg
            def width_diagnostic(*args,**kwargs):
                kwargs['pango_width']=100
                return original(*args,**kwargs)
            try:
                manimpango.text2svg=width_diagnostic
                with m.tempconfig({'media_dir':str(ROOT/'artifacts/oracle-rtl-diagnostic')}):
                    corrected=m.Text(text,**opts)
                assert corrected.width>0 and corrected.height>0
                case['known_difference']='Manim text2svg uses canvas-wide automatic RTL layout, clipping this word outside its SVG. Luanim retains the real glyph outlines.'
                case['diagnostic']=dict(width=corrected.width,height=corrected.height,center=corrected.get_center(),image='rtl_layout_diagnostic.png')
                camera=m.Camera();camera.capture_mobjects([corrected]);Image.fromarray(camera.pixel_array).save(output/'rtl_layout_diagnostic.png')
            finally:
                manimpango.text2svg=original
(ROOT/'tests/reference_text.lua').write_text('-- Real Manim 0.22.1, Pango-shaped outlines.\nreturn '+lua(cases)+'\n')
(ROOT/'tests/reference_text_cases.json').write_text(json.dumps(cases,default=lambda x:x.tolist(),ensure_ascii=False,indent=2)+'\n')
print(f'Generated {len(cases)} upstream text metric/image cases')
