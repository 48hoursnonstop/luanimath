local l=require('luanimath')
local function create()
    return l.Scene(function(s)
        local dot=l.Dot(l.LEFT,{radius=0.3,color=l.YELLOW})
        s:add(dot);s:play(dot:animate():shift(2*l.RIGHT),{run_time=0.5,rate_func=l.linear})
    end,{pixel_width=160,pixel_height=90,frame_rate=10,background_opacity=0})
end
for _,ext in ipairs({'png','mp4','gif','webm'}) do
    local report=create():render{output='artifacts/media/motion.'..ext}
    assert(report.frame_count==5)
end
local framed=l.Scene(function(s) s:add(l.Dot(l.RIGHT,{radius=.25,color=l.RED})) end)
framed:render{output='artifacts/media/frame-options.png',pixel_width=64,pixel_height=64,
    frame_width=4,frame_height=4,frame_center={1,0,0}}
print('PASS: PNG, MP4, GIF and WebM exported through the real Lua scene engine')
