import json
import subprocess
from pathlib import Path
import numpy as np

root=Path(__file__).resolve().parents[1]
path=root/'artifacts/markup.mp4'
data=json.loads(subprocess.check_output(['ffprobe','-v','error','-count_frames','-select_streams','v:0',
    '-show_entries','stream=width,height,nb_read_frames,r_frame_rate,duration','-of','json',str(path)]))['streams'][0]
assert (data['width'],data['height'],int(data['nb_read_frames']))==(640,360,108),data
assert data['r_frame_rate']=='24/1'
subprocess.run(['ffmpeg','-v','error','-i',str(path),'-f','null','-'],check=True)
raw=subprocess.check_output(['ffmpeg','-v','error','-i',str(path),'-vf',r'select=eq(n\,12)+eq(n\,60)+eq(n\,107)',
    '-fps_mode','passthrough','-f','rawvideo','-pix_fmt','rgb24','-'])
frames=np.frombuffer(raw,dtype=np.uint8).reshape(3,360,640,3).astype(float)
changes=[float(np.abs(frames[i+1]-frames[i]).mean()) for i in range(2)]
assert all(value>1 for value in changes),changes
assert frames[1,100:320].mean()>frames[2,100:320].mean()+1,'Unwrite must erase both text objects'
print('PASS: markup video fully decoded,',data,'frame changes',changes)
