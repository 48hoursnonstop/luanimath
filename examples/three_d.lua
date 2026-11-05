local l=require('luanim')
return l.ThreeDScene(function(s)
    s:set_camera_orientation{phi=1.05,theta=-.8,zoom=1.1}
    local title=l.Text('Luanim · cámara y geometría 3D',{font='Liberation Sans',font_size=42}):shift(3*l.UP)
    local cube=l.Cube{side_length=1.7,fill_opacity=.75}:shift(1.8*l.LEFT)
    local sphere=l.Sphere{radius=1,resolution={16,10}}:shift(1.8*l.RIGHT)
    s:add(cube,sphere);s:add_fixed_in_frame_mobjects(title)
    s:play(l.Rotate(cube,l.PI/2,{axis=l.vec(1,1,1)}),{run_time=1.5})
    s:move_camera{theta=.5,phi=.8,run_time=1.5}
    s:wait(.5)
end)
