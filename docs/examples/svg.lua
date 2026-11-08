local l=require('luanimath')

return l.Scene(function(s)
    local imported=l.SVGMobject('tests/svg_assets/use.svg',{
        height=2.5,fill_color=l.BLUE
    }):shift(2*l.LEFT)
    local path=l.VMobjectFromSVGPath('M0 0 C1 2 3 -1 4 1',{
        color=l.YELLOW,stroke_width=6
    }):move_to(2.5*l.RIGHT)
    s:play(l.Write(imported),l.Create(path),{run_time=1.5})
    s:wait(.5)
end)
