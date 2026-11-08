local l=require('luanimath')

return l.Scene(function(s)
    local ax=l.Axes{
        x_range={0,4,1},y_range={-1,3,1},x_length=8,y_length=4.5,
        y_axis_config={scaling=l.LogBase{base=2}}
    }
    local labels=l.VGroup()
    for exponent=-1,3 do
        local label=l.MathTypst('2^('..exponent..')',{font_size=30})
        label:next_to(ax.y_axis:n2p(2^exponent),l.LEFT,{buff=.2})
        labels:add(label)
    end
    local graph=ax:plot(function(x) return 2^(x/2) end,{x_range={0,4,.1},color=l.BLUE})
    local t=l.ValueTracker(0)
    local dot=l.always_redraw(function() return l.Dot(ax:c2p(t:get_value(),2^(t:get_value()/2)),{color=l.YELLOW}) end)
    s:play(l.Create(ax),l.Write(labels),{run_time=.5})
    s:play(l.Create(graph),{run_time=1})
    s:add(dot);s:play(t:animate():set_value(4),{run_time=1})
    s:wait(.5)
end)
