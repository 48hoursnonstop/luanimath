from pathlib import Path
import json
import numpy as np
from PIL import Image

root=Path(__file__).resolve().parents[1]
values=[]
for case in json.loads((root/'tests/reference_text_cases.json').read_text()):
    name=case.get('diagnostic',case)['image']
    path=root/'tests/reference_text_images'/name
    a=np.asarray(Image.open(path).convert('RGBA')).astype(float)
    b=np.asarray(Image.open(root/'artifacts/text'/case['image']).convert('RGBA')).astype(float)
    assert a.shape==b.shape
    d=np.abs(a-b);mae=float(d.mean());fraction=float(np.any(d>16,axis=2).mean())
    print(path.name,'MAE',mae,'fraction>16',fraction)
    assert mae<=0.6 and fraction<=0.004,(path.name,mae,fraction)
    values.append(mae)
assert len(values)==14
print('PASS: 13 original-upstream text images + 1 diagnosed RTL layout reference; max MAE',max(values))
