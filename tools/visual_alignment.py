from pathlib import Path
import numpy as np
from PIL import Image
root=Path(__file__).resolve().parents[1]
results=[]
for path in sorted((root/'tests/reference_alignment_images').glob('*.png')):
    a=np.asarray(Image.open(path).convert('RGBA')).astype(float)
    b=np.asarray(Image.open(root/'artifacts/alignment'/path.name).convert('RGBA')).astype(float)
    assert a.shape==b.shape
    d=np.abs(a-b);mae=float(d.mean());fraction=float(np.any(d>16,axis=2).mean())
    assert mae<=0.6 and fraction<=0.004,(path.name,mae,fraction)
    results.append(mae)
assert len(results)==30
print('PASS: 30 family/subpath visual comparisons; maximum MAE',max(results))
