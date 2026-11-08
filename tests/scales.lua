local l=require('luanimath')
local U=require('luanimath.util')
local data=dofile('tests/reference_scales.lua')
local checks,max_error=0,0
for key,expected in pairs(data.colors) do checks=checks+1;assert(l[key]==expected,'upstream palette mismatch: '..key) end
local function eq(a,b,label)
    if type(b)=='table' then
        assert(type(a)=='table' and #a==#b,label..' length')
        for i=1,#b do eq(a[i],b[i],label..'['..i..']') end
    else
        local error=math.abs(a-b);max_error=math.max(max_error,error)
        checks=checks+1;assert(error<=1e-9,('%s: %.17g vs %.17g'):format(label,a,b))
    end
end
local function scale(spec) return l[spec[1]](spec[2]) end
local function state(obj)
    local points={};for _,m in ipairs(obj:family_members_with_points()) do points[#points+1]=m.points end
    return {points=points,center=obj:get_center(),width=obj:get_width(),height=obj:get_height()}
end
local function compare(obj,expected,label)
    local actual=state(obj);for key,value in pairs(expected) do eq(actual[key],value,label..' '..key) end
end
local function pose(obj,index) if index==1 then obj:rotate(.41):scale(1.2):shift(l.vec(.2,-.3,.1)) end end
for _,c in ipairs(data.operations) do
    local s=l[c.kind](c.options)
    eq(s:map(c.values),c.mapped,'scale map');eq(s:inverse(c.mapped),c.inverse,'scale inverse')
end
for i,c in ipairs(data.lines) do
    local obj=l.NumberLine(U.merge(c.options,{scaling=scale(c.scale)}));pose(obj,c.pose)
    compare(obj,c.expected,'line '..i);eq(obj:get_tick_range(),c.ticks,'scaled ticks')
    eq({obj.x_min,obj.x_max,obj.x_step},c.bounds,'scaled bounds')
    eq(obj:n2p(c.values),c.mapped,'line mapping')
    eq(obj:p2n({{-2,.3,0},{0,0,0},{2,-.1,.2}}),c.inverse,'line inverse')
end
for i,c in ipairs(data.functions) do
    local obj=l.ParametricFunction(function(t) return l.vec(t,t*t/5,0) end,U.merge(c.options,{scaling=scale(c.scale)}))
    compare(obj,c.expected,'scaled sampling '..i)
end
for i,c in ipairs(data.axes) do
    local obj=l.Axes(U.merge(c.options,{x_axis_config={scaling=scale(c.x_scale)},y_axis_config={scaling=scale(c.y_scale)}}))
    local graph=obj:plot(function(x) return x*.3+1 end,{x_range={-1,2,.1},color=l.BLUE})
    pose(obj,c.pose);pose(graph,c.pose)
    compare(obj,c.expected,'axes '..i);compare(graph,c.graph,'plot '..i)
    eq(obj:c2p(c.values),c.mapped,'axes mapping')
    eq(obj:p2c({{-2,.3,0},{0,0,0},{2,-.1,.2}}),c.inverse,'axes inverse')
end
local specs={{{'LinearBase',{}},{'LogBase',{}}},{{'LogBase',{base=2}},{'LinearBase',{}}},{{'LogBase',{}},{'LogBase',{base=2}}}}
U.mkdir('artifacts/scales')
for i,spec in ipairs(specs) do
    local ax=l.Axes{x_range={-1,2,.5},y_range={-2,2,1},x_length=8,y_length=5,x_axis_config={scaling=scale(spec[1])},y_axis_config={scaling=scale(spec[2])}}
    local graph=ax:plot(function(x) return x*.3+1 end,{x_range={-1,2,.05},color=l.BLUE})
    local dot=l.Dot(ax:c2p(scale(spec[1]):map(.5),scale(spec[2]):map(1)),{color=l.YELLOW})
    local renderer=l.Renderer{pixel_width=480,pixel_height=270}
    renderer:render({ax,graph,dot},'artifacts/scales/scale_'..i..'.png');renderer:close()
end
local function fails(fn) checks=checks+1;assert(not pcall(fn),'expected invalid scale rejection') end
for _,base in ipairs({0,-2,1,math.huge,0/0}) do fails(function() l.LogBase{base=base} end) end
for _,factor in ipairs({0,math.huge,0/0}) do fails(function() l.LinearBase{scale_factor=factor} end) end
for _,value in ipairs({0,-1}) do fails(function() l.LogBase():inverse(value) end) end
fails(function() l.LogBase():inverse({1,-1}) end)
fails(function() l.LogBase():map(1000) end)
fails(function() l.NumberLine{scaling={}} end)
fails(function() l.NumberLine{include_numbers=true,scaling=l.LogBase()} end)
fails(function() l.Axes{y_axis_config={scaling=l.LogBase()}}:get_origin() end)
local copied=l.NumberLine{scaling=l.LinearBase{scale_factor=2},include_ticks=false}:copy()
eq(copied:n2p(2),{1,0,0},'copied scale metatable')
eq(l.LogBase():map({{0,1},{2,3}}),{{1,10},{100,1000}},'nested numerical arrays')
local custom={map=function(_,x) return x end,inverse=function(_,x) return x end}
local axis=l.NumberLine{scaling=custom,include_ticks=false};eq(axis:n2p(0),{0,0,0},'Lua custom scale')
print(('PASS: %d scale operations, %d lines, %d sampled functions, %d axes/plots; %d numeric/invalid-input checks'):format(#data.operations,#data.lines,#data.functions,#data.axes,checks))
print(('Maximum absolute scale/reference error: %.17g (tolerance 1e-9)'):format(max_error))
