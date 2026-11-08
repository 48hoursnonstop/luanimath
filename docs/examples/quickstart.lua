local l=require('luanimath')

return l.Scene(function(s)
    local square=l.Square{color=l.BLUE,fill_opacity=.35}
    s:play(l.Create(square),{run_time=1})
    s:play(square:animate():shift(2*l.RIGHT):rotate(l.PI/4),{run_time=1})
    s:wait(.5)
end)
