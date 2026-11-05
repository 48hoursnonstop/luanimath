local l=require('luanim')
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
print('PASS: PNG, MP4, GIF and WebM exported through the real Lua scene engine')
