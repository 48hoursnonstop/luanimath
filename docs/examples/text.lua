local l=require('luanimath')

return l.Scene(function(s)
    local rich=l.MarkupText('<b>luanimath</b> <span foreground="#58c4dd"><i>in Lua</i></span>',
        {font='Liberation Sans',font_size=64}):shift(.8*l.UP)
    local text=l.Text('geometry in motion',{
        font='Noto Sans',font_size=54,gradient={l.BLUE,l.GREEN},t2w={motion=l.BOLD}
    }):shift(.8*l.DOWN)
    s:play(l.Write(rich),l.Write(text),{run_time=1.5})
    s:wait(.5)
end)
