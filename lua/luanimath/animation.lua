local U=require('luanimath.util')
local V=require('luanimath.vector')
local C=require('luanimath.color')
local R=require('luanimath.rate_functions')
local Paths=require('luanimath.paths')
local A={}
local Animation={};Animation.__index=Animation

local function new(kind,mobject,opts)
    opts=opts or {};assert(mobject and mobject.get_family,'animation requires a Mobject')
    local self=setmetatable({kind=kind,is_animation=true,mobject=mobject,opts=opts,
        run_time=opts.run_time or 1,rate_func=opts.rate_func or R.smooth,
        lag_ratio=opts.lag_ratio or (kind=='Create' and 1 or 0)},Animation)
    self.reverse_rate_function=not not opts.reverse_rate_function
    self.remover=opts.remover
    if self.remover==nil then self.remover=kind=='FadeOut' or kind=='Uncreate' end
    self.path_func=opts.path_func or (opts.path_arc_centers and Paths.path_along_circles(opts.path_arc or 0,opts.path_arc_centers,opts.path_arc_axis))
        or Paths.path_along_arc(opts.path_arc or 0,opts.path_arc_axis)
    assert(type(self.path_func)=='function','path_func must be callable')
    U.number(self.run_time,'run_time');assert(self.run_time>=0,'run_time must be nonnegative')
    U.number(self.lag_ratio,'lag_ratio');assert(self.lag_ratio>=0,'lag_ratio must be nonnegative')
    assert(type(self.rate_func)=='function','rate_func must be callable')
    return self
end

local function interpolate(m,a,b,t,path_func)
    assert(#a.points==#b.points,'unaligned point arrays')
    local points
    if path_func then
        points=path_func(a.points,b.points,t);assert(type(points)=='table' and #points==#a.points,'path_func returned an invalid point array')
        for i,p in ipairs(points) do points[i]=V(p) end
    else points={};for i,p in ipairs(a.points) do points[i]=V.lerp(p,b.points[i],t) end end
    m.points=points;m.fill_color=C.interpolate(a.fill_color,b.fill_color,t)
    m.stroke_color=C.interpolate(a.stroke_color,b.stroke_color,t)
    m.stroke_width=a.stroke_width*(1-t)+b.stroke_width*t
end

function Animation:begin(scene)
    assert(not self.started,'animation instances cannot be reused')
    self.started=true;self.scene=scene
    if self.reverse then self.mobject:invert({recursive=true}) end
    if self.is_transform then
        if self.target_builder then self.target_mobject=self.target_builder(self.mobject) end
        assert(self.target_mobject and self.target_mobject.get_family,'transform callback must return a Mobject')
        self.target_copy=self.target_mobject:copy()
        self.mobject:align_data(self.target_copy)
    end
    self.starting_mobject=self.mobject:copy()
    if self.growth_point then
        self.target_copy=self.mobject:copy()
        if self.grow_arrow then self.starting_mobject:scale(0,{scale_tips=true,about_point=self.growth_point})
        else self.starting_mobject:scale(0):move_to(self.growth_point) end
        if self.opts.point_color then self.starting_mobject:set_color(self.opts.point_color) end
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
    elseif self.kind=='Write' or self.kind=='Unwrite' or self.kind=='DrawBorderThenFill' then
        self.outline=self.starting_mobject:copy():set_fill(nil,0)
        for _,m in ipairs(self.outline:family_members_with_points()) do
            local color=self.opts.stroke_color or (m.stroke_width>0 and m.stroke_color or m.fill_color)
            m:set_stroke(color,self.opts.stroke_width or 2,nil,{family=false})
        end
    end
    if scene then scene:add(self.mobject) end
    if self.opts.suspend_mobject_updating~=false then self.mobject:suspend_updating() end
    self:interpolate(0)
    return self
end
function Animation:interpolate(alpha)
    assert(self.started,'animation must begin before interpolation')
    U.number(alpha,'alpha');alpha=U.clamp(alpha)
    if self.kind=='MoveAlongPath' then self.mobject:move_to(self.path:point_from_proportion(self.rate_func(alpha)));return self end
    local family=self.mobject:family_members_with_points()
    -- Create at alpha=0 still retains a degenerate curve; select the original family.
    local originals=self.starting_mobject:family_members_with_points()
    if #family~=#originals then family=self.mobject:get_family();originals=self.starting_mobject:get_family() end
    local targets=self.target_copy and self.target_copy:family_members_with_points()
    local outlines=self.outline and self.outline:family_members_with_points()
    local n=#originals;local full=(n-1)*self.lag_ratio+1
    for i,src in ipairs(originals) do
        local subalpha=U.clamp(alpha*full-(i-1)*self.lag_ratio)
        local t=self.rate_func(self.reverse_rate_function and 1-subalpha or subalpha)
        local m=family[i]
        if self.kind=='Create' or self.kind=='Uncreate' then m:pointwise_become_partial(src,0,t)
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
        elseif self.target_copy then interpolate(m,src,targets[i],t,self.path_func)
        end
    end
    return self
end
function Animation:finish()
    if self.finished then return self end
    self:interpolate(1);self.finished=true
    if self.opts.suspend_mobject_updating~=false then self.mobject:resume_updating() end
    if self.scene then
        if self.remover then self.scene:remove(self.mobject) end
        if self.kind=='FadeOut' then self.mobject:become(self.starting_mobject)
        elseif self.kind=='ReplacementTransform' then self.scene:replace(self.mobject,self.target_mobject) end
    end
    if self.reverse then self.mobject:invert({recursive=true}) end
    return self
end
function Animation:update_mobjects(dt)
    if self.starting_mobject then self.starting_mobject:update(dt) end
    if self.target_mobject and self.target_mobject~=self.mobject then self.target_mobject:update(dt) end
    if self.target_copy and self.target_copy~=self.mobject then self.target_copy:update(dt) end
    return self
end
for _,kind in ipairs({'Animation','Create','FadeIn','FadeOut'}) do
    A[kind]=function(m,opts)
        if kind=='Create' then assert(m and m.is_vector,'Create requires VMobject') end
        if kind=='FadeOut' then assert(not opts or opts.remover==nil,'FadeOut always removes its subject; remover is not a supported option') end
        return new(kind,m,opts)
    end
end
function A.Transform(m,target,opts)
    opts=opts or {}
    assert(target and target.get_family,'target must be a Mobject')
    local a=new('Transform',m,opts);a.target_mobject=target;a.is_transform=true;return a
end
local function deferred_transform(kind,m,build,opts)
    local a=new(kind,m,opts);a.is_transform=true;a.target_builder=build;return a
end
function A.MoveToTarget(m,opts)
    local a=A.Transform(m,assert(m.target,'generate_target must be called before MoveToTarget'),opts)
    a.kind='MoveToTarget';return a
end
function A.ApplyMethod(m,method,args,opts)
    local fn=type(method)=='string' and m[method] or method
    assert(type(fn)=='function','ApplyMethod requires a method name or unbound Lua function')
    args=args or {};assert(type(args)=='table','method arguments must be a sequence')
    local count=U.integer(args.n or #args,'argument count',0);assert(count<=100000,'too many method arguments')
    return deferred_transform('ApplyMethod',m,function(subject)
        local target=subject:copy();fn(target,table.unpack(args,1,count));return target
    end,opts)
end
function A.ApplyFunction(fn,m,opts)
    assert(type(fn)=='function','ApplyFunction requires a callback')
    return deferred_transform('ApplyFunction',m,function(subject) return fn(subject:copy()) end,opts)
end
function A.ApplyPointwiseFunction(fn,m,opts)
    assert(type(fn)=='function','ApplyPointwiseFunction requires a point callback')
    local a=A.ApplyMethod(m,'apply_function',{fn},U.merge({run_time=3},opts));a.kind='ApplyPointwiseFunction';return a
end
function A.ApplyMatrix(matrix,m,opts)
    assert(type(matrix)=='table' and (#matrix==2 or #matrix==3),'matrix must be 2x2 or 3x3')
    local n=#matrix;matrix=U.copy(matrix)
    for _,row in ipairs(matrix) do assert(type(row)=='table' and #row==n,'matrix must be square');for _,value in ipairs(row) do U.number(value,'matrix entry') end end
    opts=opts or {};local origin=opts.about_point or V()
    local a=A.ApplyPointwiseFunction(function(point)
        local about=V(origin);local delta=point-about;local result=V(delta)
        for i=1,n do result[i]=0;for j=1,n do result[i]=result[i]+matrix[i][j]*delta[j] end end
        return about+result
    end,m,opts)
    a.kind='ApplyMatrix';return a
end
function A.FadeToColor(m,color,opts)
    local a=A.ApplyMethod(m,'set_color',{color},opts);a.kind='FadeToColor';return a
end
function A.ScaleInPlace(m,factor,opts)
    U.number(factor,'scale factor')
    local a=A.ApplyMethod(m,'scale',{factor},opts);a.kind='ScaleInPlace';return a
end
function A.ShrinkToCenter(m,opts) local a=A.ScaleInPlace(m,0,opts);a.kind='ShrinkToCenter';return a end
function A.Restore(m,opts) local a=A.ApplyMethod(m,'restore',{},opts);a.kind='Restore';return a end
function A.Uncreate(m,opts)
    assert(m and m.is_vector,'Uncreate requires VMobject')
    return new('Uncreate',m,U.merge({reverse_rate_function=true,remover=true,lag_ratio=1},opts))
end
function A.ReplacementTransform(m,target,opts) local a=A.Transform(m,target,opts);a.kind='ReplacementTransform';return a end
function A.Rotate(m,angle,opts) local a=new('Rotate',m,opts);a.angle=U.number(angle or math.pi,'angle');return a end
function A.MoveAlongPath(m,path,opts)
    assert(path and path.is_vector and #path.points>0,'MoveAlongPath requires a nonempty VMobject path')
    local a=new('MoveAlongPath',m,opts);a.path=path;return a
end
function A.GrowFromPoint(m,point,opts)
    assert(type(point)=='table','GrowFromPoint requires a point or Mobject');opts=opts or {}
    assert(opts.introducer==nil,'growth animations always introduce their subject; introducer is not a supported option')
    local a=new('GrowFromPoint',m,opts);a.growth_point=point;a.target_mobject=m;a.introducer=true;return a
end
function A.GrowFromCenter(m,opts)
    local a=A.GrowFromPoint(m,m:get_center(),opts);a.kind='GrowFromCenter';return a
end
function A.GrowFromEdge(m,edge,opts)
    local a=A.GrowFromPoint(m,m:get_critical_point(V(edge)),opts);a.kind='GrowFromEdge';return a
end
function A.GrowArrow(m,opts)
    assert(m and m._arrow,'GrowArrow requires Arrow')
    local a=A.GrowFromPoint(m,m:get_start(),opts);a.kind='GrowArrow';a.grow_arrow=true;return a
end
function A.SpinInFromNothing(m,opts)
    opts=opts or {};assert(opts.path_func==nil,'SpinInFromNothing supplies its own spiral path')
    local a=A.GrowFromCenter(m,U.merge(opts,{path_func=Paths.spiral_path(opts.angle or math.pi/2)}))
    a.kind='SpinInFromNothing';return a
end
function A.DrawBorderThenFill(m,opts)
    assert(m and m.is_vector,'DrawBorderThenFill requires VMobject')
    return new('DrawBorderThenFill',m,U.merge({run_time=2,rate_func=R.double_smooth},opts))
end
function A.Write(m,opts)
    opts=opts or {};assert(m and m.is_vector,'Write requires VMobject')
    local n=#m:family_members_with_points()
    local a=new('Write',m,U.merge({run_time=n<15 and 1 or 2,lag_ratio=math.min(4/math.max(1,n),0.2),rate_func=R.linear,remover=not not opts.reverse},opts))
    a.reverse=not not opts.reverse;return a
end
function A.Unwrite(m,opts)
    local a=A.Write(m,U.merge({reverse=true,reverse_rate_function=true},opts));a.kind='Unwrite';return a
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
    if self.kind~='Succession' then for _,a in ipairs(self.animations) do a:begin(scene) end end
    self:interpolate(0);return self
end
function Composition:interpolate(alpha)
    local t=self.rate_func(U.clamp(alpha))*self.natural_duration
    if self.kind~='Succession' then
        for i,a in ipairs(self.animations) do
            local start,finish=table.unpack(self.timings[i])
            a:interpolate(finish==start and (t>=start and 1 or 0) or U.clamp((t-start)/(finish-start)))
        end
        return self
    end
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
    if self.kind=='Succession' then self:interpolate(1)
    else for _,a in ipairs(self.animations) do a:finish() end end
    self.finished=true;return self
end
function Composition:update_mobjects(dt)
    for _,a in ipairs(self.animations) do
        if a.started and (self.kind~='Succession' or not a.finished) then a:update_mobjects(dt) end
    end
    return self
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
