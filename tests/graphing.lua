local l=require('luanimath')
local U=require('luanimath.util')
local data=dofile('tests/reference_graphing.lua')
local checks=0
local function eq(a,b,label)
    if type(a)=='table' then
        assert(type(b)=='table' and #a==#b,label..': lengths '..#a..' vs '..tostring(type(b)=='table' and #b or b))
        for i=1,#a do eq(a[i],b[i],label..'['..i..']') end
    else checks=checks+1;assert(math.abs(a-b)<=1e-9,label..': '..a..' vs '..b) end
end
local function state(obj,expected,label)
    local points={};for _,m in ipairs(obj:family_members_with_points()) do points[#points+1]=m.points end
    eq(points,expected.points,label..'.points');eq(obj:get_center(),expected.center,label..'.center')
    eq(obj:get_width(),expected.width,label..'.width');eq(obj:get_height(),expected.height,label..'.height')
end
for i,c in ipairs(data.cases) do
    local obj=l[c.kind](c.options)
    if c.action=='shift' then obj:shift(l.vec(.3,-.7,.1)) elseif c.action=='rotate' then obj:rotate(.71) elseif c.action=='scale' then obj:scale(1.3) end
    state(obj,c.expected,c.kind..':'..i)
    if c.kind=='NumberLine' then
        eq(obj:get_tick_range(),c.ticks,'ticks')
        for j,x in ipairs(c.values) do eq(obj:n2p(x),c.mapped[j],'n2p');eq(obj:p2n({x,.3,0}),c.inverse[j],'p2n') end
    else
        for j,x in ipairs(c.values) do eq(obj:c2p(x),c.mapped[j],'c2p');eq(obj:p2c({x[1],x[2],0}),c.inverse[j],'p2c') end
    end
end
for _,c in ipairs(data.splines) do eq(l.VMobject():set_points_smoothly(c.anchors).points,c.points,'spline') end
for _,c in ipairs(data.functions) do
    local fn=c.kind=='parabola' and function(t) return l.vec(t,t*t/4,0) end
        or c.kind=='circle' and function(t) return l.vec(math.cos(t),math.sin(t),0) end
        or function(t) return l.vec(t,1/t,0) end
    state(l.ParametricFunction(fn,c.options),c.expected,'function '..c.kind)
end
local function fails(fn) checks=checks+1;assert(not pcall(fn),'expected rejection') end
fails(function() l.NumberLine{x_range={1,1,1}} end)
fails(function() l.NumberLine{x_range={0,1,0}} end)
fails(function() l.NumberLine{include_numbers=true} end)
fails(function() l.ParametricFunction(function() return {0/0,0,0} end) end)
fails(function() l.ParametricFunction(function() return {} end) end)
fails(function() l.ParametricFunction(function() return nil end) end)
local ax=l.Axes{x_range={-3,3,1},y_range={-2,2,1},x_length=9,y_length=5,tips=true}
eq(ax:get_origin(),ax:c2p(0,0),'origin')
assert(ax:get_axes().submobjects[1]==ax.x_axis and ax:get_axes().submobjects[2]==ax.y_axis)
assert(ax.x_axis:get_tick_marks()==ax.x_axis.ticks)
eq(ax.x_axis:get_unit_size(),1.5,'unit size')
local graph_fn=function(x) return x*x/4 end
local fg=l.FunctionGraph(graph_fn,{x_range={-2,2,.2}})
eq(fg:get_point_from_function(1),{1,.25,0},'function helper')
eq(fg:get_function()(1),{1,.25,0},'function accessor')
local expected_fg=l.ParametricFunction(function(x) return l.vec(x,graph_fn(x),0) end,{t_range={-2,2,.2},color=l.YELLOW})
eq(fg.points,expected_fg.points,'FunctionGraph geometry')
local curve=ax:plot(math.sin,{x_range={-3,3,.1},color=l.BLUE})
local dot=l.Dot(ax:c2p(1,math.sin(1)),{color=l.YELLOW})
U.mkdir('artifacts/graphing')
local r=l.Renderer{pixel_width=480,pixel_height=270,frame_height=8,frame_width=128/9}
r:render({ax,curve,dot},'artifacts/graphing/axes_sine.png');r:close()
print(('PASS: %d coordinate, spline and function cases, %d scalar/invalid-input checks'):format(#data.cases+#data.splines+#data.functions,checks))
