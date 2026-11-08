"""Build/check the bilingual manual against the actual Lua API and real scenes."""
import argparse
import collections
import hashlib
import html
from html.parser import HTMLParser
import importlib.util
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
from urllib.parse import unquote,urlsplit

ROOT=Path(__file__).resolve().parents[1]
def module(name):
    spec=importlib.util.spec_from_file_location(name,ROOT/'docs'/(name+'.py'))
    obj=importlib.util.module_from_spec(spec);spec.loader.exec_module(obj);return obj
catalog=module('catalog');parameters=module('parameters');results=module('returns')

def surface():
    env=os.environ.copy();env['LUA_PATH']=str(ROOT/'lua/?.lua')+';'+str(ROOT/'lua/?/init.lua')+';;';env['LUA_CPATH']=str(ROOT/'build/?.so')+';;'
    raw=subprocess.check_output([os.environ.get('LUA','lua5.4'),'tools/doc_api.lua'],cwd=ROOT,env=env,text=True)
    funcs=[];constants=[]
    for line in raw.splitlines():
        row=line.split('\t')
        if row[0]=='D':constants.append(dict(name=row[1],value=row[2]));continue
        _,name,args,varargs,source,lineno,identity,category=row
        source=source.removeprefix(str(ROOT)+'/')
        funcs.append(dict(name=name,args=args.split(',') if args else [],variadic=varargs=='true',source=source,line=int(lineno),identity=identity,category=category))
    groups=collections.defaultdict(list)
    for obj in funcs:groups[obj['identity']].append(obj)
    missing=[]
    for group in groups.values():
        choices=[obj for obj in group if obj['name'] in catalog.API]
        if not choices:missing.append([obj['name'] for obj in group]);continue
        canonical=choices[0]['name']
        for obj in group:
            obj['canonical']=canonical
            obj['en'],obj['es']=catalog.API[canonical]
            obj['returns']=results.returns(canonical)
            if obj['source'].endswith('/rate_functions.lua'):
                obj['raw_args']=list(obj['args'])
                obj['args']=['t','k'] if canonical in ('smooth','rush_into','rush_from','there_and_back') else ['t']
                obj['variadic']=False
            assert all(len(obj[lang])>=12 for lang in ('en','es')),obj['name']
            for arg in obj['args']:
                assert parameters.parameter(canonical,arg),f'missing parameter docs: {canonical}({arg})'
    assert not missing,'undocumented exports: '+repr(missing)
    names={obj['name'] for obj in funcs}
    assert not set(catalog.API)-names,'stale API descriptions: '+repr(set(catalog.API)-names)
    report=dict(public_functions=len(funcs),distinct_functions=len(groups),aliases=len(funcs)-len(groups),constants=len(constants),missing=0,languages=['en','es'])
    return funcs,constants,report

GRAPH_METHODS={'add_tip','number_to_point','point_to_number','n2p','p2n','get_tick_range','get_tick','coords_to_point','c2p','point_to_coords','p2c','plot','get_axes','get_origin','get_tick_marks','get_unit_size','get_function','get_point_from_function'}
PATH_METHODS={'set_points','set_points_as_corners','get_start','get_end','get_length','get_angle','get_num_curves','get_arc_length','point_from_proportion','pointwise_become_partial','get_subcurve','reverse_direction','get_subpaths','clear_points','append_points','has_new_path_started','get_last_point','start_new_path','add_cubic_bezier_curve','add_cubic_bezier_curve_to','add_quadratic_bezier_curve_to','add_line_to','add_points_as_corners','add_subpath','is_closed','close_path','get_start_anchors','get_end_anchors','get_anchors','insert_n_curves','set_points_smoothly','make_smooth'}
CATEGORIES={
 'objects':('Objects and geometry','Objetos y geometría'),
 'paths':('Paths and Bézier geometry','Trazados y geometría Bézier'),
 'animations':('Animations and composition','Animaciones y composición'),
 'scenes':('Scenes and rendering','Escenas y renderizado'),
 'text':('Text and glyphs','Texto y glifos'),
 'typst':('Mathematical text','Texto matemático'),
 'svg':('SVG import','Importación SVG'),
 'graphing':('Coordinate systems and plots','Coordenadas y gráficas'),
 'cameras':('Cameras','Cámaras'),
 'three_d':('Three-dimensional objects','Objetos tridimensionales'),
 'vectors':('Vectors','Vectores'),
 'colors':('Colors and easing','Colores y suavizado'),
 'bezier':('Low-level Bézier utilities','Utilidades Bézier de bajo nivel'),
 'config':('Configuration','Configuración'),
}
def category(obj):
    name=obj['name'];path=obj['source']
    if name.startswith(('Scene:','Renderer:','Renderer.')) or name in ('Scene','MovingCameraScene','ThreeDScene','Renderer'):return 'scenes'
    if name.startswith('Camera:') or path.endswith('/camera.lua'):return 'cameras'
    if name.startswith('Mobject:'):
        key=name.split(':')[1]
        if key in ('select','get_baseline_frame','get_baseline_frames'):return 'typst'
        if key in GRAPH_METHODS:return 'graphing'
        if key in PATH_METHODS:return 'paths'
        if key in ('get_font_size','set_font_size'):return 'text'
        return 'objects'
    if name.startswith('vec.') or name in ('vec','Vector'):return 'vectors'
    for suffix,cat in [('animation','animations'),('text','text'),('typst','typst'),('typst_file','typst'),('svg','svg'),('graphing','graphing'),('three_d','three_d'),('paths','paths'),('vector','vectors'),('color','colors'),('rate_functions','colors'),('bezier','bezier'),('config','config')]:
        if path.endswith('/'+suffix+'.lua'):return cat
    return 'objects'

def heading(text,level='='):return text+'\n'+level*max(8,len(text))+'\n\n'
def table(headers,rows):
    out=['.. list-table::','   :header-rows: 1','   :widths: 24 18 58','']
    for row in [headers]+rows:
        for i,value in enumerate(row):out.append(('   * - ' if i==0 else '     - ')+str(value).replace('\n',' '))
    return '\n'.join(out)+'\n\n'

def references(source,funcs,constants,report,lang):
    index=0 if lang=='en' else 1
    folder=source/lang/'reference';folder.mkdir(parents=True,exist_ok=True)
    intro=('Signatures are collected from the running Lua library. Descriptions and supported options are reviewed in both languages. Availability does not imply full upstream compatibility.','Las firmas se obtienen de la biblioteca Lua en ejecución. Las descripciones y opciones se revisan en ambos idiomas. La disponibilidad no implica compatibilidad completa con upstream.')[index]
    text=heading(('API reference','Referencia de API')[index])+intro+'\n\n.. toctree::\n   :maxdepth: 1\n\n'
    text+=''.join('   '+key+'\n' for key in CATEGORIES)+'   constants\n   ../reference_fields\n'
    (folder/'index.rst').write_text(text)
    for key,titles in CATEGORIES.items():
        text=heading(titles[index])
        text+=('Methods listed with ``Mobject:`` use the shared Lua method table; each description states any required object kind.','Los métodos ``Mobject:`` usan la tabla compartida de Lua; cada descripción indica el tipo de objeto requerido.')[index]+'\n\n'
        for obj in sorted((f for f in funcs if category(f)==key),key=lambda f:f['name'].lower()):
            name=obj['name'];args=list(obj['args'])
            if obj['variadic']:args.append('...')
            text+='.. lua:function:: '+name+'('+', '.join(args)+')\n\n'
            if name!=obj['canonical']:
                text+='   '+('Alias of','Alias de')[index]+' :lua:func:`'+obj['canonical']+'`.\n\n';continue
            text+='   '+obj[lang]+'\n\n'
            text+='   '+('Returns','Devuelve')[index]+': ``'+obj['returns']+'``.\n\n'
            if obj['args']:
                text+='   '+('Parameters','Parámetros')[index]+'\n\n'
                for arg in obj['args']:
                    kind,en,es=parameters.parameter(name,arg)
                    text+=f'   * ``{arg}`` — ``{kind}``: '+(en,es)[index]+'\n'
                text+='\n'
            rows=[]
            for opt,kind,default,en,es in catalog.OPTIONS.get(name,[]):
                default=catalog.DEFAULTS.get(name,{}).get(opt,default)
                rows.append((f'``{opt}`` / ``{kind}``',f'``{default}``',(en,es)[index]))
            if rows:
                fragment=table(('Option / type','Default','Meaning') if index==0 else ('Opción / tipo','Valor inicial','Significado'),rows)
                text+=''.join('   '+line+'\n' if line else '\n' for line in fragment.splitlines())+'\n'
            link=f'https://github.com/48hoursnonstop/luanimath/blob/main/{obj["source"]}#L{obj["line"]}'
            text+='   `'+('Lua source','Código Lua')[index]+' <'+link+'>`_\n\n'
        (folder/(key+'.rst')).write_text(text)
    rows=[('``'+obj['name']+'``','``'+obj['value']+'``',('Exported constant.','Constante exportada.')[index]) for obj in constants]
    (folder/'constants.rst').write_text(heading(('Constants','Constantes')[index])+table(('Name','Value','Meaning') if index==0 else ('Nombre','Valor','Significado'),rows))
    summary=json.loads((ROOT/'compatibility/summary.json').read_text());total=summary['inventory_entries'];status=summary['statuses']
    text=heading(('Compatibility and measured coverage','Compatibilidad y cobertura medida')[index])
    text+=('These counts refer to upstream inventory symbols, not estimated engineering effort or overall completion. Partial APIs are restricted to the behavior documented in this manual.','Estas cifras cuentan símbolos de upstream, no esfuerzo de ingeniería ni avance global estimado. Las API parciales se limitan al comportamiento documentado en este manual.')[index]+'\n\n'
    rows=[(key,str(status.get(key,0)),f'{100*status.get(key,0)/total:.2f}%') for key in ('implemented_verified','implemented_partial','blocked','not_implemented')]
    text+=table(('Status','Symbols','Inventory share') if index==0 else ('Estado','Símbolos','Proporción del inventario'),rows)
    text+=('The full inventory and executed test records are available in the repository.','El inventario completo y los resultados ejecutados están en el repositorio.')[index]+'\n\n'
    for title,path in [('COMPATIBILITY.md','COMPATIBILITY.md'),('TEST_RESULTS.md','TEST_RESULTS.md'),('API inventory','compatibility/api_inventory.json')]:text+=f'* `{title} <https://github.com/48hoursnonstop/luanimath/blob/main/{path}>`_\n'
    (source/lang/'compatibility.rst').write_text(text)

def render_examples():
    from PIL import Image
    assets=ROOT/'artifacts/docs-assets';assets.mkdir(parents=True,exist_ok=True)
    results=[]
    manifest=json.loads((ROOT/'docs/examples/manifest.json').read_text())
    assert {p.stem for p in (ROOT/'docs/examples').glob('*.lua')}==set(manifest),'gallery manifest and source scenes differ'
    for path in sorted((ROOT/'docs/examples').glob('*.lua')):
        output=assets/(path.stem+'.mp4')
        log=subprocess.check_output([os.environ.get('LUA','lua5.4'),'tools/luanimath.lua',str(path),'--output',str(output),'--width','640','--height','360','--fps','12'],cwd=ROOT,text=True)
        match=re.search(r'Rendered (\d+) frames',log);assert match,log
        assert int(match[1])==manifest[path.stem],(path.name,match[1],manifest[path.stem])
        info=json.loads(subprocess.check_output(['ffprobe','-v','error','-count_frames','-select_streams','v:0','-show_entries','stream=width,height,nb_read_frames,r_frame_rate','-of','json',str(output)]))['streams'][0]
        assert (info['width'],info['height'],int(info['nb_read_frames']))==(640,360,int(match[1])),info
        subprocess.run(['ffmpeg','-v','error','-i',str(output),'-f','null','-'],check=True)
        png=output.with_suffix('.png')
        with Image.open(png) as image:
            assert image.size==(640,360);assert max(c[1] for c in image.convert('RGB').getextrema())>32
        results.append(dict(example=path.name,frames=int(match[1]),width=640,height=360,fps=12,source_sha256=hashlib.sha256(path.read_bytes()).hexdigest(),png_sha256=hashlib.sha256(png.read_bytes()).hexdigest(),mp4_sha256=hashlib.sha256(output.read_bytes()).hexdigest()))
        print(log.strip(),flush=True)
    assert len(results)==len(manifest)
    (assets/'verification.json').write_text(json.dumps(results,indent=2)+'\n')

class Links(HTMLParser):
    def __init__(self):super().__init__();self.links=[];self.ids=set()
    def handle_starttag(self,tag,attrs):
        attrs=dict(attrs)
        if 'id' in attrs:self.ids.add(attrs['id'])
        for key in ('href','src','poster'):
            if key in attrs:self.links.append(attrs[key])

def validate_links(output):
    pages={}
    for path in output.rglob('*.html'):
        parser=Links();parser.feed(path.read_text());pages[path.resolve()]=parser
    checked=0
    for path,parser in pages.items():
        for link in parser.links:
            uri=urlsplit(link)
            if uri.scheme or uri.netloc:continue
            target=(path.parent/unquote(uri.path)).resolve() if uri.path else path
            if target.is_dir():target=target/'index.html'
            assert target.is_file(),f'broken local link in {path}: {link}'
            if uri.fragment and target in pages:assert unquote(uri.fragment) in pages[target].ids,f'missing anchor in {path}: {link}'
            checked+=1
    print(f'PASS: {len(pages)} HTML pages; {checked} local links/assets/anchors',flush=True)
    return dict(html_pages=len(pages),checked_local_links=checked)

def main():
    parser=argparse.ArgumentParser();parser.add_argument('command',choices=['check','build']);args=parser.parse_args()
    funcs,constants,report=surface();print(json.dumps(report),flush=True)
    if args.command=='check':return
    render_examples()
    source=ROOT/'artifacts/docs-source';output=ROOT/'artifacts/docs'
    if source.exists():shutil.rmtree(source)
    if output.exists():shutil.rmtree(output)
    for lang in ('en','es'):
        shutil.copytree(ROOT/'docs'/lang,source/lang)
        references(source,funcs,constants,report,lang)
        subprocess.run([sys.executable,'-m','sphinx','-b','html','-n','-W','--keep-going','-c',str(ROOT/'docs'),'-D','language='+lang,str(source/lang),str(output/lang)],check=True)
    (output/'index.html').write_text('<!doctype html><html lang="en"><meta charset="utf-8"><title>luanimath documentation</title><h1>luanimath</h1><nav aria-label="Language"><a href="en/index.html" lang="en">English</a> · <a href="es/index.html" lang="es">Español</a></nav></html>')
    (output/'.nojekyll').write_text('')
    report.update(validate_links(output))
    (output/'verification.json').write_text(json.dumps(report,indent=2)+'\n')
    (output/'api.json').write_text(json.dumps(dict(functions=funcs,constants=constants),indent=2,ensure_ascii=False)+'\n')

if __name__=='__main__':main()
