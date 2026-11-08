from pathlib import Path
import json
import numpy as np
from PIL import Image

root=Path(__file__).resolve().parents[1];results=[]
for path in sorted((root/'tests/reference_rounding_images').glob('*.png')):
    a=np.asarray(Image.open(path).convert('RGBA')).astype(float)
    b=np.asarray(Image.open(root/'artifacts/rounding'/path.name).convert('RGBA')).astype(float)
    assert a.shape==b.shape
    d=np.abs(a-b);mae=float(d.mean());fraction=float(np.any(d>16,axis=2).mean())
    assert mae<=.6 and fraction<=.004,(path.name,mae,fraction)
    results.append(dict(image=path.name,mae=mae,fraction_over_16=fraction))
    print(path.name,'MAE',mae,'fraction>16',fraction)
assert len(results)==11
(root/'artifacts/rounding/results.json').write_text(json.dumps(results,indent=2)+'\n')
print('PASS: 11 actual circular/rounded geometry and SVG image comparisons')
