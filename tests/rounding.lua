local l=require('luanimath')
local U=require('luanimath.util')
local data=dofile('tests/reference_rounding.lua')
local checks,max_error,known=0,0,0
local function eq(a,b,label)
    if type(b)=='table' then
        assert(type(a)=='table' and #a==#b,label..' length '..tostring(type(a)=='table' and #a or a)..' vs '..#b)
        for i=1,#b do eq(a[i],b[i],label..'['..i..']') end
    else
        local error=math.abs(a-b);max_error=math.max(max_error,error)
        checks=checks+1;assert(error<=1e-9,('%s: %.17g vs %.17g'):format(label,a,b))
    end
end
local function state(obj) return {points=obj.points,center=obj:get_center(),width=obj:get_width(),height=obj:get_height()} end
local function compare(obj,expected,label) local actual=state(obj);for key,value in pairs(expected) do eq(actual[key],value,label..' '..key) end end
local function canonical(obj)
    local points={}
    for _,curve in ipairs(l.bezier.curves(obj.points)) do
        local extent=0;for _,p in ipairs(curve) do extent=math.max(extent,l.vec.norm(p-curve[1])) end
        if extent>1e-12 then for _,p in ipairs(curve) do points[#points+1]=p end end
    end
    return obj:copy():set_points(points)
end
for i,c in ipairs(data.arcs) do
    local obj=l.ArcBetweenPoints(c.start,c.finish,c.options)
    compare(obj,c.expected,'arc '..i)
    if c.center_issue then
        known=known+1;checks=checks+1;assert(l.vec.norm(l.vec(c.arc_center))>1e12,'known source instability changed; re-audit')
        eq(obj:get_arc_center(),{0,0,0},'undefined straight arc center');assert(obj._failed_to_get_center)
    else eq(obj:get_arc_center(),c.arc_center,'arc center '..i);eq(obj:stop_angle(),c.stop_angle,'stop angle '..i) end
end
for i,c in ipairs(data.polygons) do
    local obj=l.Polygram(c.groups):round_corners(c.radius,c.options)
    if c.degenerate_subdivision_issue then
        checks=checks+1;assert(#obj.points~=#c.expected.points,'known original curve-count difference changed; re-audit')
        known=known+1;local normalized=canonical(obj);local expected=c.degenerate_subdivision_issue
        compare(normalized,expected.expected,'canonical polygon '..i)
        eq(normalized:get_vertices(),expected.vertices,'canonical vertices '..i)
        eq(normalized:get_vertex_groups(),expected.vertex_groups,'canonical vertex groups '..i)
    else
        compare(obj,c.expected,'polygon '..i);eq(obj:get_vertices(),c.vertices,'vertices '..i);eq(obj:get_vertex_groups(),c.vertex_groups,'vertex groups '..i)
    end
end
for i,c in ipairs(data.placements) do
    local obj=l[c.kind]():put_start_and_end_on(c.start,c.finish)
    if c.closed_loop_issue then
        known=known+1;checks=checks+1;assert(math.abs(c.expected.width-c.closed_loop_issue.width)>1,'known original closed-loop placement changed; re-audit')
        compare(obj,c.closed_loop_issue,'closed-loop shift diagnostic '..i)
    else compare(obj,c.expected,'placement '..i) end
end
U.mkdir('artifacts/rounding')
for i,c in ipairs(data.svgs) do
    local path='artifacts/rounding/source_'..i..'.svg'
    local file=assert(io.open(path,'wb'));assert(file:write(c.code));assert(file:close())
    local obj=l.SVGMobject(path)
    assert(#obj.submobjects==#c.expected)
    for j,expected in ipairs(c.expected) do compare(obj.submobjects[j],expected,'SVG '..i) end
    local renderer=l.Renderer{pixel_width=480,pixel_height=270};renderer:render({obj},'artifacts/rounding/svg_'..i..'.png');renderer:close()
end
for i,radius in ipairs({.2,-.2,2}) do
    local obj=l.RoundedRectangle{width=4,height=2,corner_radius=radius,color=l.BLUE,fill_opacity=.3}
    local renderer=l.Renderer{pixel_width=480,pixel_height=270};renderer:render({obj},'artifacts/rounding/rounded_'..i..'.png');renderer:close()
end
local arc=l.ArcBetweenPoints({-2,-1,0},{2,1,0},{angle=2,color=l.YELLOW})
local renderer=l.Renderer{pixel_width=480,pixel_height=270};renderer:render({arc},'artifacts/rounding/arc.png');renderer:close()
local function fails(fn) checks=checks+1;assert(not pcall(fn),'expected invalid rounding rejection') end
fails(function() l.ArcBetweenPoints({-1,0},{1,0},{radius=.5}) end)
fails(function() l.ArcBetweenPoints({0,0},{0,0},{radius=0}) end)
fails(function() l.ArcBetweenPoints({0,0},{1,0},{angle=l.TAU}) end)
fails(function() l.RoundedRectangle{corner_radius={}} end)
fails(function() l.Polygram({{{0,0},{1,0},{0,1}}}):round_corners({.1,.2}) end)
fails(function() l.Square():round_corners(.2,{components_per_rounded_corner=1}) end)
fails(function() l.Square():round_corners(0/0) end)
fails(function() l.Square():round_corners(1e-10,{components_per_rounded_corner=3,evenly_distribute_anchors=true}) end)
fails(function() l.ArcBetweenPoints({0,0},{1,1},{num_components=100002}) end)
fails(function() l.Line():get_arc_center() end)
local moved=l.ArcBetweenPoints({0,0},{1,1}):move_arc_center_to(l.vec(2,3))
eq(moved:get_arc_center(),{2,3,0},'moving arc center')
print(('PASS: %d arcs, %d rounded polygons, %d placements and %d SVGs; %d checks, max error %.17g'):format(#data.arcs,#data.polygons,#data.placements,#data.svgs,checks,max_error))
print(('Recorded %d original-upstream center/degenerate-subdivision differences; original results retained and geometry normalized separately'):format(known))
