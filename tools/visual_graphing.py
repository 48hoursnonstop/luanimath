from pathlib import Path
import numpy as np
from PIL import Image
root=Path(__file__).resolve().parents[1]
a=np.asarray(Image.open(root/'tests/reference_graphing_images/axes_sine.png').convert('RGBA')).astype(float)
b=np.asarray(Image.open(root/'artifacts/graphing/axes_sine.png').convert('RGBA')).astype(float)
d=np.abs(a-b);mae=float(d.mean());fraction=float(np.any(d>16,axis=2).mean())
assert mae<=0.6 and fraction<=0.004,(mae,fraction)
print('PASS: real axes/sine visual comparison, MAE',mae,'fraction>16',fraction)
