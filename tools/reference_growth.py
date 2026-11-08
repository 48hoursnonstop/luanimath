"""Real Manim growth snapshots, backward evaluation and general spiral paths."""
import manim as m
import numpy as np
from PIL import Image
from reference import ROOT,lua

assert m.__version__=='0.22.1'
def subject(kind):
    if kind=='square':return m.Square(side_length=1.2,color=m.BLUE,fill_opacity=.3,stroke_width=3).rotate(.23).shift([.7,.4,0])
    if kind=='group':return m.VGroup(m.Circle(radius=.5,color=m.RED,fill_opacity=.2).shift(m.LEFT),m.Square(side_length=.9,color=m.TEAL,fill_opacity=.5).shift(m.RIGHT)).shift(m.DOWN*.3)
    return m.Text('Lua',font='Noto Sans',font_size=42,color=m.GOLD)
def state(obj):
    family=obj.family_members_with_points()
    return dict(points=[s.points for s in family],fills=[s.get_fill_color().to_rgb() for s in family],
                fill_opacity=[s.get_fill_opacity() for s in family],strokes=[s.get_stroke_color().to_rgb() for s in family],
                stroke_opacity=[s.get_stroke_opacity() for s in family],widths=[s.get_stroke_width() for s in family],center=obj.get_center())
cases=[];paths=[];image_index=[];out=ROOT/'tests/reference_growth_images';out.mkdir(exist_ok=True)
with m.tempconfig(dict(pixel_width=480,pixel_height=270,frame_height=8,frame_width=128/9,verbosity='ERROR',media_dir=str(ROOT/'artifacts/oracle-growth'))):
    for kind in ['GrowFromPoint','GrowFromCenter','GrowFromEdge','SpinInFromNothing']:
        for shape in ['square','group','text']:
            for variant in [0,1]:
                obj=subject(shape);options={} if variant==0 else dict(point_color=m.PURPLE,lag_ratio=.2,rate_func=m.linear)
                point=[-2,1,0];edge=[1,-1,0]
                if kind=='GrowFromPoint':anim=m.GrowFromPoint(obj,point,**options)
                elif kind=='GrowFromEdge':anim=m.GrowFromEdge(obj,edge,**options)
                else:anim=getattr(m,kind)(obj,**options)
                if variant:obj.shift([.4,-.1,0])
                anim.begin();states=[]
                record=dict(kind=kind,shape=shape,variant=variant,point=point,edge=edge,run_time=anim.run_time,states=states)
                cases.append(record);index=len(cases)
                for step,alpha in enumerate([0,.2,.5,.85,1,.35]):
                    anim.interpolate(alpha);states.append(dict(alpha=alpha,expected=state(obj)))
                    if shape=='square' and step in [1,2,3]:
                        name=f'growth_{index:02}_{step}.png';camera=m.Camera();camera.capture_mobjects([obj])
                        Image.fromarray(camera.pixel_array).save(out/name);image_index.append(dict(case=index,step=step+1,image=name))
                anim.finish();record['finished']=state(obj)
    for angle in [0,.005,.01,-np.pi,np.pi/2,2*np.pi]:
        for axis in [[0,0,1],[0,0,0],[1,2,-1]]:
            start=np.array([[-1,0,1],[2,.3,-1],[0,0,0]],dtype=float)
            end=np.array([[2,1,-1],[-1,0,1],[3,1,.2]],dtype=float)
            fn=m.utils.paths.spiral_path(angle,np.array(axis,dtype=float))
            for alpha in [-.2,0,.3,.8,1,1.2]:
                paths.append(dict(angle=angle,axis=axis,start=start,finish=end,alpha=alpha,expected=fn(start,end,alpha)))
(ROOT/'tests/reference_growth.lua').write_text('-- Real Manim 0.22.1 growth and spiral paths.\nreturn '+lua(dict(cases=cases,paths=paths,images=image_index))+'\n')
print(f'Generated {len(cases)} growth cases, {sum(len(c["states"]) for c in cases)} sampled states, {len(paths)} spiral paths and {len(image_index)} actual images')
