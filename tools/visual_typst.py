from pathlib import Path
import json
import numpy as np
from PIL import Image

root=Path(__file__).resolve().parents[1]
results=[]
for case in json.loads((root/'tests/reference_typst_cases.json').read_text()):
    folder='reference_typst_diagnostic_images' if case['diagnostic'] else 'reference_typst_images'
    a=np.asarray(Image.open(root/'tests'/folder/case['image']).convert('RGBA')).astype(float)
    b=np.asarray(Image.open(root/'artifacts/typst'/case['image']).convert('RGBA')).astype(float)
    assert a.shape==b.shape
    diff=np.abs(a-b);mae=float(diff.mean());fraction=float(np.any(diff>16,axis=2).mean())
    assert mae<=.6 and fraction<=.004,(case,mae,fraction)
    results.append(dict(**case,mae=mae,fraction_over_16=fraction))
    print(case['image'],'diagnostic' if case['diagnostic'] else 'original','MAE',mae,'fraction>16',fraction)
assert len(results)==44
(root/'artifacts/typst/results.json').write_text(json.dumps(results,indent=2)+'\n')
print('PASS:',sum(not c['diagnostic'] for c in results),'original-upstream frames and',sum(c['diagnostic'] for c in results),'separately diagnosed SVG-cache frames')
