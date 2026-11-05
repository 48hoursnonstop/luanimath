"""Verify actual media, including transparency and motion; development-only."""
import json
import subprocess
from pathlib import Path
import numpy as np
from PIL import Image

root=Path(__file__).resolve().parents[1]
media=root/'artifacts/media'
with Image.open(media/'frame-options.png') as image:
    a=np.asarray(image.convert('RGB'))
    yy,xx=np.where((a[:,:,0]>100)&(a[:,:,1]<100)&(a[:,:,2]<100))
    assert len(xx)>0 and abs(float(xx.mean())-31.5)<.1 and abs(float(yy.mean())-31.5)<.1
with Image.open(media/'motion.png') as image:
    a=np.asarray(image.convert('RGBA'));assert image.size==(160,90)
    assert a[:,:,3].min()==0 and a[:,:,3].max()==255
    yy,xx=np.where(a[:,:,3]>128);assert xx.mean()>80
for ext in ['mp4','gif','webm']:
    path=media/f'motion.{ext}'
    report=json.loads(subprocess.check_output(['ffprobe','-v','error','-count_frames','-select_streams','v:0',
        '-show_entries','stream=width,height,nb_read_frames,pix_fmt','-of','json',str(path)]))['streams'][0]
    assert (report['width'],report['height'],int(report['nb_read_frames']))==(160,90,5),report
    raw=subprocess.check_output(['ffmpeg','-v','error','-i',str(path),'-f','rawvideo','-pix_fmt','rgb24','-'])
    frames=np.frombuffer(raw,dtype=np.uint8).reshape(5,90,160,3)
    centers=[]
    for frame in frames:
        yy,xx=np.where((frame[:,:,0]>100)&(frame[:,:,1]>100)&(frame[:,:,2]<100))
        assert len(xx)>0
        centers.append(float(xx.mean()))
    assert all(b>a for a,b in zip(centers,centers[1:])),(ext,centers)
    print(ext,report,'motion centers',centers)
with Image.open(media/'motion.gif') as image:
    assert image.n_frames==5
print('PASS: real decode, 5-frame motion and image transparency')
