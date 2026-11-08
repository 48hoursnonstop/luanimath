local l=require('luanimath')
local U=require('luanimath.util')
local data=dofile('tests/reference_state_transforms.lua')
local checks,max_error=0,0
local function eq(a,b,label)
    if type(b)=='table' then
        assert(type(a)=='table' and #a==#b,label..' length '..tostring(type(a)=='table' and #a or a)..' vs '..#b)
        for i=1,#b do eq(a[i],b[i],label..'['..i..']') end
    else
        local error=math.abs(a-b);max_error=math.max(max_error,error);checks=checks+1
        assert(error<=1e-9,('%s: %.17g vs %.17g'):format(label,a,b))
    end
end
local function subject(shape)
    if shape=='square' then return l.Square{side_length=1.4,color=l.BLUE,fill_opacity=.4}:rotate(.2):shift(l.vec(.4,.2)) end
    if shape=='group' then return l.VGroup(l.Circle{radius=.6,color=l.RED,fill_opacity=.2}:shift(l.LEFT),l.Triangle{color=l.TEAL,fill_opacity=.3}:scale(.6):shift(l.RIGHT)) end
    if shape=='text' then return l.Text('Lua',{font='Noto Sans',font_size=40,color=l.GOLD}) end
    return l.Surface(function(u,v) return l.vec(u,v,.2*u*v) end,{u_range={-1,1},v_range={-1,1},resolution={2,2},checkerboard_colors=false})
end
local function state(obj)
    local s={points={},fills={},fill_opacity={},strokes={},stroke_opacity={},widths={},center=obj:get_center(),width=obj:get_width(),height=obj:get_height(),depth=obj:get_depth()}
    for i,m in ipairs(obj:get_family()) do
        s.points[i]=m.points;s.fills[i]={table.unpack(m.fill_color,1,3)};s.fill_opacity[i]=m.fill_color[4]
        s.strokes[i]={table.unpack(m.stroke_color,1,3)};s.stroke_opacity[i]=m.stroke_color[4];s.widths[i]=m.stroke_width
    end
    return s
end
local function compare(obj,expected,label) local actual=state(obj);for key,value in pairs(expected) do eq(actual[key],value,label..' '..key) end end
local function warp(p) return l.vec(p[1]+.2*p[2]^2,p[2]+.1*math.sin(p[1]),p[3]+.1*p[1]*p[2]) end
local function edit(obj) return obj:scale(.7):rotate(.3):shift(l.vec(.2,-.4,.1)):set_stroke(nil,2) end
local images={};for _,c in ipairs(data.images) do images[c.case..':'..c.step]=c.image end
U.mkdir('artifacts/state-transforms')
for i,c in ipairs(data.cases) do
    local obj=subject(c.shape);local opts=c.variant==0 and {} or {rate_func=l.linear,lag_ratio=.13,path_arc=.7}
    local anim
    if c.kind=='MoveToTarget' then obj:generate_target();edit(obj.target);anim=l.MoveToTarget(obj,opts)
    elseif c.kind=='Restore' then obj:save_state();edit(obj);anim=l.Restore(obj,opts)
    elseif c.kind=='ApplyMethod' then anim=l.ApplyMethod(obj,'set_fill',{l.PURPLE,.6},opts)
    elseif c.kind=='ApplyFunction' then anim=l.ApplyFunction(c.variant==0 and edit or function(copy) return l.VGroup(copy,l.Dot({2,1,0},{color=l.YELLOW})) end,obj,opts)
    elseif c.kind=='ApplyPointwiseFunction' then anim=l.ApplyPointwiseFunction(warp,obj,opts)
    elseif c.kind=='ApplyMatrix' then anim=l.ApplyMatrix(c.matrix,obj,U.merge(opts,{about_point=c.about}))
    elseif c.kind=='FadeToColor' then anim=l.FadeToColor(obj,l.PURPLE,opts)
    elseif c.kind=='ScaleInPlace' then anim=l.ScaleInPlace(obj,c.variant==0 and 1.4 or -.8,opts)
    else anim=l.ShrinkToCenter(obj,opts) end
    if c.variant==1 then obj:shift(l.vec(.3,-.2,.1)) end
    local ok,err=xpcall(function() anim:begin() end,debug.traceback)
    assert(ok,('begin case %d %s/%s: %s'):format(i,c.kind,c.shape,tostring(err)))
    eq(anim.run_time,c.run_time,'duration '..i)
    for j,s in ipairs(c.states) do
        anim:interpolate(s.alpha);compare(obj,s.expected,'transform '..i..'/'..j)
        local name=images[i..':'..j]
        if name then local renderer=l.Renderer{pixel_width=480,pixel_height=270};renderer:render({obj},'artifacts/state-transforms/'..name);renderer:close() end
    end
    anim:finish();compare(obj,c.finished,'finished '..i)
end
for i,c in ipairs(data.direct) do
    local obj
    if c.kind=='restore' then
        obj=subject(c.shape);obj:save_state():shift(l.vec(1,2,.5)):scale(.8):set_color(l.GREEN):restore()
        compare(obj,c.first,'first restore '..i);obj:save_state():shift(l.LEFT):restore();compare(obj.saved_state,c.saved,'saved state '..i)
    elseif c.kind=='target' then
        obj=subject(c.shape);obj:generate_target():shift(l.RIGHT);obj:generate_target():shift(l.UP);obj:become(obj.target);compare(obj.target,c.target,'target '..i)
    elseif c.kind=='expanded_restore' then
        obj=l.VGroup(l.Square());obj:save_state();obj:add(l.Circle():shift(l.RIGHT*2));obj:restore();compare(obj.saved_state,c.saved,'expanded saved state')
    elseif c.kind=='handles' then obj=subject('square'):scale_handle_to_anchor_distances(c.factor)
    elseif c.kind=='matrix_capture' then
        obj=subject('square');local matrix={{1,.3},{-.2,1.2}};local about={.2,-.3,.1}
        local anim=l.ApplyMatrix(matrix,obj,{about_point=about});matrix[1][1]=9;about[1]=.8;anim:begin():finish()
    elseif c.kind=='late_saved_state' then
        obj=subject('square');obj:save_state();local anim=l.Restore(obj);obj:shift(l.RIGHT):save_state():shift(l.UP);anim:begin():finish()
    elseif c.kind=='captured_target' then
        obj=subject('square');local old=obj:generate_target();old:shift(l.RIGHT);local anim=l.MoveToTarget(obj)
        obj:generate_target():shift(l.UP);old:set_color(l.PINK);anim:begin():finish()
    elseif c.kind=='smooth_surface' then
        obj=l.Surface(function(u,v) return l.vec(u,v,.2*u*v) end,{u_range={-1,1},v_range={-1,1},resolution={2,2},checkerboard_colors=false,make_smooth_after_applying_functions=true}):apply_function(warp)
    elseif c.kind=='nonvector_map' then
        obj=l.Mobject():set_points({{0,0,0},{1,2,3},{-1,.2,0}}):apply_function(warp)
        eq(obj.points,c.points,'nonvector points');eq(obj:get_center(),c.center,'nonvector center')
    else obj=l.Circle{pre_function_handle_to_anchor_scale_factor=.02,make_smooth_after_applying_functions=c.smoothing}:shift(l.RIGHT):apply_function(warp) end
    if c.expected then compare(obj,c.expected,'direct '..i) end
end
local function fails(fn) checks=checks+1;assert(not pcall(fn),'expected invalid transform rejection') end
fails(function() l.MoveToTarget(l.Square()) end)
fails(function() l.Restore(l.Square()):begin() end)
fails(function() l.ApplyMethod(l.Square(),'unknown',{}) end)
fails(function() l.ApplyFunction(function() end,l.Square()):begin() end)
fails(function() l.ApplyPointwiseFunction(function() end,l.Square()):begin() end)
fails(function() l.ApplyMatrix({{1,2,3}},l.Square()) end)
fails(function() l.ApplyMatrix({{1,0},{0,math.huge}},l.Square()) end)
fails(function() l.VMobject():start_new_path(l.ORIGIN):add_line_to(l.RIGHT):start_new_path(l.UP):apply_function(warp) end)
fails(function() l.Circle{pre_function_handle_to_anchor_scale_factor=0}:apply_function(warp) end)
local m=l.Square();local updater=function() end;m:add_updater(updater);local original=m
m:save_state():shift(l.RIGHT):restore();checks=checks+1;assert(m==original and m.updaters[1]==updater,'restore must retain identity/updaters')
local first=m:generate_target();local second=m:generate_target();checks=checks+1;assert(first~=second and second.target==nil,'regenerated target must not retain a target chain')
local copy=m:copy();copy.target:shift(l.UP);eq(m.target:get_center(),{0,0,0},'copied target independence')
local called=0;local a=l.ApplyFunction(function(target) called=called+1;return target:shift(l.RIGHT) end,m)
eq(called,0,'target creation deferred');m:shift(l.DOWN);a:begin();eq(called,1,'target created once at begin');a:finish();eq(m:get_center(),{1,-1,0},'deferred current geometry')
local packed=l.ApplyMethod(m,function(target,unused,delta) assert(unused==nil);target:shift(delta) end,table.pack(nil,l.UP))
packed:begin():finish();eq(m:get_center(),{1,0,0},'unbound method with packed nil arguments')
local group=l.VGroup(l.Square());local child=group[1];group:save_state();group:add(l.Circle():shift(l.RIGHT*2));group:restore()
checks=checks+1;assert(group[1]==child and #group.submobjects==2 and group[2].fill_color[4]==0 and group[2].stroke_color[4]==0,'restore must retain and fade aligned extra children')
print(('PASS: %d transform cases, %d direct operations, %d images; %d checks, max error %.17g'):format(#data.cases,#data.direct,#data.images,checks,max_error))
