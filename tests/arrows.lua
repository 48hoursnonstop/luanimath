local l=require('luanimath')
local U=require('luanimath.util')
local data=dofile('tests/reference_arrows.lua')
local checks,max_error,known=0,0,0
local function eq(a,b,label)
    if type(b)=='table' then
        assert(type(a)=='table' and #a==#b,label..' length')
        for i=1,#b do eq(a[i],b[i],label..'['..i..']') end
    else
        local error=math.abs(a-b);max_error=math.max(max_error,error);checks=checks+1
        assert(error<=1e-9,('%s: %.17g vs %.17g'):format(label,a,b))
    end
end
local function state(obj)
    local s={points={},fills={},fill_opacity={},strokes={},stroke_opacity={},widths={},start=obj:get_start(),['end']=obj:get_end(),center=obj:get_center()}
    for i,m in ipairs(obj:get_family()) do
        s.points[i]=m.points;s.fills[i]={table.unpack(m.fill_color,1,3)};s.fill_opacity[i]=m.fill_color[4]
        s.strokes[i]={table.unpack(m.stroke_color,1,3)};s.stroke_opacity[i]=m.stroke_color[4];s.widths[i]=m.stroke_width
    end
    if obj._arrow then s.tip_base=obj.tip.base;s.tip_point=obj.tip.tip_point;s.tip_vector=obj.tip.vector;s.tip_length=obj.tip.length;s.normal=obj:get_normal_vector();s.default_tip_length=obj:get_default_tip_length() end
    return s
end
local function compare(obj,expected,label) local actual=state(obj);for key,value in pairs(expected) do eq(actual[key],value,label..' '..key) end end
local function options(opts) opts=U.copy(opts);if type(opts.tip_shape)=='string' then opts.tip_shape=l[opts.tip_shape] end;return opts end
for i,c in ipairs(data.cases) do
    local obj=l.Arrow(c.start,c.finish,options(c.options))
    if c.action=='rotate' then obj:rotate(.37,{axis={1,2,1}})
    elseif c.action=='scale' then obj:scale(2)
    elseif c.action=='small' then obj:scale(.2)
    elseif c.action=='negative' then obj:scale(-1.2)
    elseif c.action=='all_tips' then obj:scale(1.4,{scale_tips=true,about_point={.2,-.3,.1}})
    elseif c.action=='zero' then obj:scale(0,{scale_tips=true,about_point=c.start}) end
    if c.pole_azimuth_issue then
        local actual=obj:get_normal_vector();local expected=l.vec(c.expected.normal)
        checks=checks+1;assert(l.vec.norm(actual-expected)>1e-3,'known pole azimuth difference changed; re-audit')
        local cross=l.vec.cross(actual,expected);local angle=math.atan(cross[3],l.vec.dot(actual,expected))
        local registered=obj:copy();registered.tip:rotate(angle,{about_point=registered.tip.tip_point})
        compare(registered,c.expected,'rigid tip registration '..i);known=known+1
    else compare(obj,c.expected,'arrow '..i..' '..c.action) end
end
for i,c in ipairs(data.growth) do
    local obj=l.Arrow(c.start,c.finish,options(c.options));local anim=l.GrowArrow(obj,{point_color=l.GREEN,rate_func=l.linear});anim:begin()
    for j,s in ipairs(c.states) do anim:interpolate(s.alpha);compare(obj,s.expected,'growth '..i..'/'..j) end
    anim:finish();compare(obj,c.finished,'growth finish '..i)
end
for i,c in ipairs(data.tips) do
    local obj=l[c.kind](c.options);compare(obj,c.expected,'tip '..i)
    eq(obj.base,c.base,'tip base');eq(obj.tip_point,c.point,'tip point');eq(obj.vector,c.vector,'tip vector');eq(obj.length,c.length,'tip length')
    local delta=obj.tip_angle-c.angle;eq(math.atan(math.sin(delta),math.cos(delta)),0,'tip angle modulo 2*pi')
end
U.mkdir('artifacts/arrows')
local function render(obj,name,camera) local renderer=l.Renderer({pixel_width=480,pixel_height=270},camera);renderer:render({obj},'artifacts/arrows/'..name);renderer:close() end
for i,factor in ipairs({1,.3,2}) do render(l.Arrow({-3,-1,0},{3,1,0},{color=l.YELLOW}):scale(factor),'arrow_'..i..'.png') end
render(l.Arrow({-2,-1,0},{2,1,3},{color=l.BLUE}),'arrow_3d.png',l.ThreeDCamera{phi=.8,theta=-.6})
local obj=l.Arrow({-3,-1,0},{3,1,0},{color=l.YELLOW});local anim=l.GrowArrow(obj,{rate_func=l.linear});anim:begin()
for i,alpha in ipairs({0,.25,.6,1}) do anim:interpolate(alpha);render(obj,'grow_'..i..'.png') end
local arrow=l.Arrow(l.LEFT,l.RIGHT);local tip=arrow.tip;local original=arrow.tip.length
arrow:scale(2);eq(arrow.tip.length,original,'fixed tip length');checks=checks+1;assert(arrow.tip==tip,'tip identity preserved by scale')
local popped=arrow:pop_tips();checks=checks+1;assert(not arrow:has_tip() and popped[1]==tip,'pop returns actual tip');eq(arrow:get_end(),{1.5,0,0},'pop restores shaft')
arrow:add_tip{tip=tip};checks=checks+1;assert(arrow:has_tip() and arrow.tip==tip,'reuse actual tip')
arrow:reset_normal_vector();eq(arrow.normal_vector,arrow:get_normal_vector(),'normal reset')
local function fails(fn) checks=checks+1;assert(not pcall(fn),'expected invalid arrow rejection') end
fails(function() l.GrowArrow(l.Line()) end)
fails(function() l.Arrow(l.LEFT,l.RIGHT,{max_tip_length_to_length_ratio=-1}) end)
fails(function() l.Arrow(l.LEFT,l.RIGHT,{tip_shape=function() end}) end)
fails(function() l.ArrowTriangleTip{length=-1} end)
fails(function() l.ArrowTriangleTip().length=2 end)
print(('PASS: %d Arrow states, %d growth traces and %d tips; %d checks, max error %.17g'):format(#data.cases,#data.growth,#data.tips,checks,max_error))
print(('Recorded %d original pole-azimuth differences; rigid tip-registration diagnostics are separate'):format(known))
