local Native=require('luanim_native')
local U=require('luanim.util')
local Config=require('luanim.config')
local V=require('luanim.vector')
local Renderer={};Renderer.__index=Renderer
function Renderer.new(opts)
    local config=Config.resolve(opts);local center=V(config.frame_center or {})
    return setmetatable({config=config,surface=Native.surface(config.pixel_width,config.pixel_height,
        config.frame_width,config.frame_height,center[1],center[2])},Renderer)
end
function Renderer:render(mobjects,path)
    self.surface:clear(self.config.background_rgba)
    local family,seen={},{}
    for _,m in ipairs(mobjects) do
        for _,child in ipairs(m:get_family()) do
            if child.is_vector and #child.points>0 and not seen[child] then
                seen[child]=true;family[#family+1]={m=child,order=#family+1}
            end
        end
    end
    table.sort(family,function(a,b) if a.m.z_index==b.m.z_index then return a.order<b.order end;return a.m.z_index<b.m.z_index end)
    for _,item in ipairs(family) do
        local m=item.m
        self.surface:draw(m.points,m.fill_color,m.stroke_color,m.stroke_width,m.joint_type,m.cap_style)
    end
    if path then self.surface:write_png(path) end
    return self
end
function Renderer:close() self.surface:close() end
function Renderer.encode(frame_dir,output,fps)
    local ext=output:match('%.([^./]+)$')
    assert(ext=='mp4' or ext=='gif' or ext=='webm','output format must be mp4, gif, png, or webm')
    local args={'ffmpeg','-v','error','-y','-framerate',fps,'-start_number',0,'-i',frame_dir..'/frame_%06d.png'}
    local codec=ext=='mp4' and {'-c:v','libx264','-pix_fmt','yuv420p','-movflags','+faststart'}
        or ext=='webm' and {'-c:v','libvpx-vp9','-pix_fmt','yuva420p'} or {}
    for _,s in ipairs(codec) do args[#args+1]=s end
    args[#args+1]=output;U.command(args)
end
return setmetatable(Renderer,{__call=function(_,opts) return Renderer.new(opts) end})
