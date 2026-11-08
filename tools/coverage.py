"""Apply reviewed coverage declarations to the upstream inventory; no inferred completeness."""
import collections
import json
from pathlib import Path

root=Path(__file__).resolve().parents[1]
path=root/'compatibility/api_inventory.json'
data=json.loads(path.read_text())
declarations=json.loads((root/'compatibility/implemented.json').read_text())
entries={entry['id']:entry for entry in data['entries']}
for entry in entries.values():
    entry['status']='not_implemented'
    for key in ['lua_api','evidence','limitations','blocked_by']:
        entry.pop(key,None)
    if '.opengl.' in entry['id']:
        entry.update(status='blocked',blocked_by=['OpenGL backend'])
    elif 'tex_mobject.' in entry['id']:
        entry.update(status='blocked',blocked_by=['TeX compiler integration'])
for declaration in declarations:
    assert declaration['id'] in entries,'unknown upstream API: '+declaration['id']
    assert declaration['status'] in ['implemented_verified','implemented_partial','not_applicable']
    assert declaration.get('evidence') or declaration['status']=='not_applicable'
    if declaration['status']=='implemented_partial':assert declaration.get('limitations')
    entries[declaration['id']].update(declaration)
path.write_text(json.dumps(data,indent=2)+'\n')
counts=dict(collections.Counter(e['status'] for e in entries.values()))
summary={'upstream_version':data['upstream_version'],'inventory_entries':len(entries),'statuses':counts,
         'note':'Status counts refer to explicitly inventoried symbols, not an overall project completion percentage. Partial APIs are available only within their documented restrictions.'}
(root/'compatibility/summary.json').write_text(json.dumps(summary,indent=2)+'\n')
print(json.dumps(summary))
