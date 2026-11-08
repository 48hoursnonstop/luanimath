"""Source release, manifest, clean extraction, rebuild, regressions and media verification."""
import hashlib
import json
import os
from pathlib import Path
import subprocess
import tarfile
import tempfile

root=Path(__file__).resolve().parents[1]
version=(root/'VERSION').read_text().strip()
release=root/'releases';release.mkdir(exist_ok=True)
name='luanim-'+version
excluded={'.git','.dev','build','artifacts','releases','__pycache__','.pytest_cache','.luanim-cache'}
files=sorted(p for p in root.rglob('*') if p.is_file() and not excluded.intersection(p.relative_to(root).parts) and p.name!='MANIFEST.sha256')
manifest=''.join(hashlib.sha256(p.read_bytes()).hexdigest()+'  '+p.relative_to(root).as_posix()+'\n' for p in files)
(root/'MANIFEST.sha256').write_text(manifest)
files.append(root/'MANIFEST.sha256')
archive=release/(name+'.tar.gz')
with tarfile.open(archive,'w:gz') as tar:
    for path in sorted(files):
        tar.add(path,arcname=name+'/'+path.relative_to(root).as_posix(),recursive=False)
digest=hashlib.sha256(archive.read_bytes()).hexdigest()
(release/(archive.name+'.sha256')).write_text(digest+'  '+archive.name+'\n')
with tempfile.TemporaryDirectory(prefix='clean-',dir=root/'.dev') as tmp:
    with tarfile.open(archive) as tar:tar.extractall(tmp,filter='data')
    clean=Path(tmp)/name
    log=release/(name+'-clean-build.log')
    with log.open('w') as output:
        subprocess.run(['sha256sum','--check','MANIFEST.sha256'],cwd=clean,stdout=output,stderr=subprocess.STDOUT,check=True)
        # Clear inherited paths to guarantee this build loads only the extracted source/module.
        env=os.environ.copy()
        for key in ['LUA_PATH','LUA_CPATH']:env.pop(key,None)
        subprocess.run(['make','check'],cwd=clean,env=env,stdout=output,stderr=subprocess.STDOUT,check=True)
report={'archive':archive.name,'sha256':digest,'clean_build':'passed','command':'make check','source_files':len(files),
        'clean_log':log.name,'runtime':'Lua 5.4 + native Cairo/Pango/libxml2 + FFmpeg; no Python engine'}
(release/(name+'-verification.json')).write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(report,indent=2))
