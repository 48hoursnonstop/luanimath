local U=require('luanim.util')
local C=require('luanim.color')
local M={defaults={pixel_width=854,pixel_height=480,frame_height=8,frame_rate=30,background_color=C.BLACK,background_opacity=1}}
function M.resolve(opts)
    local c=U.merge(M.defaults,opts)
    U.integer(c.pixel_width,'pixel_width',1);U.integer(c.pixel_height,'pixel_height',1)
    U.number(c.frame_height,'frame_height');assert(c.frame_height>0,'frame_height must be positive')
    c.frame_width=c.frame_width or c.frame_height*c.pixel_width/c.pixel_height
    U.number(c.frame_width,'frame_width');assert(c.frame_width>0,'frame_width must be positive')
    U.number(c.frame_rate,'frame_rate');assert(c.frame_rate>0 and c.frame_rate<=1000,'frame_rate outside (0,1000]')
    c.background_rgba=C.parse(c.background_color,c.background_opacity)
    return c
end
return M
