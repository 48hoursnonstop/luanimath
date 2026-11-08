local V=require('luanim.vector')
local C=require('luanim.color')
local B=require('luanim.bezier')
local U=require('luanim.util')
local M={}
M.__index=function(self,key)
    if type(key)=='number' then
        if key<0 then key=#self+key+1 end
        if key<1 or key%1~=0 then return nil end
        if #self.points>0 then return key==1 and self or self.submobjects[key-1] end
        return self.submobjects[key]
    end
    if key=='font_size' and rawget(self,'_font_size') then return self:get_font_size() end
    return M[key]
end
M.__len=function(self) return #self.submobjects+(#self.points>0 and 1 or 0) end
M.__newindex=function(self,key,value)
    if key=='font_size' and rawget(self,'_font_size') then self:set_font_size(value) else rawset(self,key,value) end
end

function M.new(opts)
    opts=opts or {}
    local color=opts.color or C.WHITE
    local self=setmetatable({kind='Mobject',points={},submobjects={},updaters={},
        fill_color=C.parse(opts.fill_color or color,opts.fill_opacity or 0),
        stroke_color=C.parse(opts.stroke_color or color,opts.stroke_opacity or 1),
        stroke_width=opts.stroke_width or 4,z_index=opts.z_index or 0,
        joint_type=opts.joint_type or 'miter',cap_style=opts.cap_style or 'butt',
        shade_in_3d=not not opts.shade_in_3d,
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
function M:split()
    local items={};for _,m in ipairs(self) do items[#items+1]=m end;return items
end
function M:slice(first,last,step)
    local n=#self;step=step or 1;U.number(step,'slice step');assert(step%1==0 and step~=0,'slice step must be a nonzero integer')
    first=first or (step>0 and 1 or n);last=last or (step>0 and n or 1)
    U.number(first,'slice start');U.number(last,'slice end');assert(first%1==0 and last%1==0,'slice indices must be integers')
    if first<0 then first=n+first+1 end;if last<0 then last=n+last+1 end
    if step>0 then first=math.max(1,first);last=math.min(n,last) else first=math.min(n,first);last=math.max(1,last) end
    local group=M();group.is_vector=self.is_vector;group.kind=self.is_vector and 'VGroup' or 'Group'
    for i=first,last,step do group:add(self[i]) end
    return group
end
function M:invert(opts)
    if opts and opts.recursive then for _,child in ipairs(self.submobjects) do child:invert(opts) end end
    local a=self.submobjects;for i=1,math.floor(#a/2) do a[i],a[#a-i+1]=a[#a-i+1],a[i] end
    return self
end
function M:get_font_size()
    assert(self._font_size and self.initial_height and self.initial_height>0,'font size requires nonempty Text')
    return self._font_size*self:get_height()/self.initial_height
end
function M:set_font_size(size)
    U.number(size,'font_size');assert(size>0,'font_size must be positive')
    return self:scale(size/self:get_font_size())
end
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
        for i=1,#m.points,4 do
            points[#points+1]=V(m.points[i]);if m.points[i+3] then points[#points+1]=V(m.points[i+3]) end
        end
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
function M:get_width() return self.kind=='VectorizedPoint' and self.artificial_width or self:length_over_dim(1) end
function M:get_height() return self.kind=='VectorizedPoint' and self.artificial_height or self:length_over_dim(2) end
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
function M:set_color(color,opts)
    self:set_fill(color,nil,opts);self:set_stroke(color,nil,nil,opts);return self
end
function M:set_color_by_gradient(...)
    local colors={...};assert(#colors>0,'gradient needs at least one color')
    if #colors==1 then return self:set_color(colors[1]) end
    local family=self:family_members_with_points();local gradient=C.color_gradient(colors,#family)
    for i,m in ipairs(family) do m:set_color(gradient[i],{family=false}) end
    return self
end
M.set_submobject_colors_by_gradient=M.set_color_by_gradient
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
    if self.is_vector then assert(#out%4==0 or #out%4==1,'VMobject requires complete cubics and an optional pending anchor') end
    self.points=out;return self
end
function M:set_points_as_corners(points)
    assert(self.is_vector,'corners require a VMobject');assert(#points>=1,'at least one corner required')
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
function M:get_num_curves() assert(self.is_vector,'curves require VMobject');return math.floor(#self.points/4) end
function M:get_arc_length(samples)
    local out=0;for _,c in ipairs(B.curves(self.points)) do out=out+B.length(c,samples) end;return out
end
function M:point_from_proportion(alpha)
    U.number(alpha,'alpha');assert(alpha>=0 and alpha<=1,'alpha must be in [0,1]')
    assert(#self.points>0,'VMobject has no points')
    if alpha==1 then return V(self.points[#self.points]) end
    local curves=B.curves(self.points);assert(#curves>0,'VMobject has no curves')
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
function M:get_subcurve(a,b)
    local copy=self:copy()
    if self:is_closed() and a>b then
        copy:pointwise_become_partial(self,a,1)
        return copy:append_points(B.partial_path(self.points,0,b))
    end
    return copy:pointwise_become_partial(self,a,b)
end
function M:reverse_direction()
    local points={};for i=#self.points,1,-1 do points[#points+1]=V(self.points[i]) end
    return self:set_points(points)
end
function M:get_subpaths() return B.subpaths(self.points) end
function M:clear_points() self.points={};return self end
function M:append_points(points)
    local result=U.copy(self.points);for _,p in ipairs(points) do result[#result+1]=V(p) end
    return self:set_points(result)
end
function M:has_new_path_started() return #self.points%4==1 end
function M:get_last_point() assert(#self.points>0,'VMobject has no points');return V(self.points[#self.points]) end
function M:start_new_path(point)
    assert(self.is_vector,'path requires VMobject');local result=U.copy(self.points)
    local residue=#result%4
    if residue~=0 then local anchor=result[#result-residue+1];for _=1,4-residue do result[#result+1]=V(anchor) end end
    result[#result+1]=V(point);return self:set_points(result)
end
function M:add_cubic_bezier_curve(anchor1,handle1,handle2,anchor2)
    assert(#self.points%4==0,'finish the pending curve before adding a full cubic')
    return self:append_points({anchor1,handle1,handle2,anchor2})
end
function M:add_cubic_bezier_curve_to(handle1,handle2,anchor)
    local last=self:get_last_point()
    if self:has_new_path_started() then return self:append_points({handle1,handle2,anchor}) end
    return self:append_points({last,handle1,handle2,anchor})
end
function M:add_quadratic_bezier_curve_to(handle,anchor)
    handle,anchor=V(handle),V(anchor)
    return self:add_cubic_bezier_curve_to(handle*(2/3)+self:get_last_point()/3,handle*(2/3)+anchor/3,anchor)
end
function M:add_line_to(point)
    local last=self:get_last_point();point=V(point)
    return self:add_cubic_bezier_curve_to(V.lerp(last,point,1/3),V.lerp(last,point,2/3),point)
end
function M:add_points_as_corners(points) for _,p in ipairs(points) do self:add_line_to(p) end;return self end
function M:add_subpath(points) assert(#points%4==0,'subpath requires complete cubics');return self:append_points(points) end
function M:is_closed() return #self.points>0 and V.close(self.points[1],self.points[#self.points],1e-6) end
function M:close_path()
    assert(#self.points>0,'VMobject has no points')
    if not self:is_closed() then local paths=self:get_subpaths();assert(#paths>0,'complete a curve before closing');self:add_line_to(paths[#paths][1]) end
    return self
end
function M:get_start_anchors() local result={};for i=1,#self.points,4 do result[#result+1]=V(self.points[i]) end;return result end
function M:get_end_anchors() local result={};for i=4,#self.points,4 do result[#result+1]=V(self.points[i]) end;return result end
function M:get_anchors()
    if #self.points==1 then return U.copy(self.points) end
    local result={};for i=1,#self.points-3,4 do result[#result+1]=V(self.points[i]);result[#result+1]=V(self.points[i+3]) end
    return result
end
function M:insert_n_curves(n)
    U.integer(n,'curve count',0)
    local pending=self:has_new_path_started() and self:get_last_point() or nil
    local points=U.copy(self.points);if pending then table.remove(points) end
    if #points==0 then
        if pending and n>0 then for _=1,4*n do points[#points+1]=V(pending) end end
    else points=B.remap(points,#points/4+n) end
    if pending then points[#points+1]=pending end
    return self:set_points(points)
end
function M:get_point_mobject(center)
    assert(self.is_vector,'point mobjects currently require VMobject')
    local point=require('luanim.geometry').VectorizedPoint(center or self:get_center())
    point.fill_color=U.copy(self.fill_color);point.stroke_color=U.copy(self.stroke_color);point.stroke_width=self.stroke_width
    return point
end
function M:get_location() assert(self.kind=='VectorizedPoint','get_location requires VectorizedPoint');return V(self.points[1]) end
function M:set_location(point) assert(self.kind=='VectorizedPoint','set_location requires VectorizedPoint');return self:set_points({V(point)}) end
function M:push_self_into_submobjects()
    local copy=self:copy();copy.submobjects={};self:clear_points();return self:add(copy)
end
function M:add_n_more_submobjects(n)
    U.integer(n,'submobject count',0);if n==0 then return self end
    local current=#self.submobjects
    if current==0 then for _=1,n do self.submobjects[#self.submobjects+1]=self:get_point_mobject() end;return self end
    local counts={};for i=1,current do counts[i]=0 end
    for i=0,current+n-1 do local j=math.floor(i*current/(current+n))+1;counts[j]=counts[j]+1 end
    local result={}
    for i,child in ipairs(self.submobjects) do
        result[#result+1]=child
        for _=2,counts[i] do result[#result+1]=child:copy():fade(1) end
    end
    self.submobjects=result;return self
end
function M:align_points(other)
    if #self.points==#other.points then return self end
    assert(self.is_vector and other.is_vector,'point alignment currently requires VMobjects')
    for _,m in ipairs({self,other}) do
        if #m.points==0 then m:start_new_path(m:get_center()) end
        if m:has_new_path_started() then m:add_line_to(m:get_last_point()) end
    end
    local a,b=self:get_subpaths(),other:get_subpaths()
    local function nth(paths,index)
        local path=paths[index]
        if not path then local p=#paths>0 and paths[#paths][#paths[#paths]] or V();return {V(p),V(p),V(p),V(p)} end
        path=U.copy(path)
        while #path>4 do
            local same=true;for i=#path-3,#path do if not V.close(path[i],path[#path-4],1e-6) then same=false;break end end
            if not same then break end
            for _=1,4 do table.remove(path) end
        end
        return path
    end
    local left,right={},{}
    for i=1,math.max(#a,#b) do
        local x,y=nth(a,i),nth(b,i);local n=math.max(#x,#y)/4
        for _,p in ipairs(B.remap(x,n)) do left[#left+1]=p end
        for _,p in ipairs(B.remap(y,n)) do right[#right+1]=p end
    end
    self.points=left;other.points=right;return self
end
function M:align_data(other,opts)
    if #self.points==0 and #other.points>0 then other:push_self_into_submobjects() end
    if #other.points==0 and #self.points>0 then self:push_self_into_submobjects() end
    local a,b=#self.submobjects,#other.submobjects
    self:add_n_more_submobjects(math.max(0,b-a));other:add_n_more_submobjects(math.max(0,a-b))
    if not (opts and opts.skip_point_alignment) then self:align_points(other) end
    for i,child in ipairs(self.submobjects) do child:align_data(other.submobjects[i]) end
    return self
end
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
function M:suspend_updating(opts)
    for _,m in ipairs(opts and opts.recursive==false and {self} or self:get_family()) do m.updating_suspended=true end
    return self
end
function M:resume_updating(opts)
    self.updating_suspended=false
    if not (opts and opts.recursive==false) then
        for _,child in ipairs(self.submobjects) do child:resume_updating(opts) end
    end
    return self:update(0,opts)
end
function M:save_state()
    self.saved_state=nil;self.saved_state=self:copy();return self
end
function M:restore() assert(self.saved_state,'no saved state');return self:become(self.saved_state) end
function M:update(dt,opts)
    U.number(dt or 0,'dt')
    if self.updating_suspended then return self end
    for _,fn in ipairs(self.updaters) do fn(self,dt or 0) end
    if not (opts and opts.recursive==false) then for _,child in ipairs(self.submobjects) do child:update(dt or 0) end end
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
