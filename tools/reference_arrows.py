"""Real Manim Arrow/tip geometry, fixed-tip scaling, 3D orientation and GrowArrow."""
import manim as m
import numpy as np
from PIL import Image
from reference import ROOT,lua

assert m.__version__=='0.22.1'
def state(obj):
    family=obj.get_family()
    result=dict(points=[s.points for s in family],fills=[s.get_fill_color().to_rgb() for s in family],
                fill_opacity=[s.get_fill_opacity() for s in family],strokes=[s.get_stroke_color().to_rgb() for s in family],
                stroke_opacity=[s.get_stroke_opacity() for s in family],widths=[s.get_stroke_width() for s in family],
                start=obj.get_start(),end=obj.get_end(),center=obj.get_center())
    if isinstance(obj,m.Arrow):
        result.update(tip_base=obj.tip.base,tip_point=obj.tip.tip_point,tip_vector=obj.tip.vector,tip_length=obj.tip.length,
                      normal=obj.get_normal_vector(),default_tip_length=obj.get_default_tip_length())
    return result
cases=[];growth=[];tips=[]
specs=[([-1,0,0],[1,0,0],{}),([-2,-1,0],[2,1,0],{'buff':0}),
       ([0,0,0],[.2,0,0],{'buff':0}),([0,0,0],[0,0,0],{}),
       ([0,0,0],[2,1,3],{}),([0,0,0],[0,0,2],{'buff':0}),
       ([0,0,0],[0,0,-2],{'buff':0}),([-1,0,0],[1,0,0],{'tip_length':.7,'stroke_width':3}),
       ([-1,0,0],[1,0,0],{'max_tip_length_to_length_ratio':.1,'max_stroke_width_to_length_ratio':1}),
       ([-1,0,0],[1,0,0],{'max_tip_length_to_length_ratio':0}),
       ([-1,0,0],[1,0,0],{'buff':2,'color':m.PURPLE,'tip_style':{'fill_opacity':.4}})]
specs.append(([0,0,0],[.2,0,0],{'buff':0,'tip_shape':m.ArrowTriangleTip}))
def options_data(options):
    return {k:v.to_hex() if isinstance(v,m.ManimColor) else v.__name__ if isinstance(v,type) else v for k,v in options.items()}
out=ROOT/'tests/reference_arrows_images';out.mkdir(exist_ok=True)
with m.tempconfig(dict(pixel_width=480,pixel_height=270,frame_height=8,frame_width=128/9,verbosity='ERROR',media_dir=str(ROOT/'artifacts/oracle-arrows'))):
    for index,(start,end,options) in enumerate(specs,1):
        for action in ['none','rotate','scale','small','negative','all_tips','zero']:
            obj=m.Arrow(start,end,**options)
            if action=='rotate':obj.rotate(.37,axis=[1,2,1])
            elif action=='scale':obj.scale(2)
            elif action=='small':obj.scale(.2)
            elif action=='negative':obj.scale(-1.2)
            elif action=='all_tips':obj.scale(1.4,scale_tips=True,about_point=[.2,-.3,.1])
            elif action=='zero':obj.scale(0,scale_tips=True,about_point=start)
            record=dict(start=start,finish=end,options=options_data(options),action=action,expected=state(obj))
            if index in [6,7] and action in ['scale','small','negative']:record['pole_azimuth_issue']=True
            cases.append(record)
        obj=m.Arrow(start,end,**options);anim=m.GrowArrow(obj,point_color=m.GREEN,rate_func=m.linear);anim.begin()
        states=[]
        for alpha in [0,.25,.6,1,.4]:anim.interpolate(alpha);states.append(dict(alpha=alpha,expected=state(obj)))
        anim.finish();growth.append(dict(start=start,finish=end,options=options_data(options),states=states,finished=state(obj)))
    for kind in ['ArrowTriangleTip','ArrowTriangleFilledTip']:
        for options in [{},{'length':.6,'width':.2},{'length':0,'width':0},{'color':m.RED,'start_angle':.2}]:
            obj=getattr(m,kind)(**options)
            tips.append(dict(kind=kind,options={k:v.to_hex() if isinstance(v,m.ManimColor) else v for k,v in options.items()},expected=state(obj),base=obj.base,point=obj.tip_point,vector=obj.vector,length=obj.length,angle=obj.tip_angle))
    for i,factor in enumerate([1,.3,2],1):
        obj=m.Arrow([-3,-1,0],[3,1,0],color=m.YELLOW).scale(factor)
        camera=m.Camera();camera.capture_mobjects([obj]);Image.fromarray(camera.pixel_array).save(out/f'arrow_{i}.png')
    obj=m.Arrow([-2,-1,0],[2,1,3],color=m.BLUE)
    camera=m.ThreeDCamera(phi=.8,theta=-.6);camera.capture_mobjects([obj]);Image.fromarray(camera.pixel_array).save(out/'arrow_3d.png')
    obj=m.Arrow([-3,-1,0],[3,1,0],color=m.YELLOW);anim=m.GrowArrow(obj,rate_func=m.linear);anim.begin()
    for i,alpha in enumerate([0,.25,.6,1],1):
        anim.interpolate(alpha);camera=m.Camera();camera.capture_mobjects([obj]);Image.fromarray(camera.pixel_array).save(out/f'grow_{i}.png')
(ROOT/'tests/reference_arrows.lua').write_text('-- Actual Manim 0.22.1 Arrow/tip/GrowArrow states.\nreturn '+lua(dict(cases=cases,growth=growth,tips=tips))+'\n')
print(f'Generated {len(cases)} Arrow states, {len(growth)} growth traces, {len(tips)} tip cases and 8 images')
