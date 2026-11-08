local l=require('luanimath')

return l.Scene(function(s)
    local path=l.VMobject{color=l.BLUE,stroke_width=6}
        :start_new_path(l.vec(-3,-1))
        :add_cubic_bezier_curve_to(l.vec(-2,3),l.vec(1,-3),l.vec(3,1))
    local dot=l.Dot(path:get_start(),{color=l.YELLOW,radius=.12})
    s:play(l.Create(path),{run_time=1})
    s:play(l.MoveAlongPath(dot,path,{rate_func=l.linear}),{run_time=1})
    s:wait(.5)
end)
