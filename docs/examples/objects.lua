local l=require('luanimath')

return l.Scene(function(s)
    local shapes=l.VGroup(
        l.Circle{fill_opacity=.4},
        l.Square{color=l.BLUE,fill_opacity=.4},
        l.Triangle{color=l.GREEN,fill_opacity=.4}
    ):arrange(l.RIGHT,{buff=.8})
    shapes:slice(2,3):shift(.35*l.UP)
    s:play(l.Create(shapes),{run_time=1})
    s:wait(.5)
end)
