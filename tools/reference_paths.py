"""Upstream curved paths, composition evaluation and grouped path motion."""
import manim as m
from manim.utils import paths
import numpy as np
from reference import lua,ROOT

start=np.array([[-1.,0.,0.],[0.,1.,2.]])
finish=np.array([[2.,1.,0.],[-1.,-2.,1.]])
cases=[]
for angle in [-np.pi,0,.005,.05,1,np.pi,4*np.pi/3]:
    for axis in [[0,0,1],[1,2,3],[0,0,0]]:
        for alpha in [-.2,0,.1,.5,1,1.2]:
            cases.append(dict(kind='arc',angle=angle,axis=axis,alpha=alpha,start=start,finish=finish,
                              expected=paths.path_along_arc(angle,axis)(start,finish,alpha)))
for centers in [[0,0,0],[[1,0,0],[0,1,0]]]:
    for alpha in [0,.25,.5,.75,1]:
        cases.append(dict(kind='circles',angle=1.3,centers=centers,alpha=alpha,start=start,finish=finish,
                          expected=paths.path_along_circles(1.3,np.array(centers))(start,finish,alpha)))
transforms=[]
for angle in [-np.pi,.005,.1,np.pi/2,np.pi]:
    for alpha in [0,.25,.5,.75,1]:
        a=m.Square().shift(m.LEFT);b=m.Circle().shift(m.RIGHT)
        animation=m.Transform(a,b,path_arc=angle,rate_func=m.linear);animation.begin();animation.interpolate(alpha)
        transforms.append(dict(angle=angle,alpha=alpha,points=a.points))
composition=[]
for kind in ['AnimationGroup','LaggedStart','Succession']:
    for rate in ['linear','there_and_back'] if kind!='Succession' else ['linear']:
        a,b=m.Square().shift(m.LEFT),m.Circle().shift(m.RIGHT)
        one=m.Transform(a,a.copy().shift(m.UP),run_time=1,rate_func=m.linear)
        two=m.Transform(b,b.copy().shift(m.DOWN),run_time=2,rate_func=m.linear)
        group=getattr(m,kind)(one,two,rate_func=getattr(m,rate))
        group._setup_scene(m.Scene());group.begin()
        trace=[0,.1,.4,.75,.5,.2,1] if kind!='Succession' else [0,.1,.4,.75,1]
        values=[]
        for alpha in trace:
            group.interpolate(alpha);values.append(dict(alpha=alpha,a=a.points.copy(),b=b.points.copy()))
        group.finish()
        composition.append(dict(kind=kind,rate=rate,trace=values,final_a=a.points,final_b=b.points))
motion=[]
for alpha in [0,.1,.5,.75,1]:
    obj=m.VGroup(m.Square().shift(m.LEFT),m.Circle().shift(m.RIGHT))
    path=m.Circle(radius=2)
    animation=m.MoveAlongPath(obj,path,rate_func=m.linear);animation.begin();animation.interpolate(alpha)
    motion.append(dict(alpha=alpha,points=[c.points for c in obj.get_family()]))
obj=m.Square();obj.add_updater(lambda mob,dt:mob.shift(dt*m.RIGHT))
target=m.Circle().shift(2*m.RIGHT);target.add_updater(lambda mob,dt:mob.shift(dt*m.UP))
animation=m.Transform(obj,target,rate_func=m.linear);animation.begin()
updates=[]
for dt,alpha in [(0,0),(.1,.1),(.2,.4),(.25,.75)]:
    animation.update_mobjects(dt);animation.interpolate(alpha)
    updates.append(dict(dt=dt,alpha=alpha,points=obj.points.copy(),target=target.points.copy()))
animation.finish()
(ROOT/'tests/reference_paths.lua').write_text('-- Real Manim 0.22.1 path/composition oracle.\nreturn '+lua(dict(paths=cases,transforms=transforms,composition=composition,motion=motion,updates=updates,updated_finish=obj.points))+'\n')
print(f'Generated {len(cases)} mathematical paths, {len(transforms)} arc transforms, {len(composition)} composition traces, {len(motion)} group motion states')
