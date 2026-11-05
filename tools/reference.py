"""Development-only, real Manim 0.22.1 oracle. Writes frozen Lua fixtures."""
from __future__ import annotations

import argparse
import ast
import hashlib
import json
from pathlib import Path

import numpy as np
import manim as m
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]


def lua(value):
    if isinstance(value, np.ndarray):
        value = value.tolist()
    if isinstance(value, dict):
        return '{' + ','.join(f'[{lua(k)}]={lua(v)}' for k, v in value.items()) + '}'
    if isinstance(value, (list, tuple)):
        return '{' + ','.join(map(lua, value)) + '}'
    if isinstance(value, str):
        return json.dumps(value, ensure_ascii=False)
    if isinstance(value, (bool, np.bool_)):
        return 'true' if value else 'false'
    if value is None:
        return 'nil'
    if isinstance(value, (np.integer, np.floating)):
        value = value.item()
    if isinstance(value, (int, float)):
        assert np.isfinite(value)
        return repr(value)
    raise TypeError(type(value))


def state(obj):
    return dict(points=obj.points, center=obj.get_center(), width=obj.width,
                height=obj.height, fill=obj.get_fill_color().to_rgb(),
                fill_opacity=obj.get_fill_opacity(), stroke=obj.get_stroke_color().to_rgb(),
                stroke_opacity=obj.get_stroke_opacity(), stroke_width=obj.get_stroke_width())


def inventory(upstream):
    records = {}
    hashes = {}
    for path in sorted((upstream / 'manim').rglob('*.py')):
        rel = path.relative_to(upstream).as_posix()
        hashes[rel] = hashlib.sha256(path.read_bytes()).hexdigest()
        module = rel[:-3].replace('/', '.')
        tree = ast.parse(path.read_text())
        exports = None
        for node in tree.body:
            if isinstance(node, ast.Assign) and any(isinstance(t, ast.Name) and t.id == '__all__' for t in node.targets):
                try:
                    exports = ast.literal_eval(node.value)
                except (ValueError, TypeError):
                    pass
        for node in tree.body:
            if not isinstance(node, (ast.ClassDef, ast.FunctionDef, ast.AsyncFunctionDef)):
                continue
            if node.name.startswith('_') or (exports is not None and node.name not in exports):
                continue
            qualified = module + '.' + node.name
            records[qualified] = dict(id=qualified, kind='class' if isinstance(node, ast.ClassDef) else 'function',
                                      source=rel, line=node.lineno, status='not_implemented')
            if isinstance(node, ast.ClassDef):
                for child in node.body:
                    if isinstance(child, (ast.FunctionDef, ast.AsyncFunctionDef)) and (
                        not child.name.startswith('_') or child.name in {'__init__', '__getitem__', '__iter__', '__len__', '__add__', '__sub__'}
                    ):
                        ident = qualified + '.' + child.name
                        records[ident] = dict(id=ident, kind='method', source=rel,
                                             line=child.lineno, status='not_implemented')
        if exports:
            for name in exports:
                qualified = module + '.' + name
                records.setdefault(qualified, dict(id=qualified, kind='export', source=rel, status='not_implemented'))
    (ROOT/'compatibility/upstream_files.sha256').write_text(''.join(f'{v}  {k}\n' for k, v in hashes.items()))
    result = dict(upstream_version=m.__version__, definition='Module __all__ declarations, public definitions in modules without __all__, and public class methods defined in those classes. Inherited methods resolve to their defining class. Dynamic exports and runtime instance attributes need a later audit.',
                  entries=list(records.values()))
    (ROOT/'compatibility/api_inventory.json').write_text(json.dumps(result, indent=2)+'\n')
    print(f'Inventory: {len(records)} explicit API entries from {len(hashes)} source files')


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--upstream', type=Path, required=True)
    args = parser.parse_args()
    assert m.__version__ == '0.22.1', m.__version__
    cases = []
    specs = [
        ('Circle', {}, lambda: m.Circle()),
        ('Circle', {'radius': 2.3, 'num_components': 13}, lambda: m.Circle(radius=2.3, num_components=13)),
        ('Arc', {'radius': 1.7, 'start_angle': -.3, 'angle': -2.1}, lambda: m.Arc(radius=1.7,start_angle=-.3,angle=-2.1)),
        ('Square', {}, lambda: m.Square()),
        ('Rectangle', {'width': 3.2, 'height': .7}, lambda: m.Rectangle(width=3.2,height=.7)),
        ('Triangle', {}, lambda: m.Triangle()),
        ('RegularPolygon', {'n': 7, 'radius': 1.8}, lambda: m.RegularPolygon(n=7,radius=1.8)),
        ('Ellipse', {'width': 3.1, 'height': .8}, lambda: m.Ellipse(width=3.1,height=.8)),
        ('Line', {}, lambda: m.Line()),
        ('Dot', {}, lambda: m.Dot()),
    ]
    operations = [
        ([], lambda o:o),
        ([['shift',[1.2,-.6,.3]]], lambda o:o.shift([1.2,-.6,.3])),
        ([['shift',[1.2,-.6,.3]],['scale',-1.3]],lambda o:o.shift([1.2,-.6,.3]).scale(-1.3)),
        ([['rotate',.71]],lambda o:o.rotate(.71)),
        ([['rotate',-.91,{'axis':[1,2,3],'about_point':[.2,-.4,1]}]],lambda o:o.rotate(-.91,axis=[1,2,3],about_point=[.2,-.4,1])),
        ([['apply_matrix',[[1,.3],[.2,.9]]]],lambda o:o.apply_matrix([[1,.3],[.2,.9]])),
        ([['stretch',1.4,2]],lambda o:o.stretch(1.4,1)),
        ([['move_to',[2,-1,0]]],lambda o:o.move_to([2,-1,0])),
    ]
    for name, options, constructor in specs:
        for actions, operation in operations:
            obj = operation(constructor())
            cases.append(dict(name=name, options=options, actions=actions, expected=state(obj)))
    rate = []
    for name in ['linear','smooth','smoothstep','smootherstep','smoothererstep','rush_into','rush_from','slow_into','double_smooth','there_and_back']:
        for t in [-.1,0,.01,.125,.25,.5,.75,.9,1,1.1]:
            rate.append(dict(name=name,t=t,expected=getattr(m.rate_functions,name)(t)))
    paths=[]
    for name, options, constructor in specs:
        for alpha in [0,.07,.25,.5,.77,1]:
            obj=constructor()
            paths.append(dict(name=name, options=options, alpha=alpha, point=obj.point_from_proportion(alpha),
                              partial=obj.copy().pointwise_become_partial(obj,0,alpha).points, length=obj.get_arc_length()))
    animations=[]
    for kind in ['Transform','Create','FadeIn','FadeOut','Rotate']:
        for alpha in [0,.125,.25,.5,.75,1]:
            obj=m.Square(color=m.BLUE,fill_opacity=.35).shift(m.LEFT)
            target=m.Circle(color=m.GREEN,fill_opacity=.7).shift(m.RIGHT)
            if kind=='Transform': animation=m.Transform(obj,target,rate_func=m.linear)
            elif kind=='Rotate': animation=m.Rotate(obj,angle=1.2,about_point=m.ORIGIN,rate_func=m.linear)
            else: animation=getattr(m,kind)(obj,rate_func=m.linear)
            animation.begin();animation.interpolate(alpha)
            animations.append(dict(kind=kind,alpha=alpha,expected=state(obj)))
    fixture = dict(upstream_version=m.__version__,objects=cases,rates=rate,paths=paths,animations=animations)
    (ROOT/'tests/reference_v0221.lua').write_text('-- Generated by tools/reference.py using real Manim 0.22.1.\nreturn '+lua(fixture)+'\n')
    visual = ROOT/'tests/reference_images';visual.mkdir(parents=True,exist_ok=True)
    for case in animations:
        kind,alpha=case['kind'],case['alpha']
        with m.tempconfig(dict(pixel_width=320,pixel_height=180,frame_height=8,frame_width=128/9,background_color=m.BLACK)):
            obj=m.Square(color=m.BLUE,fill_opacity=.35).shift(m.LEFT)
            target=m.Circle(color=m.GREEN,fill_opacity=.7).shift(m.RIGHT)
            if kind=='Transform': animation=m.Transform(obj,target,rate_func=m.linear)
            elif kind=='Rotate': animation=m.Rotate(obj,angle=1.2,about_point=m.ORIGIN,rate_func=m.linear)
            else: animation=getattr(m,kind)(obj,rate_func=m.linear)
            animation.begin();animation.interpolate(alpha)
            camera=m.Camera();camera.capture_mobjects([obj])
            Image.fromarray(camera.pixel_array).save(visual/f'{kind}_{alpha:.3f}.png')
    inventory(args.upstream)
    print(f'Generated {len(cases)} object, {len(rate)} rate, {len(paths)} path, {len(animations)} animation cases; {len(animations)} real reference PNGs')


if __name__ == '__main__':
    main()
