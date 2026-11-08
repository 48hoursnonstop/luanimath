"""Real Pango markup states, styles and images from pinned Manim."""
import manim as m
from PIL import Image
from reference import ROOT,lua

assert m.__version__=='0.22.1'
specs=[('<b>Lua</b> <i>nativo</i>',{}),
 ('<span foreground="red">Red <span foreground="#58c4dd">blue</span></span>',{}),
 ('<span size="x-large">Big</span> small',{}),
 ('<u>under</u> <s>strike</s>',{}),
 ('<span background="blue" foreground="yellow">Box</span>',{}),
 ('x<sup>2</sup> + y<sub>0</sub>',{}),
 ('Line <b>one</b>\nLine <i>two</i>',{}),
 ('Line one\nLine two',{'line_spacing':.6}),
 ('Justified words '*12,{'justify':True}),
 ('مرحبا',{'font':'Noto Sans Arabic'}),
 ('office fi fl',{'font':'Noto Sans','disable_ligatures':True}),
 ('<b>Blue</b> <span foreground="red">Red</span>',{'color':m.BLUE}),
 ('A &amp; B &lt; C &gt; D',{}),
 ('Raw <i>position</i>',{'should_center':False}),
 ('Sized <b>text</b>',{'height':1.5,'width':3}),
 ('',{}),('A\tB',{'tab_width':2}),
 ('<span font_family="Noto Sans CJK JP">日本語</span>',{}),
 ('<span rise="4000" letter_spacing="1000">Raised</span>',{}),
 ('<span foreground="red" alpha="50%">Alpha</span>',{}),
 ('Gradient <b>style</b>',{'gradient':[m.RED,m.BLUE]})]
cases=[];out=ROOT/'tests/reference_markup_images';out.mkdir(exist_ok=True)
with m.tempconfig(dict(pixel_width=480,pixel_height=270,frame_height=8,frame_width=128/9,
                       media_dir=str(ROOT/'artifacts/oracle-markup'),verbosity='ERROR')):
    for i,(text,extra) in enumerate(specs,1):
        options={'font':'Liberation Sans','font_size':48,**extra}
        obj=m.MarkupText(text,**options)
        encoded={k:v.to_hex() if isinstance(v,m.ManimColor) else [c.to_hex() for c in v] if isinstance(v,list) else v for k,v in options.items()}
        image=f'markup_{i:02}.png'
        cases.append(dict(text=text,options=encoded,image=image,
            points=[g.points for g in obj],fills=[g.get_fill_color().to_rgb() for g in obj],
            fill_opacity=[g.get_fill_opacity() for g in obj],strokes=[g.get_stroke_color().to_rgb() for g in obj],
            stroke_opacity=[g.get_stroke_opacity() for g in obj],widths=[g.get_stroke_width() for g in obj]))
        if obj.height>0:cases[-1]['font_size']=obj.font_size
        if i in (1,15,21):
            resized=obj.copy().scale(1.25);before=resized.font_size;resized.font_size=72
            cases[-1]['resize']=dict(before=before,after=resized.font_size,points=[g.points for g in resized])
        camera=m.Camera();camera.capture_mobjects([obj]);Image.fromarray(camera.pixel_array).save(out/image)
(ROOT/'tests/reference_markup.lua').write_text('-- Pinned Manim MarkupText states.\nreturn '+lua(cases)+'\n')
print(f'Generated {len(cases)} markup cases and images')
