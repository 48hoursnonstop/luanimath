from pathlib import Path
import posixpath
import sys

ROOT=Path(__file__).resolve().parents[1]
luanimath_root=str(ROOT)
sys.path.insert(0,str(ROOT/'docs/_ext'))
project='luanimath'
author='luanimath contributors'
copyright='2026, luanimath contributors'
release=(ROOT/'VERSION').read_text().strip()
version=release
extensions=['luadomain','sphinx_copybutton']
html_theme='furo'
highlight_language='lua'
templates_path=[str(ROOT/'docs/_templates')]
html_static_path=[str(ROOT/'docs/_static'),str(ROOT/'artifacts/docs-assets')]
html_title=f'luanimath {release}'
html_sidebars={'**':['sidebar/brand.html','language-switcher.html','sidebar/search.html','sidebar/scroll-start.html','sidebar/navigation.html','sidebar/scroll-end.html']}
html_theme_options={}
html_show_sourcelink=False
nitpicky=True
exclude_patterns=[]

def page_context(app,pagename,templatename,context,doctree):
    lang=app.config.language
    peer='es' if lang=='en' else 'en'
    context['language_peer_name']='Español' if peer=='es' else 'English'
    context['language_peer_url']=posixpath.relpath(f'{peer}/{pagename}.html',posixpath.dirname(f'{lang}/{pagename}.html'))

def setup(app):
    app.connect('html-page-context',page_context)
