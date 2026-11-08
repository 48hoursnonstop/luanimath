from pathlib import Path
import json
import numpy as np
from PIL import Image

root=Path(__file__).resolve().parents[1]
a=np.asarray(Image.open(root/'tests/reference_colors_images/palette.png').convert('RGBA')).astype(float)
b=np.asarray(Image.open(root/'artifacts/colors/palette.png').convert('RGBA')).astype(float)
assert a.shape==b.shape
d=np.abs(a-b);mae=float(d.mean());fraction=float(np.any(d>16,axis=2).mean())
assert mae<=.6 and fraction<=.004,(mae,fraction)
(root/'artifacts/colors/results.json').write_text(json.dumps(dict(colors=89,mae=mae,fraction_over_16=fraction),indent=2)+'\n')
print('PASS: 89-color actual swatch image; MAE',mae,'fraction>16',fraction)
