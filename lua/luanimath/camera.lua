local V=require('luanimath.vector')
local G=require('luanimath.geometry')
local U=require('luanimath.util')
local Config=require('luanimath.config')
local Camera={};Camera.__index=Camera
local API={}
function Camera.new(opts,kind)
    opts=opts or {};local config=Config.resolve(opts)
    local self=setmetatable({kind=kind or 'Camera',config=config,fixed_in_frame_mobjects={},fixed_orientation_mobjects={}},Camera)
    self.frame=G.Rectangle{width=config.frame_width,height=config.frame_height,stroke_width=0,fill_opacity=0}
    self.frame:move_to(V(opts.frame_center or {}))
    if kind=='ThreeDCamera' then
        self._frame_center=G.VectorizedPoint(V(opts.frame_center or {}))
        self.phi_tracker=G.ValueTracker(opts.phi or 0);self.theta_tracker=G.ValueTracker(opts.theta or -math.pi/2)
        self.gamma_tracker=G.ValueTracker(opts.gamma or 0);self.zoom_tracker=G.ValueTracker(opts.zoom or 1)
        self.focal_distance_tracker=G.ValueTracker(opts.focal_distance or 20)
        assert(self.focal_distance_tracker:get_value()>0,'focal_distance must be positive')
        self.should_apply_shading=opts.should_apply_shading~=false
        self.exponential_projection=not not opts.exponential_projection
        self.light_source=G.VectorizedPoint(V(opts.light_source_start_point or {-7,-9,10}))
    end
    return self
end
function Camera:get_frame_center() return self.kind=='ThreeDCamera' and self._frame_center:get_center() or self.frame:get_center() end
function Camera:get_frame_width() return self.frame:get_width() end
function Camera:get_frame_height() return self.frame:get_height() end
function Camera:copy() return U.copy(self) end
for _,name in ipairs({'phi','theta','gamma','zoom','focal_distance'}) do
    Camera['get_'..name]=function(self) assert(self[name..'_tracker'],'requires ThreeDCamera');return self[name..'_tracker']:get_value() end
    Camera['set_'..name]=function(self,value) assert(self[name..'_tracker'],'requires ThreeDCamera');self[name..'_tracker']:set_value(value);return self end
end
function Camera:get_value_trackers() return {self.phi_tracker,self.theta_tracker,self.focal_distance_tracker,self.gamma_tracker,self.zoom_tracker} end
function Camera:rotate_point(point)
    point=V.rotate(point,-self:get_theta()-math.pi/2,V(0,0,1))
    point=V.rotate(point,-self:get_phi(),V(1,0,0))
    return V.rotate(point,self:get_gamma(),V(0,0,1))
end
function Camera:generate_rotation_matrix()
    local x,y,z=self:rotate_point(V(1,0,0)),self:rotate_point(V(0,1,0)),self:rotate_point(V(0,0,1))
    return {{x[1],y[1],z[1]},{x[2],y[2],z[2]},{x[3],y[3],z[3]}}
end
Camera.get_rotation_matrix=Camera.generate_rotation_matrix
function Camera:project_point(point)
    assert(self.kind=='ThreeDCamera','projection requires ThreeDCamera')
    local p=self:rotate_point(V(point)-self:get_frame_center())
    local distance=self:get_focal_distance();assert(distance>0,'focal_distance must be positive')
    local factor
    if self.exponential_projection and p[3]>=0 then factor=math.exp(p[3]/distance)
    elseif distance-p[3]<0 then factor=1e6
    else assert(distance~=p[3],'point lies on the focal plane');factor=distance/(distance-p[3]) end
    return V(p[1]*factor*self:get_zoom(),p[2]*factor*self:get_zoom(),p[3])
end
function Camera:project_points(points) local out={};for i,p in ipairs(points) do out[i]=self:project_point(p) end;return out end
function Camera:transform_points(m,points)
    if self.kind~='ThreeDCamera' or self.fixed_in_frame_mobjects[m] then return points end
    local center_fn=self.fixed_orientation_mobjects[m]
    if center_fn then
        local center=V(center_fn());local delta=self:project_point(center)-center;local out={}
        for i,p in ipairs(points) do out[i]=V(p)+delta end;return out
    end
    return self:project_points(points)
end
function Camera:add_fixed_in_frame_mobjects(...)
    for _,root in ipairs({...}) do for _,m in ipairs(root:get_family()) do self.fixed_in_frame_mobjects[m]=true end end
    return self
end
function Camera:remove_fixed_in_frame_mobjects(...)
    for _,root in ipairs({...}) do for _,m in ipairs(root:get_family()) do self.fixed_in_frame_mobjects[m]=nil end end
    return self
end
function Camera:add_fixed_orientation_mobjects(...)
    for _,root in ipairs({...}) do for _,m in ipairs(root:get_family()) do self.fixed_orientation_mobjects[m]=function() return m:get_center() end end end
    return self
end
function Camera:depth(m)
    if self.kind=='ThreeDCamera' and m.shade_in_3d then return self:rotate_point(m:get_center())[3] end
    return math.huge
end
local function unit_normal(v1,v2)
    local function largest(v) return math.max(math.abs(v[1]),math.abs(v[2]),math.abs(v[3])) end
    local d1,d2=largest(v1),largest(v2);local u
    if d1==0 then if d2==0 then return V(0,-1,0) end;u=v2/d2
    elseif d2==0 then u=v1/d1
    else local a,b=v1/d1,v2/d2;local cross=V.cross(a,b);if V.norm(cross)>1e-6 then return V.normalize(cross) end;u=a end
    if math.abs(u[1])<1e-6 and math.abs(u[2])<1e-6 then return V(0,-1,0) end
    return V.normalize(V(-u[1]*u[3],-u[2]*u[3],u[1]^2+u[2]^2))
end
local function corner_normal(m,index)
    local n=#m.points
    if #m:get_anchors()<=2 then return V(0,1,0) end
    local before=index>2 and index-3 or n-4
    local after=index<n-3 and index+3 or 3
    local p=V(m.points[index+1])
    return unit_normal(V(m.points[after+1])-p,V(m.points[before+1])-p)
end
function Camera:shading(m)
    if self.kind~='ThreeDCamera' or not self.should_apply_shading or not m.shade_in_3d or #m.points==0 then return nil end
    local start_index,finish_index=0,math.floor((#m.points-1)/6)*3
    local start,finish=V(m.points[1]),V(m.points[finish_index+1])
    local light=self.light_source:get_center()
    local function shade(color,p,index)
        local toward=light-p;local direction=V.norm(toward)==0 and V() or V.normalize(toward)
        local brightness=.5*V.dot(corner_normal(m,index),direction)^3
        if brightness<0 then brightness=brightness*.5 end
        return {U.clamp(color[1]+brightness),U.clamp(color[2]+brightness),U.clamp(color[3]+brightness),color[4]}
    end
    local projected=self:transform_points(m,{start,finish})
    return {start=projected[1],finish=projected[2],
        fill={shade(m.fill_color,start,start_index),shade(m.fill_color,finish,finish_index)},
        stroke={shade(m.stroke_color,start,start_index),shade(m.stroke_color,finish,finish_index)}}
end
function API.Camera(opts) return Camera.new(opts,'Camera') end
function API.MovingCamera(opts) return Camera.new(opts,'MovingCamera') end
function API.ThreeDCamera(opts) return Camera.new(opts,'ThreeDCamera') end
return API
