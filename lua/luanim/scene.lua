local U=require('luanim.util')
local V=require('luanim.vector')
local Config=require('luanim.config')
local Renderer=require('luanim.renderer')
local A=require('luanim.animation')
local Cameras=require('luanim.camera')
local Scene={};Scene.__index=Scene
function Scene.new(construct,opts)
    assert(type(construct)=='function','Scene requires a construct function')
    return setmetatable({construct=construct,raw_config=U.copy(opts or {}),config=Config.resolve(opts),mobjects={},time=0,frame_count=0,
        camera=opts and opts.camera or Cameras.Camera(opts)},Scene)
end
function Scene:add(...)
    for _,m in ipairs({...}) do
        assert(m.get_family,'Scene.add requires Mobject')
        self:remove(m);self.mobjects[#self.mobjects+1]=m
    end
    return self
end
function Scene:remove(...)
    local removed={};for _,m in ipairs({...}) do for _,child in ipairs(m:get_family()) do removed[child]=true end end
    local result={}
    local function collect(m)
        if removed[m] then return end
        local affected=false
        for _,child in ipairs(m:get_family()) do if removed[child] then affected=true;break end end
        if affected then for _,child in ipairs(m.submobjects) do collect(child) end else result[#result+1]=m end
    end
    for _,m in ipairs(self.mobjects) do collect(m) end
    self.mobjects=result;return self
end
function Scene:replace(old,new)
    for i,m in ipairs(self.mobjects) do
        if m==old then self.mobjects[i]=new;return self end
        local function find(parent)
            for j,child in ipairs(parent.submobjects) do
                if child==old then parent.submobjects[j]=new;return true elseif find(child) then return true end
            end
        end
        if find(m) then return self end
    end
    error('replacement Mobject is not in the scene')
end
function Scene:update_mobjects(dt)
    local seen={}
    local function update(m)
        if seen[m] or m.updating_suspended then return end
        seen[m]=true
        for _,fn in ipairs(m.updaters) do fn(m,dt) end
        for _,child in ipairs(m.submobjects) do update(child) end
    end
    for _,m in ipairs(self.mobjects) do update(m) end
end
function Scene:_frame()
    if self.renderer then self.renderer:render(self.mobjects,('%s/frame_%06d.png'):format(self.frame_dir,self.frame_count)) end
    if self.on_frame then self.on_frame(self,self.frame_count) end
    self.frame_count=self.frame_count+1
end
function Scene:play(...)
    local args={...};local opts={}
    if #args>0 and not args[#args].is_animation and not args[#args].is_builder then opts=table.remove(args) end
    assert(#args>0,'Scene.play requires at least one animation')
    for i,a in ipairs(args) do
        if a.is_builder then args[i]=a:build() end
        assert(args[i].is_animation,'Scene.play expected an animation')
        if opts.run_time~=nil then args[i].run_time=U.number(opts.run_time,'run_time');assert(opts.run_time>=0,'run_time must be nonnegative') end
        if opts.rate_func then assert(type(opts.rate_func)=='function','rate_func must be callable');args[i].rate_func=opts.rate_func end
    end
    local group=A.AnimationGroup(args,{lag_ratio=opts.lag_ratio or 0})
    local start=self.time;group:begin(self)
    local n=math.ceil(group.run_time*self.config.frame_rate-1e-10)
    local last=0
    for frame=0,n-1 do
        local t=frame/self.config.frame_rate
        group:update_mobjects(t-last)
        group:interpolate(group.run_time==0 and 1 or t/group.run_time)
        self.time=start+t;self:update_mobjects(t-last);self:_frame();last=t
    end
    group:finish();self.time=start+group.run_time
    self:update_mobjects(0)
    return self
end
function Scene:wait(duration)
    duration=duration==nil and 1 or U.number(duration,'duration');assert(duration>=0,'duration must be nonnegative')
    local start=self.time;local n=math.ceil(duration*self.config.frame_rate-1e-10);local last=0
    for frame=0,n-1 do
        local t=frame/self.config.frame_rate;self.time=start+t;self:update_mobjects(t-last);self:_frame();last=t
    end
    self.time=start+duration;return self
end
function Scene:render(opts)
    opts=opts or {};local config=Config.resolve(U.merge(self.raw_config,opts))
    local output=opts.output or 'artifacts/scene.mp4'
    local directory=output:match('^(.*)/[^/]+$') or '.';U.mkdir(directory)
    -- mktemp avoids colliding with earlier renderings or deleting a user directory.
    local handle=assert(io.popen('mktemp -d '..U.shell_quote(directory..'/.luanim-frames-XXXXXX'),'r'))
    self.frame_dir=assert(handle:read('*l'));assert(handle:close(),'cannot create frame directory')
    self.config=config;self.mobjects={};self.time=0;self.frame_count=0
    if opts.frame_width then self.camera.frame:stretch(opts.frame_width/self.camera.frame:get_width(),1) end
    if opts.frame_height then self.camera.frame:stretch(opts.frame_height/self.camera.frame:get_height(),2) end
    if opts.frame_center then
        local frame=self.camera.kind=='ThreeDCamera' and self.camera._frame_center or self.camera.frame
        frame:move_to(V(opts.frame_center))
    end
    self.renderer=Renderer(config,self.camera)
    local ok,err=xpcall(function()
        self:construct()
        if self.frame_count==0 then self:_frame() end
        local last=output:match('%.png$') and output or (opts.last_frame or output:gsub('%.[^/.]+$','')..'.png')
        self.renderer:render(self.mobjects,last)
        if not output:match('%.png$') then Renderer.encode(self.frame_dir,output,config.frame_rate) end
    end,debug.traceback)
    self.renderer:close();self.renderer=nil
    if ok and not opts.keep_frames then U.command({'rm','-rf','--',self.frame_dir}) end
    if not ok then error(err,0) end
    return {output=output,frame_count=self.frame_count,duration=self.frame_count/config.frame_rate,
        scene_time=self.time,frame_dir=opts.keep_frames and self.frame_dir or nil}
end
function Scene:set_camera_orientation(opts)
    assert(self.camera.kind=='ThreeDCamera','camera orientation requires ThreeDScene');opts=opts or {}
    for _,name in ipairs({'phi','theta','gamma','zoom','focal_distance'}) do if opts[name]~=nil then self.camera['set_'..name](self.camera,opts[name]) end end
    if opts.frame_center then self.camera._frame_center:move_to(V(opts.frame_center)) end
    return self
end
function Scene:move_camera(opts)
    assert(self.camera.kind=='ThreeDCamera','move_camera requires ThreeDScene');opts=opts or {}
    local animations={}
    for _,name in ipairs({'phi','theta','gamma','zoom','focal_distance'}) do
        if opts[name]~=nil then animations[#animations+1]=self.camera[name..'_tracker']:animate():set_value(opts[name]) end
    end
    if opts.frame_center then animations[#animations+1]=self.camera._frame_center:animate():move_to(opts.frame_center) end
    assert(#animations>0,'move_camera requires a target camera parameter')
    animations[#animations+1]={run_time=opts.run_time or 1,rate_func=opts.rate_func}
    return self:play(table.unpack(animations))
end
function Scene:add_fixed_in_frame_mobjects(...)
    self:add(...);self.camera:add_fixed_in_frame_mobjects(...);return self
end
return setmetatable(Scene,{__call=function(_,...) return Scene.new(...) end})
