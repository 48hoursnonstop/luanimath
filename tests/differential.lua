local l=require('luanimath')
local U=require('luanimath.util')
local fixture=dofile('tests/reference_v0221.lua')
local count,scalars=0,0
local function eq(a,b,path)
    path=path or ''
    if type(a)=='table' then
        assert(type(b)=='table' and #a==#b,path..' length '..#a..' != '..tostring(type(b)=='table' and #b or b))
        for i=1,#a do eq(a[i],b[i],path..'['..i..']') end
    else
        scalars=scalars+1
        assert(type(a)=='number' and type(b)=='number' and math.abs(a-b)<=1e-9,
            path..': '..tostring(a)..' != '..tostring(b))
    end
end
local function state(m,expected,label)
    eq(m.points,expected.points,label..'.points');eq(m:get_center(),expected.center,label..'.center')
    eq(m:get_width(),expected.width,label..'.width');eq(m:get_height(),expected.height,label..'.height')
    eq({table.unpack(m.fill_color,1,3)},expected.fill,label..'.fill');eq(m.fill_color[4],expected.fill_opacity,label..'.fill_opacity')
    eq({table.unpack(m.stroke_color,1,3)},expected.stroke,label..'.stroke');eq(m.stroke_color[4],expected.stroke_opacity,label..'.stroke_opacity')
    eq(m.stroke_width,expected.stroke_width,label..'.stroke_width')
end
for i,case in ipairs(fixture.objects) do
    local m
    if case.name=='Line' or case.name=='Dot' then m=l[case.name]() else m=l[case.name](case.options) end
    for _,action in ipairs(case.actions) do m[action[1]](m,table.unpack(action,2)) end
    state(m,case.expected,case.name..':'..i);count=count+1
end
for _,case in ipairs(fixture.rates) do eq(l.rate_functions[case.name](case.t),case.expected,case.name..':'..case.t);count=count+1 end
for i,case in ipairs(fixture.paths) do
    local m=(case.name=='Line' or case.name=='Dot') and l[case.name]() or l[case.name](case.options)
    eq(m:point_from_proportion(case.alpha),case.point,'path.point:'..i)
    eq(m:get_subcurve(0,case.alpha).points,case.partial,'path.partial:'..i)
    eq(m:get_arc_length(),case.length,'path.length:'..i);count=count+1
end
U.mkdir('artifacts/luanimath')
for _,case in ipairs(fixture.animations) do
    local obj=l.Square{color=l.BLUE,fill_opacity=.35}:shift(l.LEFT)
    local target=l.Circle{color=l.GREEN,fill_opacity=.7}:shift(l.RIGHT)
    local a
    if case.kind=='Transform' then a=l.Transform(obj,target,{rate_func=l.linear})
    elseif case.kind=='Rotate' then a=l.Rotate(obj,1.2,{about_point=l.ORIGIN,rate_func=l.linear})
    else a=l[case.kind](obj,{rate_func=l.linear}) end
    a:begin();a:interpolate(case.alpha);state(obj,case.expected,case.kind..':'..case.alpha)
    local renderer=l.Renderer{pixel_width=320,pixel_height=180,frame_height=8,frame_width=128/9}
    renderer:render({obj},('artifacts/luanimath/%s_%.3f.png'):format(case.kind,case.alpha));renderer:close()
    count=count+1
end
print(('PASS: %d upstream differential cases, %d scalar comparisons; %d actual Lua/Cairo PNGs'):format(count,scalars,#fixture.animations))
