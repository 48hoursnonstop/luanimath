"""Lua API signatures, cross-references and the standard Sphinx search index."""
import re
import html
import posixpath
from pathlib import Path
from docutils import nodes
from docutils.parsers.rst import directives
from sphinx import addnodes
from sphinx.directives import ObjectDescription
from sphinx.domains import Domain,ObjType
from sphinx.roles import XRefRole
from sphinx.util.nodes import make_refnode
from sphinx.util.docutils import SphinxDirective

class SceneExample(SphinxDirective):
    required_arguments=1
    option_spec={'alt':directives.unchanged,'video':directives.flag}

    def run(self):
        slug=self.arguments[0]
        if not re.fullmatch(r'[a-z][a-z0-9_-]*',slug):raise self.error('invalid example name')
        root=Path(self.config.luanimath_root)
        path=root/'docs/examples'/(slug+'.lua')
        if not path.is_file():raise self.error(f'example does not exist: {slug}')
        self.env.note_dependency(str(path))
        base=posixpath.relpath('_static',posixpath.dirname(self.env.docname+'.html') or '.')
        alt=html.escape(self.options.get('alt',slug),quote=True)
        picture=f'<img src="{base}/{slug}.png" alt="{alt}" width="640" height="360" loading="lazy" style="height:auto;max-width:100%">'
        if 'video' in self.options:
            picture=f'<video controls preload="none" aria-label="{alt}" poster="{base}/{slug}.png" style="width:100%;max-width:640px"><source src="{base}/{slug}.mp4" type="video/mp4"><a href="{base}/{slug}.mp4">MP4</a></video>'
        code=path.read_text()
        literal=nodes.literal_block(code,code);literal['language']='lua'
        return [nodes.raw('',picture,format='html'),literal]

class LuaObject(ObjectDescription):
    def handle_signature(self,sig,signode):
        name=sig.split('(',1)[0].strip()
        signode+=addnodes.desc_name(sig,sig)
        return name

    def add_target_and_index(self,name,sig,signode):
        target='lua-'+re.sub(r'[^A-Za-z0-9_-]','-',name)
        signode['ids'].append(target)
        self.state.document.note_explicit_target(signode)
        self.env.get_domain('lua').data['objects'][name]=(self.env.docname,target,self.objtype)
        self.indexnode['entries'].append(('single',name,target,'',None))

class LuaDomain(Domain):
    name='lua'
    label='Lua'
    object_types={'function':ObjType('function','func','obj'),'data':ObjType('data','data','obj')}
    directives={'function':LuaObject,'data':LuaObject}
    roles={'func':XRefRole(),'data':XRefRole(),'obj':XRefRole()}
    initial_data={'objects':{}}

    def clear_doc(self,docname):
        self.data['objects']={k:v for k,v in self.data['objects'].items() if v[0]!=docname}

    def merge_domaindata(self,docnames,otherdata):
        for key,value in otherdata['objects'].items():
            if value[0] in docnames:self.data['objects'][key]=value

    def resolve_xref(self,env,fromdocname,builder,typ,target,node,contnode):
        if target in self.data['objects']:
            doc,anchor,_=self.data['objects'][target]
            return make_refnode(builder,fromdocname,doc,anchor,contnode,target)

    def get_objects(self):
        for name,(doc,anchor,kind) in self.data['objects'].items():
            yield name,name,kind,doc,anchor,1

def setup(app):
    app.add_domain(LuaDomain)
    app.add_config_value('luanimath_root','', 'env')
    app.add_directive('luanimath-example',SceneExample)
    return {'version':'1','parallel_read_safe':True,'parallel_write_safe':True}
