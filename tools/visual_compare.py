"""Development-only image/video validation, never used by the Lua runtime."""
import json
import subprocess
from pathlib import Path

import numpy as np
from PIL import Image

root=Path(__file__).resolve().parents[1]
results=[]
for path in sorted((root/'tests/reference_images').glob('*.png')):
    actual=root/'artifacts/luanim'/path.name
    a=np.asarray(Image.open(path).convert('RGBA')).astype(float)
    b=np.asarray(Image.open(actual).convert('RGBA')).astype(float)
    assert a.shape==b.shape,(path.name,a.shape,b.shape)
    diff=np.abs(a-b)
    # Same geometry and Cairo, but rounding of cubic controls can change edge pixels.
    mae=float(diff.mean());fraction=float(np.any(diff>16,axis=2).mean())
    assert mae<=0.6 and fraction<=0.004,(path.name,mae,fraction)
    results.append(dict(frame=path.name,mean_absolute_channel_error=mae,pixel_fraction_error_over_16=fraction))
assert len(results)>=48,'expected complete reference frame set'
for name in ['artifacts/geometric.mp4']:
    path=root/name
    if not path.exists():continue
    data=json.loads(subprocess.check_output(['ffprobe','-v','error','-count_frames','-select_streams','v:0','-show_entries','stream=width,height,nb_read_frames,r_frame_rate,duration','-of','json',str(path)]))
    stream=data['streams'][0]
    assert (stream['width'],stream['height'],int(stream['nb_read_frames']))==(640,360,108),stream
    subprocess.run(['ffmpeg','-v','error','-i',str(path),'-f','null','-'],check=True)
    print('Video decoded:',json.dumps(stream))
with Image.open(root/'artifacts/tests/native.png') as image:
    image.load();assert image.size==(64,64)
    assert np.asarray(image.convert('RGBA'))[:,:,3].min()==0
(root/'artifacts/visual_results.json').write_text(json.dumps(results,indent=2)+'\n')
print(f'PASS: {len(results)} reference image comparisons; maximum MAE {max(r["mean_absolute_channel_error"] for r in results):.6g}')
