from pathlib import Path
import json
import numpy as np
from PIL import Image
root=Path(__file__).resolve().parents[1]
results=[]
for path in sorted((root/'tests/reference_three_d_images').glob('*.png')):
    a=np.asarray(Image.open(path).convert('RGBA')).astype(float)
    b=np.asarray(Image.open(root/'artifacts/three-d'/path.name).convert('RGBA')).astype(float)
    assert a.shape==b.shape
    diff=np.abs(a-b);mae=float(diff.mean());fraction=float(np.any(diff>16,axis=2).mean())
    print(path.name,'MAE',mae,'fraction>16',fraction)
    assert mae<=0.6 and fraction<=0.004,(path.name,mae,fraction)
    results.append(dict(image=path.name,mae=mae,fraction_over_16=fraction))
assert len(results)==7
(root/'artifacts/three-d/results.json').write_text(json.dumps(results,indent=2)+'\n')
print('PASS: 7 real moving-camera/3D images')
