local M=require('luanimath.mobject')
local V=require('luanimath.vector')
local B=require('luanimath.bezier')
local U=require('luanimath.util')
local C=require('luanimath.color')
local G={}
function G.VMobject(opts) local m=M(opts);m.kind='VMobject';m.is_vector=true;return m end
function G.Group(...)
    local m=M();m.kind='Group';return m:add(...)
end
function G.VGroup(...)
    local m=G.VMobject();m.kind='VGroup';return m:add(...)
end
function G.Arc(opts)
    opts=opts or {};local m=G.VMobject(opts);m.kind='Arc'
    local r=U.number(opts.radius or 1,'radius')
    local angle=U.number(opts.angle or math.pi/2,'angle')
    local start=U.number(opts.start_angle or 0,'start_angle')
    local n=U.integer(opts.num_components or 9,'num_components',2)
    local center=V(opts.arc_center or {})
    local delta=angle/(n-1);local factor=4/3*math.tan(delta/4)
    local points={}
    for i=0,n-2 do
        local a,b=start+i*delta,start+(i+1)*delta
        local p,q=V(math.cos(a),math.sin(a),0),V(math.cos(b),math.sin(b),0)
        local h1=p+V(-p[2],p[1],0)*factor
        local h2=q-V(-q[2],q[1],0)*factor
        B.append(points,{p*r+center,h1*r+center,h2*r+center,q*r+center})
    end
    return m:set_points(points)
end
function G.Circle(opts)
    local m=G.Arc(U.merge({angle=2*math.pi,color=C.RED},opts));m.kind='Circle';return m
end
function G.Dot(point,opts)
    local m=G.Circle(U.merge({radius=0.08,stroke_width=0,fill_opacity=1,color=C.WHITE},opts));m.kind='Dot'
    return m:shift(V(point or {}))
end
function G.Ellipse(opts)
    opts=opts or {};local m=G.Circle(opts);m.kind='Ellipse'
    return m:stretch((opts.width or 2)/2,1):stretch((opts.height or 1)/2,2)
end
function G.Line(start,finish,opts)
    opts=opts or {};assert(not opts.path_arc or opts.path_arc==0,'curved Line is not implemented; use Arc')
    start,finish=V(start or {-1,0,0}),V(finish or {1,0,0})
    local buff=U.number(opts.buff or 0,'buff');assert(buff>=0,'buff must be nonnegative')
    local delta=finish-start
    if V.norm(delta)>2*buff then local unit=V.normalize(delta);start=start+unit*buff;finish=finish-unit*buff end
    local m=G.VMobject(opts);m.kind='Line';return m:set_points(B.line(start,finish))
end
function G.Polygon(vertices,opts)
    assert(type(vertices)=='table' and #vertices>=3,'Polygon requires at least three vertices')
    local m=G.VMobject(U.merge({color=C.BLUE},opts));m.kind='Polygon'
    local corners={};for i,p in ipairs(vertices) do corners[i]=V(p) end
    corners[#corners+1]=V(corners[1]);return m:set_points_as_corners(corners)
end
function G.Rectangle(opts)
    opts=opts or {};local w,h=U.number(opts.width or 4,'width'),U.number(opts.height or 2,'height')
    local m=G.Polygon({{w/2,h/2,0},{-w/2,h/2,0},{-w/2,-h/2,0},{w/2,-h/2,0}},U.merge({color=C.WHITE},opts));m.kind='Rectangle';return m
end
function G.Square(opts)
    opts=opts or {};local side=opts.side_length or 2
    local m=G.Rectangle(U.merge(opts,{width=side,height=side}));m.kind='Square';return m
end
function G.RegularPolygon(opts)
    opts=opts or {};local n=U.integer(opts.n or 6,'n',3)
    local start=opts.start_angle or (n%2==0 and 0 or math.pi/2)
    local radius=U.number(opts.radius or 1,'radius');local vertices={}
    for i=0,n-1 do vertices[#vertices+1]={radius*math.cos(start+i*2*math.pi/n),radius*math.sin(start+i*2*math.pi/n),0} end
    local m=G.Polygon(vertices,opts);m.kind='RegularPolygon';return m
end
function G.Triangle(opts)
    local m=G.RegularPolygon(U.merge(opts,{n=3}));m.kind='Triangle';return m
end
function G.CubicBezier(a,b,c,d,opts)
    local m=G.VMobject(opts);m.kind='CubicBezier';return m:set_points({a,b,c,d})
end
function G.ValueTracker(value)
    local m=M();m.kind='ValueTracker';m.points={V(U.number(value or 0,'value'),0,0)};return m
end
function G.VectorizedPoint(location,opts)
    opts=opts or {};local m=G.VMobject(U.merge({color=C.BLACK,fill_opacity=0,stroke_width=0},opts))
    m.kind='VectorizedPoint';m.artificial_width=opts.artificial_width or .01;m.artificial_height=opts.artificial_height or .01
    return m:set_points({V(location or {})})
end
return G
