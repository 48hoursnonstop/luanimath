local l=require('luanimath')

return l.ThreeDScene(function(s)
    s:set_camera_orientation{phi=65*l.DEGREES,theta=-45*l.DEGREES}
    local cube=l.Cube{side_length=1.8}:shift(1.8*l.LEFT)
    local sphere=l.Sphere{radius=1,resolution={16,8}}:shift(1.8*l.RIGHT)
    s:add(cube,sphere)
    s:move_camera{theta=-25*l.DEGREES,run_time=1}
    s:wait(.5)
end)
