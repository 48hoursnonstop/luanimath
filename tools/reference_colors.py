"""Frozen RGB constants and rendered swatches from actual upstream Manim."""
import json
import manim as m
from manim.utils.color import manim_colors
from PIL import Image
from reference import ROOT,lua

assert m.__version__=='0.22.1'
colors={k:dict(hex=v.to_hex(),rgba=v.to_rgba()) for k,v in vars(manim_colors).items()
        if k.isupper() and isinstance(v,m.ManimColor)}
assert len(colors)==89
(ROOT/'tests/reference_colors.lua').write_text('-- Actual Manim 0.22.1 palette values.\nreturn '+lua(colors)+'\n')
(ROOT/'tests/reference_colors.json').write_text(json.dumps({k:v['hex'] for k,v in colors.items()},indent=2)+'\n')
with m.tempconfig(dict(pixel_width=480,pixel_height=270,frame_width=128/9,frame_height=8)):
    shapes=[]
    for index,name in enumerate(sorted(colors)):
        x=(index%10-4.5)*1.2;y=(4-index//10)*.7
        shapes.append(m.Rectangle(width=1,height=.5,color=getattr(m,name),fill_opacity=1,stroke_width=0).shift([x,y,0]))
    camera=m.Camera();camera.capture_mobjects(shapes)
    folder=ROOT/'tests/reference_colors_images';folder.mkdir(exist_ok=True)
    Image.fromarray(camera.pixel_array).save(folder/'palette.png')
print('Generated 89 exact RGB/RGBA constants and one actual color swatch image')
