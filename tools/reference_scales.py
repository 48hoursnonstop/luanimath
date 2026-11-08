"""Execute pinned Manim scales, transformed number lines, axes and scaled sampling."""
import manim as m
import numpy as np
from PIL import Image
from reference import ROOT, lua

assert m.__version__ == '0.22.1'
specs=[('LinearBase',{}),('LinearBase',{'scale_factor':2.5}),
       ('LinearBase',{'scale_factor':-1.3}),('LogBase',{}),
       ('LogBase',{'base':2}),('LogBase',{'base':.5})]
def scale(spec):return getattr(m,spec[0])(**spec[1])
def state(obj):
    return dict(points=[s.points for s in obj.family_members_with_points()],
                center=obj.get_center(),width=obj.width,height=obj.height)
def pose(obj,index):
    if index:obj.rotate(.41).scale(1.2).shift([.2,-.3,.1])
cases=[];functions=[];operations=[];axes=[]
for spec in specs:
    s=scale(spec);values=np.array([-2.,-.5,0,1,3])
    operations.append(dict(kind=spec[0],options=spec[1],values=values,
                           mapped=s.function(values),inverse=s.inverse_function(s.function(values))))
    for tip in [False,True]:
        for p in [0,1]:
            options=dict(x_range=[-2,3,.5],length=8,include_tip=tip)
            obj=m.NumberLine(scaling=s,**options);pose(obj,p)
            numbers=s.function(np.array([-2.,0,.25,2.,3.]))
            cases.append(dict(scale=spec,options=options,pose=p,expected=state(obj),
                              ticks=obj.get_tick_range(),values=numbers,mapped=obj.n2p(numbers),
                              inverse=obj.p2n([[-2.,.3,0],[0.,0,0],[2.,-.1,.2]]),
                              bounds=[obj.x_min,obj.x_max,obj.x_step]))
    for smooth in [False,True]:
        options=dict(t_range=[-1,1,.2],use_smoothing=smooth)
        obj=m.ParametricFunction(lambda t:np.array([t,t*t/5,0]),scaling=s,**options)
        functions.append(dict(scale=spec,options=options,expected=state(obj)))
    options=dict(t_range=[-1,1,.2],discontinuities=[0],dt=.03)
    obj=m.ParametricFunction(lambda t:np.array([t,t*t/5,0]),scaling=s,**options)
    functions.append(dict(scale=spec,options=options,expected=state(obj)))
axis_specs=[(specs[0],specs[3]),(specs[4],specs[0]),(specs[3],specs[4]),
            (specs[1],specs[0]),(specs[5],specs[4]),(specs[2],specs[0])]
for xs,ys in axis_specs:
    for tips in [False,True]:
        for p in [0,1]:
            options=dict(x_range=[-1,2,.5],y_range=[-2,2,1],x_length=8,y_length=5,tips=tips)
            obj=m.Axes(**options,x_axis_config={'scaling':scale(xs)},y_axis_config={'scaling':scale(ys)})
            graph=obj.plot(lambda x:x*.3+1,x_range=[-1,2,.1],color=m.BLUE)
            pose(obj,p);pose(graph,p)
            values=[[scale(xs).function(x),scale(ys).function(y)] for x,y in [(-1,-2),(0,0),(.5,1),(2,2)]]
            axes.append(dict(x_scale=xs,y_scale=ys,options=options,pose=p,expected=state(obj),
                             values=values,mapped=[obj.c2p(*point) for point in values],
                             inverse=obj.p2c([[-2.,.3,0],[0.,0,0],[2.,-.1,.2]]),
                             graph=state(graph)))
colors={key:getattr(m,key).to_hex() for key in ['WHITE','BLACK','RED','GREEN','BLUE','YELLOW','PURPLE','TEAL','ORANGE','PINK','GRAY','GREY','BLUE_D','RED_D','GREEN_D']}
(ROOT/'tests/reference_scales.lua').write_text('-- Real Manim 0.22.1 scaling/palette reference.\nreturn '+lua(dict(colors=colors,operations=operations,lines=cases,functions=functions,axes=axes))+'\n')
out=ROOT/'tests/reference_scales_images';out.mkdir(exist_ok=True)
with m.tempconfig(dict(pixel_width=480,pixel_height=270,frame_height=8,frame_width=128/9)):
    for i,(xs,ys) in enumerate(axis_specs[:3],1):
        ax=m.Axes(x_range=[-1,2,.5],y_range=[-2,2,1],x_length=8,y_length=5,
                  x_axis_config={'scaling':scale(xs)},y_axis_config={'scaling':scale(ys)})
        graph=ax.plot(lambda x:x*.3+1,x_range=[-1,2,.05],color=m.BLUE)
        dot=m.Dot(ax.c2p(scale(xs).function(.5),scale(ys).function(1)),color=m.YELLOW)
        camera=m.Camera();camera.capture_mobjects([ax,graph,dot])
        Image.fromarray(camera.pixel_array).save(out/f'scale_{i}.png')
print(f'Generated {len(operations)} scale operations, {len(cases)} lines, {len(functions)} functions and {len(axes)} axes/plots')
