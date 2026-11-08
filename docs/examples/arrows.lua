local l=require('luanimath')

return l.ThreeDScene(function(s)
    s:set_camera_orientation{phi=65*l.DEGREES,theta=135*l.DEGREES}
    local first=l.Arrow({-3,0,0},{-1,1,2},{color=l.BLUE,buff=0})
    local second=l.Arrow({0,-1,0},{3,0,0},{color=l.GOLD,buff=0})
    s:play(l.GrowArrow(first),l.GrowArrow(second),{run_time=1})
    s:play(l.ScaleInPlace(first,.6),l.ApplyMethod(second,'scale',{1.3,{scale_tips=true}}),{run_time=1})
    s:move_camera{theta=155*l.DEGREES,run_time=.5}
    s:wait(.5)
end)
