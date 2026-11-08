from pathlib import Path
import json
import numpy as np
from PIL import Image

root=Path(__file__).resolve().parents[1];results=[]
for i in range(1,4):
    name=f'scale_{i}.png'
    a=np.asarray(Image.open(root/'tests/reference_scales_images'/name).convert('RGBA')).astype(float)
    b=np.asarray(Image.open(root/'artifacts/scales'/name).convert('RGBA')).astype(float)
    assert a.shape==b.shape
    difference=np.abs(a-b);mae=float(difference.mean());fraction=float(np.any(difference>16,axis=2).mean())
    assert mae<=.6 and fraction<=.004,(name,mae,fraction)
    results.append(dict(image=name,mae=mae,fraction_over_16=fraction))
    print(name,'MAE',mae,'fraction>16',fraction)
(root/'artifacts/scales/results.json').write_text(json.dumps(results,indent=2)+'\n')
print('PASS: 3 real semilog/logarithmic axes and plot images')
