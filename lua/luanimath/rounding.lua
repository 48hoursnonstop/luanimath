local G=require('luanimath.geometry')
local M=require('luanimath.mobject')
local V=require('luanimath.vector')
local U=require('luanimath.util')
local B=require('luanimath.bezier')
local C=require('luanimath.color')
local R={}
local function unit(v) local length=V.norm(v);return length>0 and v/length or V() end
local function angle_between(a,b)
    a,b=unit(a),unit(b);return 2*math.atan(V.norm(a-b),V.norm(a+b))
end
function M:put_start_and_end_on(start,finish)
    start,finish=V(start),V(finish)
    local current=self:get_start();local vector=self:get_end()-current
    local closed=self.kind~='Arc' and self.kind~='ArcBetweenPoints' and #self.points>4 and self:is_closed()
    if V.norm(vector)==0 or closed then return self:shift(start-current) end
    local target=finish-start;local cross=V.cross(vector,target)
    local axis=V.norm(cross)>0 and unit(cross) or V(0,0,1)
    return self:scale(V.norm(target)/V.norm(vector),{about_point=current})
        :rotate(angle_between(vector,target),{axis=axis,about_point=current}):shift(start-current)
end
function M:get_arc_center()
    assert(self.kind=='Arc' or self.kind=='Circle' or self.kind=='ArcBetweenPoints','get_arc_center requires circular arc geometry')
    assert(#self.points>=4,'arc has no complete cubic')
    local a,h,k,b=table.unpack(self.points,1,4)
    if V.norm(a-b)==0 then return V(a) end
    local t,u=h-a,k-b
    if a[3]~=0 or b[3]~=0 or t[3]~=0 or u[3]~=0 then self._failed_to_get_center=true;return V() end
    local n,p=V.rotate(t,math.pi/2),V.rotate(u,math.pi/2)
    local line1=V.cross(V(a[1],a[2],1),V(a[1]+n[1],a[2]+n[2],1))
    local line2=V.cross(V(b[1],b[2],1),V(b[1]+p[1],b[2]+p[2],1))
    local hit=V.cross(line1,line2)
    if hit[3]==0 then self._failed_to_get_center=true;return V() end
    return V(hit[1]/hit[3],hit[2]/hit[3],0)
end
function M:move_arc_center_to(point) return self:shift(V(point)-self:get_arc_center()) end
function M:stop_angle()
    local point=self:get_end()-self:get_arc_center();return math.atan(point[2],point[1])%(2*math.pi)
end
function R.ArcBetweenPoints(start,finish,opts)
    start,finish=V(start),V(finish);opts=opts or {}
    assert((opts.num_components or 9)<=100001,'arc exceeds the 100000-curve limit')
    local angle=U.number(opts.angle or math.pi/2,'angle');local radius=opts.radius
    assert(radius~=nil or angle==0 or angle%(2*math.pi)~=0,'complete circular turns require Circle instead of ArcBetweenPoints')
    if radius~=nil then
        U.number(radius,'radius');local sign=radius<0 and -2 or 2;radius=math.abs(radius)
        local half=V.norm(finish-start)/2
        assert(radius>=half and radius>0,'arc radius must be positive in magnitude and at least half the chord length')
        local height=radius-math.sqrt(radius*radius-half*half)
        angle=math.acos(math.max(-1,math.min(1,(radius-height)/radius)))*sign
    end
    local obj=G.Arc(U.merge(opts,{radius=radius or 1,angle=angle}))
    obj.kind='ArcBetweenPoints';obj.angle=angle
    if angle==0 then obj:set_points_as_corners({V(-1,0),V(1,0)}) end
    obj:put_start_and_end_on(start,finish)
    if opts.radius==nil then
        local center=obj:get_arc_center()
        obj.radius=obj._failed_to_get_center and math.huge or V.norm(start-center)
    else obj.radius=radius end
    return obj
end
function R.Polygram(vertex_groups,opts)
    assert(type(vertex_groups)=='table','Polygram requires a sequence of vertex groups')
    local obj=G.VMobject(U.merge({color=C.BLUE},opts));obj.kind='Polygram'
    local points={}
    for _,vertices in ipairs(vertex_groups) do
        assert(type(vertices)=='table' and #vertices>=1,'each vertex group requires at least one vertex')
        for i=1,#vertices do B.append(points,B.line(vertices[i],vertices[i%#vertices+1])) end
    end
    return obj:set_points(points)
end
function M:get_vertices() return self:get_start_anchors() end
function M:get_vertex_groups()
    local groups,current={},{}
    for _,curve in ipairs(B.curves(self.points)) do
        current[#current+1]=V(curve[1])
        if V.close(curve[4],current[1],1e-6) then groups[#groups+1]=current;current={} end
    end
    return groups
end
function M:round_corners(radius,opts)
    radius=radius or .5;opts=opts or {}
    if type(radius)=='number' then U.number(radius,'corner radius');if radius==0 then return self end
    else assert(type(radius)=='table' and #radius>0,'corner radii require a nonempty sequence');for _,r in ipairs(radius) do U.number(r,'corner radius') end end
    local components=U.integer(opts.components_per_rounded_corner or 2,'components_per_rounded_corner',2)
    assert(components<=100001,'rounded corner exceeds the 100000-curve limit')
    local points={}
    for _,vertices in ipairs(self:get_vertex_groups()) do
        local arcs={};local count=#vertices
        assert(count*components+#points/4<=100000,'rounded polygon exceeds the 100000-curve limit')
        assert(type(radius)=='number' or count%#radius==0,'corner radius sequence length must divide the vertex count, following upstream strict iteration')
        for i=1,count do
            local a,b,c=vertices[i],vertices[i%count+1],vertices[(i+1)%count+1]
            local r=type(radius)=='number' and radius or radius[(i-1)%#radius+1]
            local v,w=b-a,c-b;local angle=angle_between(v,w)*(r>0 and 1 or r<0 and -1 or 0)
            local cutoff=r*math.tan(angle/2);local maximum=math.min(V.norm(v),V.norm(w))/2
            cutoff=math.max(-maximum,math.min(maximum,cutoff))
            local cross=V.cross(v,w)[3];local sign=cross>0 and 1 or cross<0 and -1 or 0
            arcs[#arcs+1]=R.ArcBetweenPoints(b-unit(v)*cutoff,b+unit(w)*cutoff,{angle=sign*angle,num_components=components})
        end
        local average=1
        if opts.evenly_distribute_anchors then
            local length,curves=0,0
            for _,arc in ipairs(arcs) do if #arc.points>4 then length=length+arc:get_arc_length();curves=curves+#arc.points/4 end end
            if curves>0 then average=length/curves end
        end
        table.insert(arcs,1,table.remove(arcs))
        for i,arc in ipairs(arcs) do
            for _,p in ipairs(arc.points) do points[#points+1]=V(p) end
            local line=G.Line(arc:get_end(),arcs[i%#arcs+1]:get_start())
            if opts.evenly_distribute_anchors then
                assert(average>0,'cannot distribute anchors with zero average corner length')
                local length=line:get_length()
                -- Clamped corners meet at a point. Do not turn roundoff-sized
                -- gaps into extra curves through ceil(positive epsilon).
                if length>1e-12 then
                    local extra=math.ceil(length/average)
                    assert(extra+#points/4+1<=100000,'rounded polygon subdivisions exceed the 100000-curve limit')
                    line:insert_n_curves(extra)
                end
            end
            for _,p in ipairs(line.points) do points[#points+1]=V(p) end
        end
    end
    return self:set_points(points)
end
function R.RoundedRectangle(opts)
    opts=opts or {};local obj=G.Rectangle(opts);obj.kind='RoundedRectangle';obj.corner_radius=opts.corner_radius or .5
    return obj:round_corners(obj.corner_radius)
end
return R
