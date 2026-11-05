local l=require('luanim')
local U=require('luanim.util')
local fixture=dofile('tests/reference_alignment.lua')
local checks=0
local function eq(a,b,label)
    if type(a)=='table' then
        assert(type(b)=='table' and #a==#b,label..' lengths '..#a..' vs '..tostring(type(b)=='table' and #b or b))
        for i=1,#a do eq(a[i],b[i],label..'['..i..']') end
    elseif type(a)=='number' then checks=checks+1;assert(math.abs(a-b)<=1e-9,label..': '..a..' vs '..b)
    else checks=checks+1;assert(a==b,label) end
end
local function make(spec)
    local obj
    if spec.kind=='VGroup' then
        local children={};for i,c in ipairs(spec.children or {}) do children[i]=make(c) end
        obj=l.VGroup(table.unpack(children))
    elseif spec.kind=='VMobject' then
        obj=l.VMobject(spec.options)
        for _,c in ipairs(spec.commands or {}) do obj[c[1]](obj,table.unpack(c,2)) end
    elseif spec.kind=='VectorizedPoint' then obj=l.VectorizedPoint(spec.location,spec.options)
    else obj=l[spec.kind](spec.options) end
    if spec.shift then obj:shift(l.vec(spec.shift)) end
    return obj
end
for i,c in ipairs(fixture.builders) do
    local obj=make{kind='VMobject',commands=c.commands}
    eq(obj.points,c.points,'builder '..i);eq(obj:has_new_path_started(),c.pending,'pending')
    eq(obj:get_num_curves(),c.curves,'curves');eq(obj:get_subpaths(),c.subpaths,'subpaths')
end
U.mkdir('artifacts/alignment')
for i,c in ipairs(fixture.cases) do
    local obj,target=make(c.source),make(c.target)
    local before=target:copy();local a=l.Transform(obj,target,{rate_func=l.linear})
    a:begin();a:interpolate(c.alpha)
    local points,fill,stroke,widths={},{},{},{}
    for j,m in ipairs(obj:get_family()) do points[j]=m.points;fill[j]=m.fill_color[4];stroke[j]=m.stroke_color[4];widths[j]=m.stroke_width end
    eq(points,c.expected.points,'transform '..i)
    eq(fill,c.expected.fill,'fill '..i);eq(stroke,c.expected.stroke,'stroke '..i);eq(widths,c.expected.widths,'stroke widths '..i)
    eq(target:get_all_points(),before:get_all_points(),'target must remain unchanged')
    if c.image then
        local r=l.Renderer{pixel_width=320,pixel_height=180,frame_height=8,frame_width=128/9}
        r:render({obj},'artifacts/alignment/'..c.image);r:close()
    end
end
local m=l.VMobject():start_new_path(l.ORIGIN):add_line_to(l.RIGHT)
m:insert_n_curves(3);eq(m:get_num_curves(),4,'insert curves');eq(m:get_start(),l.ORIGIN,'start');eq(m:get_last_point(),l.RIGHT,'end')
local p=l.VectorizedPoint(l.RIGHT):set_location(l.UP);eq(p:get_location(),l.UP,'location');eq(p:get_width(),.01,'artificial width')
local cubic=l.VMobject():add_cubic_bezier_curve(l.ORIGIN,l.UP,l.RIGHT,l.vec(2,0,0))
eq(cubic:get_start_anchors(),{l.ORIGIN},'start anchors');eq(cubic:get_end_anchors(),{l.vec(2,0,0)},'end anchors')
eq(cubic:get_anchors(),{l.ORIGIN,l.vec(2,0,0)},'anchors')
local joined=l.VMobject():add_subpath(cubic.points);eq(joined.points,cubic.points,'add_subpath')
joined:clear_points();eq(#joined.points,0,'clear points');joined:append_points(cubic.points)
eq(joined.points,cubic.points,'append points')
eq(cubic:get_subcurve(-1,2).points,cubic.points,'clamped full curve')
assert(not pcall(function() cubic:add_subpath({l.ORIGIN}) end),'incomplete subpath must fail')
local wrapped=l.Circle():get_subcurve(.8,.2);assert(wrapped:get_num_curves()>0)
local bad=pcall(function() l.VMobject():add_line_to(l.RIGHT) end);assert(not bad,'empty path must reject add_line_to')
print(('PASS: %d path-builder + %d family/subpath states, %d numeric/identity checks'):format(#fixture.builders,#fixture.cases,checks))
