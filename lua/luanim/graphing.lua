local G=require('luanim.geometry')
local M=require('luanim.mobject')
local V=require('luanim.vector')
local B=require('luanim.bezier')
local U=require('luanim.util')
local C=require('luanim.color')
local Config=require('luanim.config')
local P={}
local function range(r,default_step)
    assert(type(r)=='table' and (#r==2 or #r==3),'range requires {minimum,maximum[,step]}')
    local low,high,step=U.number(r[1],'minimum'),U.number(r[2],'maximum'),U.number(r[3] or default_step,'step')
    assert(high>low and step>0,'range requires maximum > minimum and step > 0')
    assert((high-low)/step<100000,'range requires too many samples')
    return {low,high,step}
end
local function origin_shift(r) return r[1]>0 and r[1] or r[2]<0 and r[2] or 0 end

function M:add_tip(opts)
    opts=opts or {};assert(not self.tip,'tip already present')
    local start,finish=self:get_start(),self:get_end();local direction=V.normalize(finish-start)
    assert(math.abs(direction[3])<1e-10,'3D line tips are not implemented')
    local length=U.number(opts.tip_length or 0.35,'tip_length');local width=U.number(opts.tip_width or 0.35,'tip_width')
    assert(length>0 and width>0 and length<self:get_length(),'tip dimensions must be positive and length smaller than line')
    local base=finish-direction*length;local perpendicular=V(-direction[2],direction[1],0)
    local tip=G.Polygon({finish,base+perpendicular*(width/2),base-perpendicular*(width/2)},
        {color=self.stroke_color,fill_opacity=1,stroke_width=opts.stroke_width or 0})
    tip.kind='ArrowTriangleFilledTip';self:set_points(B.line(start,base));self:add(tip);self.tip=tip
    return self
end
function M:number_to_point(number)
    assert(self.kind=='NumberLine','number_to_point requires NumberLine')
    if type(number)=='table' then local out={};for i,x in ipairs(number) do out[i]=self:number_to_point(x) end;return out end
    U.number(number,'number')
    return V.lerp(self:get_start(),self:get_end(),(number-self.x_range[1])/(self.x_range[2]-self.x_range[1]))
end
function M:point_to_number(point)
    assert(self.kind=='NumberLine','point_to_number requires NumberLine')
    if type(point[1])=='table' then local out={};for i,p in ipairs(point) do out[i]=self:point_to_number(p) end;return out end
    local d=self:get_end()-self:get_start()
    return self.x_range[1]+V.dot(V(point)-self:get_start(),d)/V.dot(d,d)*(self.x_range[2]-self.x_range[1])
end
M.n2p=M.number_to_point;M.p2n=M.point_to_number
function M:get_tick_range()
    assert(self.kind=='NumberLine','get_tick_range requires NumberLine')
    local low,high,step=table.unpack(self.x_range)
    local extra=self.include_tip and 0 or 1e-6
    local values={}
    local function arange(start,finish,sign)
        local i=0
        while start+i*step<finish do values[#values+1]=(start+i*step)*(sign or 1);i=i+1 end
    end
    if (low<high and high<0) or (high>low and low>0) then arange(low,high+extra)
    else
        local start=self.exclude_origin_tick and step or 0
        arange(start,math.abs(low)+1e-6,-1);arange(start,high+extra)
    end
    table.sort(values);local unique={}
    for _,x in ipairs(values) do if #unique==0 or math.abs(x-unique[#unique])>1e-10 then unique[#unique+1]=x end end
    return unique
end
function M:get_tick(x,size)
    size=size or self.tick_size
    local m=G.Line(V(0,-size,0),V(0,size,0),{stroke_color=self.stroke_color,stroke_width=self.stroke_width})
    return m:rotate(self:get_angle()):move_to(self:number_to_point(x))
end
function P.NumberLine(opts)
    opts=opts or {};assert(not opts.include_numbers,'NumberLine numeric labels require the mathematical text subsystem')
    assert(not opts.scaling,'nonlinear NumberLine scaling is not implemented')
    local r=range(opts.x_range or {-7,7,1},1)
    local length=opts.length or (r[2]-r[1])*(opts.unit_size or 1)
    U.number(length,'length');assert(length>0,'length must be positive')
    local m=G.Line(V(-length/2,0,0),V(length/2,0,0),U.merge({stroke_width=2},opts))
    m.kind='NumberLine';m.x_range=r;m.tick_size=opts.tick_size or .1;m.include_tip=not not opts.include_tip
    m.exclude_origin_tick=not not opts.exclude_origin_tick
    if m.include_tip then m:add_tip{tip_length=opts.tip_height,tip_width=opts.tip_width,stroke_width=m.stroke_width} end
    m.ticks=G.VGroup()
    if opts.include_ticks~=false then
        for _,x in ipairs(m:get_tick_range()) do
            local size=m.tick_size
            for _,elongated in ipairs(opts.numbers_with_elongated_ticks or {}) do
                if math.abs(x-elongated)<=1e-8+1e-5*math.abs(elongated) then size=size*(opts.longer_tick_multiple or 2);break end
            end
            m.ticks:add(m:get_tick(x,size))
        end
        m:add(m.ticks)
    end
    return m:rotate(opts.rotation or 0)
end
function M:coords_to_point(x,y)
    assert(self.kind=='Axes','coords_to_point requires Axes')
    if type(x)=='table' then
        if type(x[1])=='table' then local out={};for i,p in ipairs(x) do out[i]=self:coords_to_point(p[1],p[2]) end;return out end
        x,y=x[1],x[2]
    end
    local origin=self.x_axis:number_to_point(origin_shift(self.x_axis.x_range))
    return self.x_axis:number_to_point(x)+self.y_axis:number_to_point(y or 0)-origin
end
M.c2p=M.coords_to_point
function M:point_to_coords(point)
    assert(self.kind=='Axes','point_to_coords requires Axes')
    if type(point[1])=='table' then local out={};for i,p in ipairs(point) do out[i]=self:point_to_coords(p) end;return out end
    return {self.x_axis:point_to_number(point),self.y_axis:point_to_number(point)}
end
M.p2c=M.point_to_coords
function P.Axes(opts)
    opts=opts or {};local xr,yr=range(opts.x_range or {-7,7,1},1),range(opts.y_range or {-4,4,1},1)
    local common=U.merge({include_tip=opts.tips~=false,exclude_origin_tick=true},opts.axis_config)
    local x= P.NumberLine(U.merge(U.merge(common,opts.x_axis_config),{x_range=xr,length=opts.x_length or 12}))
    local y= P.NumberLine(U.merge(U.merge(U.merge(common,{rotation=math.pi/2}),opts.y_axis_config),{x_range=yr,length=opts.y_length or 6}))
    x:shift(-x:number_to_point(origin_shift(xr)));y:shift(-y:number_to_point(origin_shift(yr)))
    local m=G.VGroup(x,y);m.kind='Axes';m.x_range=xr;m.y_range=yr;m.x_axis=x;m.y_axis=y
    m.axes=G.VGroup(x,y)
    return m:shift(-m:coords_to_point((xr[1]+xr[2])/2,(yr[1]+yr[2])/2))
end
function P.ParametricFunction(fn,opts)
    assert(type(fn)=='function','ParametricFunction requires a function');opts=opts or {}
    assert(not opts.scaling and not opts.use_vectorized,'custom scaling and vectorized functions are not implemented')
    local r=range(opts.t_range or {0,1,.01},.01)
    local dt=U.number(opts.dt or 1e-8,'dt');assert(dt>0,'dt must be positive')
    local boundaries={r[1],r[2]}
    for _,t in ipairs(opts.discontinuities or {}) do
        U.number(t,'discontinuity')
        if t>=r[1] and t<=r[2] then boundaries[#boundaries+1]=t-dt;boundaries[#boundaries+1]=t+dt end
    end
    table.sort(boundaries)
    local points={}
    for i=1,#boundaries,2 do
        local low,high=boundaries[i],boundaries[i+1]
        if high>=low then
            local anchors={};local n=math.ceil((high-low)/r[3])
            for j=0,n-1 do anchors[#anchors+1]=V(fn(low+j*r[3])) end
            anchors[#anchors+1]=V(fn(high))
            if #anchors>=2 then
                local path={}
                if opts.use_smoothing==false then for j=1,#anchors-1 do B.append(path,B.line(anchors[j],anchors[j+1])) end
                else path=B.smooth(anchors) end
                for _,p in ipairs(path) do points[#points+1]=p end
            end
        end
    end
    local m=G.VMobject(opts);m.kind='ParametricFunction';m.function_fn=fn;m.t_range=r
    return m:set_points(points)
end
function P.FunctionGraph(fn,opts)
    opts=opts or {};return P.ParametricFunction(function(x) return V(x,fn(x),0) end,
        U.merge({color=C.YELLOW,t_range=opts.x_range or {-Config.defaults.frame_width/2,Config.defaults.frame_width/2,.01}},opts))
end
function M:plot(fn,opts)
    assert(self.kind=='Axes','plot requires Axes');opts=opts or {}
    local r=opts.x_range or self.x_range
    local step=(#r>=3 and opts.x_range) and r[3] or self.x_range[3]/10
    local graph=P.ParametricFunction(function(x) return self:coords_to_point(x,fn(x)) end,
        U.merge(opts,{t_range={r[1],r[2],step}}))
    graph.underlying_function=fn;return graph
end
function M:get_axes() assert(self.kind=='Axes','get_axes requires Axes');return self.axes end
function M:get_origin() return self:coords_to_point(0,0) end
function M:get_tick_marks() assert(self.kind=='NumberLine','get_tick_marks requires NumberLine');return self.ticks end
function M:get_unit_size() assert(self.kind=='NumberLine','get_unit_size requires NumberLine');return self:get_length()/(self.x_range[2]-self.x_range[1]) end
function M:get_function() assert(self.function_fn,'requires parametric function');return self.function_fn end
function M:get_point_from_function(t) return V(self:get_function()(U.number(t,'t'))) end
function P.always_redraw(fn)
    assert(type(fn)=='function','always_redraw requires a function')
    local m=fn();assert(m and m.get_family,'always_redraw function must return a Mobject')
    return m:add_updater(function(object) object:become(fn()) end)
end
return P
