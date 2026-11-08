"""Actual upstream target generation, state restoration and deferred transforms."""
import manim as m
import numpy as np
from PIL import Image
from reference import ROOT,lua

assert m.__version__=='0.22.1'
def subject(shape):
    if shape=='square':return m.Square(side_length=1.4,color=m.BLUE,fill_opacity=.4).rotate(.2).shift([.4,.2,0])
    if shape=='group':return m.VGroup(m.Circle(radius=.6,color=m.RED,fill_opacity=.2).shift(m.LEFT),m.Triangle(color=m.TEAL,fill_opacity=.3).scale(.6).shift(m.RIGHT))
    if shape=='text':return m.Text('Lua',font='Noto Sans',font_size=40,color=m.GOLD)
    return m.Surface(lambda u,v:np.array([u,v,.2*u*v]),u_range=[-1,1],v_range=[-1,1],resolution=(2,2),checkerboard_colors=False)
def state(obj):
    family=obj.get_family()
    return dict(points=[s.points for s in family],fills=[s.get_fill_color().to_rgb() for s in family],
                fill_opacity=[s.get_fill_opacity() for s in family],strokes=[s.get_stroke_color().to_rgb() for s in family],
                stroke_opacity=[s.get_stroke_opacity() for s in family],widths=[s.get_stroke_width() for s in family],
                center=obj.get_center(),width=obj.width,height=obj.height,depth=obj.depth)
def warp(p):return np.array([p[0]+.2*p[1]**2,p[1]+.1*np.sin(p[0]),p[2]+.1*p[0]*p[1]])
def edit(obj):return obj.scale(.7).rotate(.3).shift([.2,-.4,.1]).set_stroke(width=2)
cases=[];images=[];direct=[]
out=ROOT/'tests/reference_state_transforms_images';out.mkdir(exist_ok=True)
kinds=['MoveToTarget','Restore','ApplyMethod','ApplyFunction','ApplyPointwiseFunction','ApplyMatrix','FadeToColor','ScaleInPlace','ShrinkToCenter']
with m.tempconfig(dict(pixel_width=480,pixel_height=270,frame_height=8,frame_width=128/9,verbosity='ERROR',media_dir=str(ROOT/'artifacts/oracle-state-transforms'))):
    for kind in kinds:
        for shape in ['square','group','text','surface']:
            for variant in [0,1]:
                obj=subject(shape);options={} if variant==0 else dict(rate_func=m.linear,lag_ratio=.13,path_arc=.7)
                matrix=[[1,.3],[-.2,1.2]] if variant==0 else [[1,.2,.1],[-.1,.9,.2],[.3,0,1]]
                about=np.array([.2,-.3,.1])
                if kind=='MoveToTarget':
                    obj.generate_target();edit(obj.target);anim=m.MoveToTarget(obj,**options)
                elif kind=='Restore':
                    obj.save_state();edit(obj);anim=m.Restore(obj,**options)
                elif kind=='ApplyMethod':anim=m.ApplyMethod(obj.set_fill,m.PURPLE,.6,**options)
                elif kind=='ApplyFunction':
                    fn=edit if variant==0 else lambda copy:m.VGroup(copy,m.Dot([2,1,0],color=m.YELLOW))
                    anim=m.ApplyFunction(fn,obj,**options)
                elif kind=='ApplyPointwiseFunction':anim=m.ApplyPointwiseFunction(warp,obj,**options)
                elif kind=='ApplyMatrix':anim=m.ApplyMatrix(matrix,obj,about_point=about,**options)
                elif kind=='FadeToColor':anim=m.FadeToColor(obj,m.PURPLE,**options)
                elif kind=='ScaleInPlace':anim=m.ScaleInPlace(obj,1.4 if variant==0 else -.8,**options)
                else:anim=m.ShrinkToCenter(obj,**options)
                if variant:obj.shift([.3,-.2,.1])
                anim.begin();record=dict(kind=kind,shape=shape,variant=variant,matrix=matrix,about=about,run_time=anim.run_time,states=[])
                cases.append(record);index=len(cases)
                for step,alpha in enumerate([0,.25,.6,1,.35],1):
                    anim.interpolate(alpha);record['states'].append(dict(alpha=alpha,expected=state(obj)))
                    if shape=='square' and variant==0 and step in [2,3,4]:
                        name=f'state_{index:02}_{step}.png';camera=m.Camera();camera.capture_mobjects([obj])
                        Image.fromarray(camera.pixel_array).save(out/name);images.append(dict(case=index,step=step,image=name))
                anim.finish();record['finished']=state(obj)
    for shape in ['square','group','text','surface']:
        obj=subject(shape);obj.save_state();obj.shift([1,2,.5]).scale(.8).set_color(m.GREEN)
        obj.restore();first=state(obj)
        obj.save_state();obj.shift(m.LEFT).restore()
        direct.append(dict(kind='restore',shape=shape,first=first,expected=state(obj),saved=state(obj.saved_state)))
        obj=subject(shape);first_target=obj.generate_target();first_target.shift(m.RIGHT)
        obj.generate_target();obj.target.shift(m.UP);obj.become(obj.target)
        direct.append(dict(kind='target',shape=shape,expected=state(obj),target=state(obj.target)))
    obj=m.VGroup(m.Square());obj.save_state();obj.add(m.Circle().shift(m.RIGHT*2));obj.restore()
    direct.append(dict(kind='expanded_restore',expected=state(obj),saved=state(obj.saved_state)))
    for factor in [0,.25,-.3,2]:
        obj=subject('square');obj.scale_handle_to_anchor_distances(factor)
        direct.append(dict(kind='handles',factor=factor,expected=state(obj)))
    for smoothing in [False,True]:
        obj=m.Circle(pre_function_handle_to_anchor_scale_factor=.02,make_smooth_after_applying_functions=smoothing).shift(m.RIGHT)
        obj.apply_function(warp);direct.append(dict(kind='map',smoothing=smoothing,expected=state(obj)))
    obj=subject('square');matrix=np.array([[1.,.3],[-.2,1.2]]);about=np.array([.2,-.3,.1])
    anim=m.ApplyMatrix(matrix,obj,about_point=about);matrix[0,0]=9;about[0]=.8;anim.begin();anim.finish()
    direct.append(dict(kind='matrix_capture',expected=state(obj)))
    obj=subject('square');obj.save_state();anim=m.Restore(obj);obj.shift(m.RIGHT).save_state();obj.shift(m.UP);anim.begin();anim.finish()
    direct.append(dict(kind='late_saved_state',expected=state(obj)))
    obj=subject('square');old=obj.generate_target();old.shift(m.RIGHT);anim=m.MoveToTarget(obj);obj.generate_target().shift(m.UP);old.set_color(m.PINK);anim.begin();anim.finish()
    direct.append(dict(kind='captured_target',expected=state(obj)))
    obj=m.Surface(lambda u,v:np.array([u,v,.2*u*v]),u_range=[-1,1],v_range=[-1,1],resolution=(2,2),checkerboard_colors=False,make_smooth_after_applying_functions=True)
    obj.apply_function(warp);direct.append(dict(kind='smooth_surface',expected=state(obj)))
    obj=m.Mobject();obj.points=np.array([[0.,0,0],[1,2,3],[-1,.2,0]])
    obj.apply_function(warp);direct.append(dict(kind='nonvector_map',points=obj.points,center=obj.get_center()))
(ROOT/'tests/reference_state_transforms.lua').write_text('-- Actual Manim 0.22.1 states/transform classes.\nreturn '+lua(dict(cases=cases,images=images,direct=direct))+'\n')
print(f'Generated {len(cases)} transform cases, {sum(len(c["states"]) for c in cases)} sampled states, {len(direct)} direct operations and {len(images)} images')
