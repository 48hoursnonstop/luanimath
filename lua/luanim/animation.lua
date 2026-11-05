local U=require('luanim.util')
local V=require('luanim.vector')
local C=require('luanim.color')
local B=require('luanim.bezier')
local R=require('luanim.rate_functions')
local A={}
local Animation={};Animation.__index=Animation

local function new(kind,mobject,opts)
    opts=opts or {};assert(mobject and mobject.get_family,'animation requires a Mobject')
    local self=setmetatable({kind=kind,is_animation=true,mobject=mobject,opts=opts,
        run_time=opts.run_time or 1,rate_func=opts.rate_func or R.smooth,
        lag_ratio=opts.lag_ratio or (kind=='Create' and 1 or 0)},Animation)
    U.number(self.run_time,'run_time');assert(self.run_time>=0,'run_time must be nonnegative')
    U.number(self.lag_ratio,'lag_ratio');assert(self.lag_ratio>=0,'lag_ratio must be nonnegative')
    assert(type(self.rate_func)=='function','rate_func must be callable')
    return self
end

local function align(a,b)
    assert(#a.submobjects==#b.submobjects,'Transform between different family structures is not implemented')
    if #a.points~=#b.points then
        assert(a.is_vector and b.is_vector and #a.points>0 and #b.points>0,'Transform requires compatible points')
        local n=math.max(#a.points,#b.points)/4
        a.points=B.remap(a.points,n);b.points=B.remap(b.points,n)
    end
    for i,child in ipairs(a.submobjects) do align(child,b.submobjects[i]) end
end

local function interpolate(m,a,b,t)
    assert(#a.points==#b.points,'unaligned point arrays')
    local points={};for i,p in ipairs(a.points) do points[i]=V.lerp(p,b.points[i],t) end
    m.points=points;m.fill_color=C.interpolate(a.fill_color,b.fill_color,t)
    m.stroke_color=C.interpolate(a.stroke_color,b.stroke_color,t)
    m.stroke_width=a.stroke_width*(1-t)+b.stroke_width*t
end

function Animation:begin(scene)
    assert(not self.started,'animation instances cannot be reused')
    self.started=true;self.scene=scene
    self.starting_mobject=self.mobject:copy()
    if self.kind=='Transform' or self.kind=='ReplacementTransform' then
        self.target_copy=self.target_mobject:copy()
        align(self.starting_mobject,self.target_copy)
        self.mobject:become(self.starting_mobject)
    elseif self.kind=='FadeIn' or self.kind=='FadeOut' then
        local faded=self.starting_mobject:copy():fade(1)
        local shift=V(self.opts.shift or {})
        if self.opts.target_position then
            local p=self.opts.target_position
            shift=(p.get_center and p:get_center() or V(p))-self.starting_mobject:get_center()
        elseif self.kind=='FadeIn' then shift=-shift end
        faded:shift(shift):scale(self.opts.scale or 1)
        self.target_copy=self.kind=='FadeIn' and self.starting_mobject:copy() or faded
        if self.kind=='FadeIn' then self.starting_mobject=faded end
    elseif self.kind=='Rotate' then
        self.about_point=self.opts.about_point and V(self.opts.about_point) or self.starting_mobject:get_center()
    elseif self.kind=='Write' or self.kind=='DrawBorderThenFill' then
        self.outline=self.starting_mobject:copy():set_fill(nil,0)
        for _,m in ipairs(self.outline:family_members_with_points()) do
            local color=self.opts.stroke_color or (m.stroke_width>0 and m.stroke_color or m.fill_color)
            m:set_stroke(color,self.opts.stroke_width or 2,nil,{family=false})
        end
    end
    if scene then scene:add(self.mobject) end
    self.saved_suspension={}
    if self.opts.suspend_mobject_updating~=false then
        for _,m in ipairs(self.mobject:get_family()) do self.saved_suspension[m]=m.updating_suspended;m.updating_suspended=true end
    end
    self:interpolate(0)
    return self
end
function Animation:interpolate(alpha)
    assert(self.started,'animation must begin before interpolation')
    U.number(alpha,'alpha');alpha=U.clamp(alpha)
    local family=self.mobject:family_members_with_points()
    -- Create at alpha=0 still retains a degenerate curve; select the original family.
    local originals=self.starting_mobject:family_members_with_points()
    if #family~=#originals then family=self.mobject:get_family();originals=self.starting_mobject:get_family() end
    local targets=self.target_copy and self.target_copy:family_members_with_points()
    local outlines=self.outline and self.outline:family_members_with_points()
    local n=#originals;local full=(n-1)*self.lag_ratio+1
    for i,src in ipairs(originals) do
        local t=self.rate_func(U.clamp(alpha*full-(i-1)*self.lag_ratio))
        local m=family[i]
        if self.kind=='Create' then m:pointwise_become_partial(src,0,t)
        elseif outlines then
            local outline=outlines[i]
            if t<0.5 then
                m:pointwise_become_partial(outline,0,2*t)
                m.fill_color=U.copy(outline.fill_color);m.stroke_color=U.copy(outline.stroke_color);m.stroke_width=outline.stroke_width
            else interpolate(m,outline,src,2*t-1) end
        elseif self.kind=='Rotate' then
            m.points=U.copy(src.points)
            local p=self.about_point;local axis=self.opts.axis or V(0,0,1)
            for j,v in ipairs(m.points) do m.points[j]=p+V.rotate(v-p,self.angle*t,axis) end
        elseif self.kind=='MoveAlongPath' then
            local p=self.path:point_from_proportion(t)
            m:become(src):move_to(p)
        elseif self.target_copy then interpolate(m,src,targets[i],t)
        end
    end
    return self
end
function Animation:finish()
    if self.finished then return self end
    self:interpolate(1);self.finished=true
    for m,previous in pairs(self.saved_suspension) do m.updating_suspended=previous end
    if self.scene then
        if self.kind=='FadeOut' then self.scene:remove(self.mobject);self.mobject:become(self.starting_mobject)
        elseif self.kind=='ReplacementTransform' then self.scene:replace(self.mobject,self.target_mobject) end
    end
    return self
end
for _,kind in ipairs({'Animation','Create','FadeIn','FadeOut'}) do
    A[kind]=function(m,opts)
        if kind=='Create' then assert(m and m.is_vector,'Create requires VMobject') end
        return new(kind,m,opts)
    end
end
function A.Transform(m,target,opts)
    opts=opts or {};assert(not opts.path_arc or opts.path_arc==0,'Transform path_arc is not implemented')
    assert(target and target.get_family,'target must be a Mobject')
    local a=new('Transform',m,opts);a.target_mobject=target;return a
end
function A.ReplacementTransform(m,target,opts) local a=A.Transform(m,target,opts);a.kind='ReplacementTransform';return a end
function A.Rotate(m,angle,opts) local a=new('Rotate',m,opts);a.angle=U.number(angle or math.pi,'angle');return a end
function A.MoveAlongPath(m,path,opts)
    assert(path and path.is_vector and #path.points>0,'MoveAlongPath requires a nonempty VMobject path')
    local a=new('MoveAlongPath',m,opts);a.path=path;return a
end
function A.DrawBorderThenFill(m,opts)
    assert(m and m.is_vector,'DrawBorderThenFill requires VMobject')
    return new('DrawBorderThenFill',m,U.merge({run_time=2,rate_func=R.double_smooth},opts))
end
function A.Write(m,opts)
    opts=opts or {};assert(m and m.is_vector,'Write requires VMobject')
    assert(not opts.reverse,'reverse Write is not implemented')
    local n=#m:family_members_with_points()
    return new('Write',m,U.merge({run_time=n<15 and 1 or 2,lag_ratio=math.min(4/math.max(1,n),0.2),rate_func=R.linear},opts))
end

local Composition={};Composition.__index=Composition
local function composition(kind,animations,opts)
    opts=opts or {};assert(type(animations)=='table' and #animations>0,'composition requires animations')
    local lag=opts.lag_ratio or (kind=='Succession' and 1 or kind=='LaggedStart' and 0.05 or 0)
    U.number(lag,'lag_ratio');assert(lag>=0,'lag_ratio must be nonnegative')
    local self=setmetatable({kind=kind,is_animation=true,animations=animations,timings={},
        rate_func=opts.rate_func or R.linear,started=false},Composition)
    local start,maximum=0,0
    for i,a in ipairs(animations) do
        assert(a.is_animation,'composition child must be an animation')
        local finish=start+a.run_time
        self.timings[i]={start,finish};maximum=math.max(maximum,finish);start=start+lag*a.run_time
    end
    self.natural_duration=maximum;self.run_time=opts.run_time or maximum
    U.number(self.run_time,'run_time');assert(self.run_time>=0,'run_time must be nonnegative')
    return self
end
for _,kind in ipairs({'AnimationGroup','Succession','LaggedStart'}) do A[kind]=function(a,opts) return composition(kind,a,opts) end end
function Composition:begin(scene)
    assert(not self.started,'animation instances cannot be reused');self.started=true;self.scene=scene
    self:interpolate(0);return self
end
function Composition:interpolate(alpha)
    local t=self.rate_func(U.clamp(alpha))*self.natural_duration
    for i,a in ipairs(self.animations) do
        local start,finish=table.unpack(self.timings[i])
        if t>=start then
            if not a.started then a:begin(self.scene) end
            if not a.finished then
                a:interpolate(finish==start and 1 or U.clamp((t-start)/(finish-start)))
                if t>=finish then a:finish() end
            end
        end
    end
    return self
end
function Composition:finish()
    if self.finished then return self end
    self:interpolate(1);self.finished=true;return self
end

function A.builder(m,opts)
    local target=m:copy()
    local builder={is_builder=true,mobject=m,target=target,opts=opts or {}}
    function builder:build() return A.Transform(self.mobject,self.target,self.opts) end
    return setmetatable(builder,{__index=function(_,key)
        assert(type(target[key])=='function','unknown animation builder method: '..tostring(key))
        return function(self,...) target[key](target,...);return self end
    end})
end
return A
