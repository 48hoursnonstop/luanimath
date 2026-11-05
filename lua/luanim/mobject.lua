local V=require('luanim.vector')
local C=require('luanim.color')
local B=require('luanim.bezier')
local U=require('luanim.util')
local M={}
M.__index=M

function M.new(opts)
    opts=opts or {}
    local color=opts.color or C.WHITE
    local self=setmetatable({kind='Mobject',points={},submobjects={},updaters={},
        fill_color=C.parse(opts.fill_color or color,opts.fill_opacity or 0),
        stroke_color=C.parse(opts.stroke_color or color,opts.stroke_opacity or 1),
        stroke_width=opts.stroke_width or 4,z_index=opts.z_index or 0,
        joint_type=opts.joint_type or 'miter',cap_style=opts.cap_style or 'butt',
        updating_suspended=false},M)
    U.number(self.stroke_width,'stroke_width');assert(self.stroke_width>=0,'stroke_width must be nonnegative')
    U.number(self.z_index,'z_index')
    return self
end

function M:get_family()
    local out,seen={},{}
    local function walk(m)
        if seen[m] then return end
        seen[m]=true;out[#out+1]=m
        for _,child in ipairs(m.submobjects) do walk(child) end
    end
    walk(self);return out
end
function M:family_members_with_points()
    local out={}
    for _,m in ipairs(self:get_family()) do if #m.points>0 then out[#out+1]=m end end
    return out
end
function M:add(...)
    for _,child in ipairs({...}) do
        assert(getmetatable(child)==M,'expected a Mobject')
        for _,m in ipairs(child:get_family()) do assert(m~=self,'Mobject hierarchy cannot contain cycles') end
        if self.kind=='VGroup' then assert(child.is_vector,'VGroup only accepts VMobjects') end
        local found=false
        for _,m in ipairs(self.submobjects) do if m==child then found=true end end
        if not found then self.submobjects[#self.submobjects+1]=child end
    end
    return self
end
function M:remove(...)
    local remove={};for _,m in ipairs({...}) do remove[m]=true end
    local out={};for _,m in ipairs(self.submobjects) do if not remove[m] then out[#out+1]=m end end
    self.submobjects=out;return self
end
function M:copy() return U.copy(self) end
function M:get_all_points()
    local out={}
    local function visit(m)
        for _,p in ipairs(m.points) do out[#out+1]=V(p) end
        for _,child in ipairs(m.submobjects) do visit(child) end
    end
    visit(self)
    return out
end
function M:get_points_defining_boundary()
    if not self.is_vector then return self:get_all_points() end
    local points={}
    for _,m in ipairs(self:get_family()) do
        for i=1,#m.points,4 do points[#points+1]=V(m.points[i]);points[#points+1]=V(m.points[i+3]) end
    end
    return points
end
function M:get_critical_point(direction)
    direction=V(direction or {})
    local points=self:get_points_defining_boundary()
    if #points==0 then return V() end
    local low,high=V(points[1]),V(points[1])
    for _,p in ipairs(points) do for d=1,3 do low[d]=math.min(low[d],p[d]);high[d]=math.max(high[d],p[d]) end end
    local out=V()
    for d=1,3 do out[d]=direction[d]>0 and high[d] or (direction[d]<0 and low[d] or (low[d]+high[d])/2) end
    return out
end
function M:get_center() return self:get_critical_point(V()) end
function M:get_left() return self:get_critical_point(V(-1,0,0)) end
function M:get_right() return self:get_critical_point(V(1,0,0)) end
function M:get_top() return self:get_critical_point(V(0,1,0)) end
function M:get_bottom() return self:get_critical_point(V(0,-1,0)) end
function M:length_over_dim(dim)
    U.integer(dim,'dimension',1);assert(dim<=3,'dimension must be 1, 2, or 3')
    local points=self:get_all_points();if #points==0 then return 0 end
    local low,high=points[1][dim],points[1][dim]
    for _,p in ipairs(points) do low=math.min(low,p[dim]);high=math.max(high,p[dim]) end
    return high-low
end
function M:get_width() return self:length_over_dim(1) end
function M:get_height() return self:length_over_dim(2) end
function M:get_depth() return self:length_over_dim(3) end
function M:apply_points_function(fn)
    for _,m in ipairs(self:family_members_with_points()) do
        for i,p in ipairs(m.points) do m.points[i]=V(fn(V(p))) end
    end
    return self
end
function M:shift(...)
    local sum=V();for _,p in ipairs({...}) do sum=sum+V(p) end
    return self:apply_points_function(function(p) return p+sum end)
end
function M:move_to(target,opts)
    opts=opts or {};local edge=opts.aligned_edge or V()
    local p=target.get_critical_point and target:get_critical_point(edge) or V(target)
    local delta=p-self:get_critical_point(edge)
    local mask=opts.coor_mask or {1,1,1}
    return self:shift(V(delta[1]*mask[1],delta[2]*mask[2],delta[3]*mask[3]))
end
local function about(self,opts)
    opts=opts or {};return opts.about_point and V(opts.about_point) or self:get_critical_point(opts.about_edge or V())
end
function M:scale(factor,opts)
    U.number(factor,'scale factor');local p=about(self,opts)
    return self:apply_points_function(function(v) return p+(v-p)*factor end)
end
function M:stretch(factor,dim,opts)
    U.number(factor,'stretch factor');U.integer(dim,'dimension',1);assert(dim<=3,'dimension must be 1, 2, or 3')
    local p=about(self,opts)
    return self:apply_points_function(function(v) v[dim]=p[dim]+factor*(v[dim]-p[dim]);return v end)
end
function M:rotate(angle,opts)
    U.number(angle,'angle');opts=opts or {};local p=about(self,opts)
    local axis=V.normalize(opts.axis or V(0,0,1))
    return self:apply_points_function(function(v) return p+V.rotate(v-p,angle,axis) end)
end
function M:apply_matrix(matrix,opts)
    assert(type(matrix)=='table' and (#matrix==2 or #matrix==3),'matrix must be 2x2 or 3x3')
    local n=#matrix
    for _,row in ipairs(matrix) do assert(type(row)=='table' and #row==n,'matrix must be square');for _,x in ipairs(row) do U.number(x,'matrix entry') end end
    local p=(opts and opts.about_point and V(opts.about_point)) or V()
    return self:apply_points_function(function(v)
        local d=v-p;local r=V(d)
        for i=1,n do r[i]=0;for j=1,n do r[i]=r[i]+matrix[i][j]*d[j] end end
        return p+r
    end)
end
function M:align_to(target,direction)
    direction=V(direction);local p=target.get_critical_point and target:get_critical_point(direction) or V(target)
    local delta=p-self:get_critical_point(direction)
    for i=1,3 do if direction[i]==0 then delta[i]=0 end end
    return self:shift(delta)
end
function M:next_to(target,direction,opts)
    direction=V(direction or {1,0,0});opts=opts or {}
    local edge=V(opts.aligned_edge or {})
    local p=target.get_critical_point and target:get_critical_point(edge+direction) or V(target)
    local delta=p-self:get_critical_point(edge-direction)+direction*(opts.buff or 0.25)
    return self:shift(delta)
end
function M:arrange(direction,opts)
    opts=opts or {};direction=direction or V(1,0,0)
    for i=2,#self.submobjects do self.submobjects[i]:next_to(self.submobjects[i-1],direction,opts) end
    if opts.center~=false then self:move_to(V()) end
    return self
end
function M:set_fill(color,opacity,opts)
    local family=opts and opts.family==false and {self} or self:get_family()
    for _,m in ipairs(family) do m.fill_color=C.parse(color or m.fill_color,opacity==nil and m.fill_color[4] or opacity) end
    return self
end
function M:set_stroke(color,width,opacity,opts)
    if width~=nil then U.number(width,'stroke_width');assert(width>=0,'stroke_width must be nonnegative') end
    local family=opts and opts.family==false and {self} or self:get_family()
    for _,m in ipairs(family) do
        m.stroke_color=C.parse(color or m.stroke_color,opacity==nil and m.stroke_color[4] or opacity)
        if width~=nil then m.stroke_width=width end
    end
    return self
end
function M:set_color(color)
    self:set_fill(color);self:set_stroke(color);return self
end
function M:set_opacity(opacity) self:set_fill(nil,opacity);self:set_stroke(nil,nil,opacity);return self end
function M:fade(darkness)
    U.number(darkness,'darkness');assert(darkness>=0 and darkness<=1,'darkness must be in [0,1]')
    for _,m in ipairs(self:get_family()) do m.fill_color[4]=m.fill_color[4]*(1-darkness);m.stroke_color[4]=m.stroke_color[4]*(1-darkness) end
    return self
end
function M:set_z_index(z,opts)
    U.number(z,'z_index')
    for _,m in ipairs(opts and opts.family==false and {self} or self:get_family()) do m.z_index=z end
    return self
end
function M:set_points(points)
    assert(type(points)=='table','points must be a table')
    local out={};for i,p in ipairs(points) do out[i]=V(p) end
    if self.is_vector then assert(#out%4==0,'VMobject requires four points per cubic') end
    self.points=out;return self
end
function M:set_points_as_corners(points)
    assert(self.is_vector,'corners require a VMobject');assert(#points>=2,'at least two corners required')
    local out={};for i=1,#points-1 do B.append(out,B.line(points[i],points[i+1])) end
    return self:set_points(out)
end
function M:get_start() assert(#self.points>0,'Mobject has no points');return V(self.points[1]) end
function M:get_end()
    if self.tip then return self.tip:get_start() end
    assert(#self.points>0,'Mobject has no points');return V(self.points[#self.points])
end
function M:get_length() return V.norm(self:get_end()-self:get_start()) end
function M:get_angle() local d=self:get_end()-self:get_start();return math.atan(d[2],d[1]) end
function M:get_num_curves() assert(self.is_vector,'curves require VMobject');return #self.points/4 end
function M:get_arc_length(samples)
    local out=0;for _,c in ipairs(B.curves(self.points)) do out=out+B.length(c,samples) end;return out
end
function M:point_from_proportion(alpha)
    U.number(alpha,'alpha');assert(alpha>=0 and alpha<=1,'alpha must be in [0,1]')
    local curves=B.curves(self.points);assert(#curves>0,'VMobject has no curves')
    if alpha==1 then return V(self.points[#self.points]) end
    local lengths,total={},0
    for i,c in ipairs(curves) do lengths[i]=B.length(c);total=total+lengths[i] end
    local target,current=alpha*total,0
    for i,c in ipairs(curves) do
        if current+lengths[i]>=target then return B.point(c,lengths[i]==0 and 0 or (target-current)/lengths[i]) end
        current=current+lengths[i]
    end
    return V(self.points[#self.points])
end
function M:pointwise_become_partial(other,a,b) return self:set_points(B.partial_path(other.points,a,b)) end
function M:get_subcurve(a,b) return self:copy():pointwise_become_partial(self,a,b) end
function M:reverse_direction()
    local points={};for i=#self.points,1,-1 do points[#points+1]=V(self.points[i]) end
    return self:set_points(points)
end
function M:get_subpaths() return B.subpaths(self.points) end
function M:set_points_smoothly(points) return self:set_points(B.smooth(points)) end
function M:make_smooth()
    for _,m in ipairs(self:family_members_with_points()) do
        local result={}
        for _,path in ipairs(B.subpaths(m.points)) do
            local anchors={};for i=1,#path,4 do anchors[#anchors+1]=path[i] end
            anchors[#anchors+1]=path[#path]
            for _,p in ipairs(B.smooth(anchors)) do result[#result+1]=p end
        end
        m.points=result
    end
    return self
end
function M:become(other)
    self.points=U.copy(other.points)
    self.fill_color=U.copy(other.fill_color);self.stroke_color=U.copy(other.stroke_color)
    self.stroke_width=other.stroke_width
    for i,child in ipairs(other.submobjects) do
        if self.submobjects[i] then self.submobjects[i]:become(child) else self.submobjects[i]=child:copy() end
    end
    for i=#self.submobjects,#other.submobjects+1,-1 do self.submobjects[i]=nil end
    return self
end
function M:add_updater(fn,opts)
    assert(type(fn)=='function','updater must be a function')
    self.updaters[#self.updaters+1]=fn
    if opts and opts.call_updater then fn(self,0) end
    return self
end
function M:remove_updater(fn)
    for i=#self.updaters,1,-1 do if self.updaters[i]==fn then table.remove(self.updaters,i) end end
    return self
end
function M:clear_updaters(opts)
    for _,m in ipairs(opts and opts.recursive==false and {self} or self:get_family()) do m.updaters={} end
    return self
end
function M:update(dt)
    U.number(dt or 0,'dt')
    if self.updating_suspended then return self end
    for _,fn in ipairs(self.updaters) do fn(self,dt or 0) end
    for _,child in ipairs(self.submobjects) do child:update(dt or 0) end
    return self
end
function M:animate(opts)
    local A=require('luanim.animation')
    return A.builder(self,opts)
end
function M:get_value() assert(self.kind=='ValueTracker','get_value requires ValueTracker');return self.points[1][1] end
function M:set_value(value) assert(self.kind=='ValueTracker','set_value requires ValueTracker');self.points[1][1]=U.number(value,'value');return self end
function M:increment_value(value) return self:set_value(self:get_value()+value) end

return setmetatable(M,{__call=function(_,opts) return M.new(opts) end})
