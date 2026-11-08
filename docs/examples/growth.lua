local l=require('luanimath')

return l.Scene(function(s)
    local title=l.Text('Grow in Lua',{font='Noto Sans',font_size=42}):shift(l.UP*2.2)
    local left=l.Square{side_length=1.5,color=l.BLUE,fill_opacity=.3}:shift(l.LEFT*3)
    local center=l.Circle{radius=.8,color=l.TEAL,fill_opacity=.3}
    local right=l.RoundedRectangle{width=2,height=1.2,corner_radius=.2,color=l.GOLD,fill_opacity=.3}:shift(l.RIGHT*3)
    s:play(l.GrowFromPoint(title,l.DOWN*2,{point_color=l.PURPLE}),{run_time=.75})
    s:play(l.GrowFromEdge(left,l.LEFT),l.GrowFromCenter(center),l.SpinInFromNothing(right,{angle=l.TAU}),{run_time=1.5})
    s:wait(.75)
end)
