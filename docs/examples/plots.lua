local l=require('luanimath')

return l.Scene(function(s)
    local axes=l.Axes{x_range={-3,3,1},y_range={-1.5,1.5,.5},x_length=9,y_length=4}
    local graph=axes:plot(math.sin,{x_range={-3,3,.05},color=l.BLUE})
    local tracker=l.ValueTracker(-3)
    local dot=l.always_redraw(function()
        local x=tracker:get_value()
        return l.Dot(axes:coords_to_point(x,math.sin(x)),{color=l.YELLOW,radius=.1})
    end)
    s:add(axes,graph,dot)
    s:play(tracker:animate():set_value(2),{run_time=2,rate_func=l.linear})
    s:wait(.5)
end)
