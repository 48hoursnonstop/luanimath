local l=require('luanimath')

return l.Scene(function(s)
    local equation=l.MathTypst('{{ a^2+b^2 : lhs }} = {{ c^2 }}',{
        font_size=90,track_baselines=true
    }):shift(l.UP)
    equation:select('lhs'):set_color(l.BLUE)
    equation:select(1):set_color(l.YELLOW)
    local fraction=l.MathTypst('sum_(k=1)^n k = frac(n(n+1),2)',{
        font_size=64
    }):shift(1.2*l.DOWN)
    s:play(l.Write(equation),{run_time=1})
    s:play(l.Write(fraction),{run_time=1})
    s:play(equation:animate():rotate(.1),{run_time=.5})
    s:wait(.5)
end)
