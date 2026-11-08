local l=require('luanimath')
local U=require('luanimath.util')
local data=dofile('tests/reference_growth.lua')
local checks,max_error=0,0
local function eq(a,b,label)
    if type(b)=='table' then
        assert(type(a)=='table' and #a==#b,label..' length')
        for i=1,#b do eq(a[i],b[i],label..'['..i..']') end
    else
        local error=math.abs(a-b);max_error=math.max(max_error,error);checks=checks+1
        assert(error<=1e-9,('%s: %.17g vs %.17g'):format(label,a,b))
    end
end
local function subject(kind)
    if kind=='square' then return l.Square{side_length=1.2,color=l.BLUE,fill_opacity=.3,stroke_width=3}:rotate(.23):shift(l.vec(.7,.4)) end
    if kind=='group' then return l.VGroup(l.Circle{radius=.5,color=l.RED,fill_opacity=.2}:shift(l.LEFT),l.Square{side_length=.9,color=l.TEAL,fill_opacity=.5}:shift(l.RIGHT)):shift(l.DOWN*.3) end
    return l.Text('Lua',{font='Noto Sans',font_size=42,color=l.GOLD})
end
local function state(obj)
    local s={points={},fills={},fill_opacity={},strokes={},stroke_opacity={},widths={},center=obj:get_center()}
    for i,m in ipairs(obj:family_members_with_points()) do
        s.points[i]=m.points;s.fills[i]={table.unpack(m.fill_color,1,3)};s.fill_opacity[i]=m.fill_color[4]
        s.strokes[i]={table.unpack(m.stroke_color,1,3)};s.stroke_opacity[i]=m.stroke_color[4];s.widths[i]=m.stroke_width
    end
    return s
end
local function compare(obj,expected,label) local actual=state(obj);for key,value in pairs(expected) do eq(actual[key],value,label..' '..key) end end
local images={};for _,c in ipairs(data.images) do images[c.case..':'..c.step]=c.image end
U.mkdir('artifacts/growth')
for i,c in ipairs(data.cases) do
    local obj=subject(c.shape)
    local options=c.variant==0 and {} or {point_color=l.PURPLE,lag_ratio=.2,rate_func=l.linear}
    local anim
    if c.kind=='GrowFromPoint' then anim=l.GrowFromPoint(obj,c.point,options)
    elseif c.kind=='GrowFromEdge' then anim=l.GrowFromEdge(obj,c.edge,options)
    else anim=l[c.kind](obj,options) end
    if c.variant==1 then obj:shift(l.vec(.4,-.1)) end
    anim:begin();eq(anim.run_time,c.run_time,'duration')
    for j,s in ipairs(c.states) do
        anim:interpolate(s.alpha);compare(obj,s.expected,'growth '..i..'/'..j)
        local name=images[i..':'..j]
        if name then local renderer=l.Renderer{pixel_width=480,pixel_height=270};renderer:render({obj},'artifacts/growth/'..name);renderer:close() end
    end
    anim:finish();compare(obj,c.finished,'finished growth '..i)
end
for i,c in ipairs(data.paths) do eq(l.spiral_path(c.angle,c.axis)(c.start,c.finish,c.alpha),c.expected,'spiral '..i) end
local function fails(fn) checks=checks+1;assert(not pcall(fn),'expected invalid growth rejection') end
fails(function() l.GrowFromPoint(l.Square(),false) end)
fails(function() l.GrowFromPoint(l.Square(),l.ORIGIN,{introducer=false}) end)
fails(function() l.SpinInFromNothing(l.Square(),{path_func=l.straight_path()}) end)
fails(function() l.SpinInFromNothing(l.Square(),{angle=0/0}) end)
fails(function() l.spiral_path(1)({l.ORIGIN},{},.5) end)
local anchor=l.Dot(l.LEFT);local grown=l.Square();local animation=l.GrowFromPoint(grown,anchor)
anchor:shift(l.UP);animation:begin();eq(grown:get_center(),{-1,1,0},'Mobject point resolved at begin');animation:finish()
local rendered=l.Square()
local scene=l.Scene(function(s)
    s:play(l.GrowFromCenter(rendered),{run_time=.2})
    checks=checks+1;assert(#s.mobjects==1 and s.mobjects[1]==rendered,'growth must introduce actual object')
    s:play(l.GrowFromCenter(rendered,{remover=true}),{run_time=.2})
    checks=checks+1;assert(#s.mobjects==0,'growth remover cleanup')
end,{pixel_width=64,pixel_height=64,frame_rate=10})
local report=scene:render{output='artifacts/growth/lifecycle.png'};eq(report.frame_count,4,'growth lifecycle frames')
print(('PASS: %d growth cases, %d spiral paths, %d images; %d numerical/lifecycle checks, max error %.17g'):format(#data.cases,#data.paths,#data.images,checks,max_error))
