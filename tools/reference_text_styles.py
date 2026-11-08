import manim as m
import random
from PIL import Image
from reference import ROOT,lua

assert m.__version__=='0.22.1'
specs=[('Lua Lua',{'t2c':{'Lua':m.BLUE}}),('ababa',{'t2c':{'aba':m.RED}}),
       ('mañana café',{'t2c':{'café':m.GREEN}}),
       ('abcde',{'t2c':{'abc':m.RED},'t2w':{'bcd':'BOLD'}}),
       ('ababa',{'t2c':{'aba':m.RED},'t2w':{'ba':'BOLD'}}),
       ('Range selector',{'t2c':{'[0:5]':m.YELLOW}}),('Range selector',{'t2s':{'[-8:]':'ITALIC'}}),
       ('Whole',{'t2c':{'[:]':m.PURPLE}}),('Two fonts',{'t2f':{'fonts':'Noto Sans'}}),
       ('Bold light',{'t2w':{'Bold':'BOLD','light':'LIGHT'}}),
       ('AVAV',{'t2c':{'A':m.WHITE}}),
       ('First\nSecond',{'t2c':{'st\nSec':m.BLUE}}),
       ('Gradient',{'gradient':[m.RED,m.BLUE]}),
       ('Gradient',{'gradient':[m.RED,m.GREEN,m.BLUE]}),
       ('office fi',{'font':'Noto Sans','gradient':[m.YELLOW,m.PURPLE]}),
       ('Local gradient',{'t2g':{'gradient':[m.GREEN,m.BLUE]}}),
       ('abc def',{'t2g':{'[0:3]':[m.RED,m.BLUE]}}),
       ('Long form',{'text2color':{'Long':m.BLUE},'text2weight':{'form':'BOLD'}}),
       ('Override',{'t2c':{'Override':m.RED},'text2color':{'Override':m.BLUE}}),
       ('Tab\tcolor',{'t2c':{'color':m.GREEN},'tab_width':2})]
random.seed(228)
for _ in range(20):
    text='abcdefghijklmno'
    ranges=[sorted(random.sample(range(len(text)+1),2)) for _ in range(3)]
    specs.append((text,{'t2c':{f'[{ranges[0][0]}:{ranges[0][1]}]':m.BLUE},
                        't2w':{f'[{ranges[1][0]}:{ranges[1][1]}]':'BOLD'},
                        't2s':{f'[{ranges[2][0]}:{ranges[2][1]}]':'ITALIC'}}))
cases=[];colors=[];out=ROOT/'tests/reference_text_styles_images';out.mkdir(exist_ok=True)
def encode(x):
    if isinstance(x,m.ManimColor):return x.to_hex()
    if isinstance(x,dict):return {k:encode(v) for k,v in x.items()}
    if isinstance(x,list):return [encode(v) for v in x]
    return x
with m.tempconfig(dict(pixel_width=480,pixel_height=270,frame_height=8,frame_width=128/9,
                       media_dir=str(ROOT/'artifacts/oracle-styles'),verbosity='ERROR')):
    for i,(text,extra) in enumerate(specs,1):
        options={'font':'Liberation Sans','font_size':48,**extra};obj=m.Text(text,**options)
        image=f'style_{i:02}.png'
        cases.append(dict(text=text,options=encode(options),image=image,
            points=[g.points for g in obj],fills=[g.get_fill_color().to_rgb() for g in obj],
            fill_opacity=[g.get_fill_opacity() for g in obj],strokes=[g.get_stroke_color().to_rgb() for g in obj],
            stroke_opacity=[g.get_stroke_opacity() for g in obj],widths=[g.get_stroke_width() for g in obj]))
        camera=m.Camera();camera.capture_mobjects([obj]);Image.fromarray(camera.pixel_array).save(out/image)
    for refs in [[],[m.RED],[m.RED,m.BLUE],[m.RED,m.GREEN,m.BLUE]]:
        for n in [0,1,2,3,7,11]:
            if not refs and n>0:continue
            colors.append(dict(colors=encode(refs),length=n,expected=[c.to_rgba() for c in m.color_gradient(refs,n)]))
(ROOT/'tests/reference_text_styles.lua').write_text('-- Pinned Manim Text styling runs.\nreturn '+lua(dict(cases=cases,colors=colors))+'\n')
print(f'Generated {len(cases)} styled text cases and {len(colors)} gradient cases')
