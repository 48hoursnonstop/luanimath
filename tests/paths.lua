local l=require('luanim')
local fixture=dofile('tests/reference_paths.lua')
local checks=0
local function eq(a,b,label)
    if type(a)=='table' then
        assert(type(b)=='table' and #a==#b,label..' lengths '..#a..' vs '..tostring(type(b)=='table' and #b or b))
        for i=1,#a do eq(a[i],b[i],label..'['..i..']') end
    else checks=checks+1;assert(math.abs(a-b)<=1e-9,label..': '..a..' vs '..b) end
end
for _,c in ipairs(fixture.paths) do
    local fn=c.kind=='arc' and l.path_along_arc(c.angle,c.axis) or l.path_along_circles(c.angle,c.centers)
    eq(fn(c.start,c.finish,c.alpha),c.expected,'path '..c.kind)
end
for _,c in ipairs(fixture.transforms) do
    local a,b=l.Square():shift(l.LEFT),l.Circle():shift(l.RIGHT)
    local animation=l.Transform(a,b,{path_arc=c.angle,rate_func=l.linear});animation:begin();animation:interpolate(c.alpha)
    eq(a.points,c.points,'arc transform')
end
for _,c in ipairs(fixture.composition) do
    local a,b=l.Square():shift(l.LEFT),l.Circle():shift(l.RIGHT)
    local one=l.Transform(a,a:copy():shift(l.UP),{run_time=1,rate_func=l.linear})
    local two=l.Transform(b,b:copy():shift(l.DOWN),{run_time=2,rate_func=l.linear})
    local group=l[c.kind]({one,two},{rate_func=l[c.rate]});group:begin()
    for _,t in ipairs(c.trace) do group:interpolate(t.alpha);eq(a.points,t.a,'composition a');eq(b.points,t.b,'composition b') end
    group:finish();eq(a.points,c.final_a,'finish a');eq(b.points,c.final_b,'finish b')
end
for _,c in ipairs(fixture.motion) do
    local obj=l.VGroup(l.Square():shift(l.LEFT),l.Circle():shift(l.RIGHT))
    local a=l.MoveAlongPath(obj,l.Circle{radius=2},{rate_func=l.linear});a:begin();a:interpolate(c.alpha)
    local points={};for i,m in ipairs(obj:get_family()) do points[i]=m.points end
    eq(points,c.points,'group path motion')
end
local obj=l.Square():add_updater(function(m,dt) m:shift(dt*l.RIGHT) end)
local target=l.Circle():shift(2*l.RIGHT):add_updater(function(m,dt) m:shift(dt*l.UP) end)
local animation=l.Transform(obj,target,{rate_func=l.linear});animation:begin()
for _,c in ipairs(fixture.updates) do
    animation:update_mobjects(c.dt);animation:interpolate(c.alpha)
    eq(obj.points,c.points,'updater snapshot');eq(target.points,c.target,'updater target')
end
animation:finish();eq(obj.points,fixture.updated_finish,'updater finish')
local start,finish={l.LEFT,l.UP},{l.RIGHT,l.DOWN}
eq(l.clockwise_path()(start,finish,.5),l.path_along_arc(-math.pi)(start,finish,.5),'clockwise')
eq(l.counterclockwise_path()(start,finish,.5),l.path_along_arc(math.pi)(start,finish,.5),'counterclockwise')
assert(not pcall(function() l.path_along_arc(0/0) end))
assert(not pcall(function() l.Transform(l.Circle(),l.Square(),{path_func='invalid'}) end))
print(('PASS: %d mathematical paths, %d transforms, %d composition traces and %d grouped motion states; %d numeric checks'):format(#fixture.paths,#fixture.transforms,#fixture.composition,#fixture.motion,checks))
