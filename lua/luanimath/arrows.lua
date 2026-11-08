-- Source-derived from Manim CE 0.22.1 geometry/{line,tips,arc}.py; see UPSTREAM.md.
local M=require('luanimath.mobject')
local G=require('luanimath.geometry')
local V=require('luanimath.vector')
local C=require('luanimath.color')
local U=require('luanimath.util')
local A={}
local properties={}
function properties.tip_point(self) return V(self.points[1]) end
function properties.base(self) return self:point_from_proportion(.5) end
function properties.vector(self) return self.tip_point-self.base end
function properties.tip_angle(self) local v=self.vector;return math.atan(v[2],v[1]) end
function properties.length(self) return V.norm(self.vector) end
function A.ArrowTriangleTip(opts)
    opts=opts or {};local length=U.number(opts.length or .35,'tip length');local width=U.number(opts.width or .35,'tip width')
    assert(length>=0 and width>=0,'tip dimensions must be nonnegative')
    local tip=G.Triangle(U.merge({fill_opacity=0,stroke_width=3,start_angle=math.pi},opts))
    if tip:get_width()>0 then tip:scale(width/tip:get_width()) end
    if tip:get_width()>0 then tip:stretch(length/tip:get_width(),1) end
    if tip:get_height()>0 then tip:stretch(width/tip:get_height(),2) end
    tip.kind='ArrowTriangleTip';tip._computed_fields=properties;return tip
end
function A.ArrowTriangleFilledTip(opts)
    local tip=A.ArrowTriangleTip(U.merge({fill_opacity=1,stroke_width=0},opts));tip.kind='ArrowTriangleFilledTip';return tip
end
function M:has_tip()
    if not self.tip then return false end
    for _,child in ipairs(self.submobjects) do if child==self.tip then return true end end
    return false
end
function M:get_default_tip_length()
    assert(self._arrow,'get_default_tip_length requires Arrow')
    return math.min(self.tip_length,self.max_tip_length_to_length_ratio*self:get_length())
end
local function stroke_width(self)
    return self:set_stroke(nil,math.min(self.initial_stroke_width,self.max_stroke_width_to_length_ratio*self:get_length()),nil,{family=false})
end
local function rotate_tip(tip,angle,axis)
    local n=V.normalize(axis or {0,0,1});local sine=math.sin(angle/2)
    local x,y,z,w=n[1]*sine,n[2]*sine,n[3]*sine,math.cos(angle/2)
    local center=tip:get_center()
    return tip:apply_points_function(function(point)
        local p=point-center
        return center+V((x*x-y*y-z*z+w*w)*p[1]+2*(x*y-z*w)*p[2]+2*(x*z+y*w)*p[3],
            2*(x*y+z*w)*p[1]+(-x*x+y*y-z*z+w*w)*p[2]+2*(y*z-x*w)*p[3],
            2*(x*z-y*w)*p[1]+2*(y*z+x*w)*p[2]+(-x*x-y*y+z*z+w*w)*p[3])
    end)
end
local function position(self,tip)
    local anchor=self:get_end();local handle=self.points[#self.points-1];local d=handle-anchor
    local radius=V.norm(d);local theta=math.atan(d[2],d[1]);local phi=radius==0 and 0 or math.acos(math.max(-1,math.min(1,d[3]/radius)))
    rotate_tip(tip,theta-math.pi-tip.tip_angle)
    if not self._init_positioning_axis then
        local axis=V(math.sin(theta),-math.cos(theta),0)
        rotate_tip(tip,-phi+math.pi/2,axis);self._init_positioning_axis=axis
    end
    tip:shift(anchor-tip.tip_point);return tip
end
local function add_tip(self,opts)
    assert(not opts.at_start,'starting arrow tips are not implemented')
    assert(not opts.tip_shape or opts.tip_shape==A.ArrowTriangleFilledTip or opts.tip_shape==A.ArrowTriangleTip,'only triangular arrow tips are implemented')
    local tip=opts.tip
    if not tip then
        local color=self:get_color() or C.BLUE
        local defaults={fill_color=color,stroke_color=color,length=opts.tip_length or self:get_default_tip_length()}
        if not opts.tip_shape or opts.tip_shape==A.ArrowTriangleFilledTip then defaults.width=opts.tip_width or self:get_default_tip_length() end
        local style=U.merge(defaults,self.tip_style)
        tip=(opts.tip_shape or A.ArrowTriangleFilledTip)(style)
    end
    assert(tip._computed_fields==properties or (tip._computed_fields and tip._computed_fields.base),'arrow tip must expose triangular tip properties')
    position(self,tip)
    if self:get_length()~=0 then self:put_start_and_end_on(self:get_start(),tip.base) end
    self.tip=tip;self:add(tip);return self
end
function M:pop_tips()
    local start,finish=self:get_start(),self:get_end();local result=G.VGroup()
    if self:has_tip() then result:add(self.tip);self:remove(self.tip) end
    if #result.submobjects>0 then self:put_start_and_end_on(start,finish) end
    return result
end
local function scale(self,factor,opts)
    if self:get_length()==0 then return self end
    if opts.scale_tips then M._scale_geometry(self,factor,opts);stroke_width(self);return self end
    local tip=self:has_tip() and self:pop_tips().submobjects[1] or nil
    M._scale_geometry(self,factor,opts);stroke_width(self)
    if tip then add_tip(self,{tip=tip}) end
    return self
end
function M:get_normal_vector()
    assert(self._arrow and self:has_tip(),'get_normal_vector requires an Arrow with a tip')
    local p=self.tip:get_start_anchors();local n=V.cross(p[3]-p[2],p[2]-p[1]);return V.norm(n)>0 and V.normalize(n) or V()
end
function M:reset_normal_vector() self.normal_vector=self:get_normal_vector();return self end
function A.Arrow(start,finish,opts)
    opts=opts or {};local self=G.Line(start,finish,U.merge({stroke_width=6,buff=.25},opts))
    self.kind='Arrow';self._arrow=true;self.tip_length=U.number(opts.tip_length or .35,'tip_length')
    self.max_tip_length_to_length_ratio=U.number(opts.max_tip_length_to_length_ratio or .25,'max tip ratio')
    self.max_stroke_width_to_length_ratio=U.number(opts.max_stroke_width_to_length_ratio or 5,'max stroke ratio')
    assert(self.tip_length>=0 and self.max_tip_length_to_length_ratio>=0 and self.max_stroke_width_to_length_ratio>=0,'arrow length ratios must be nonnegative')
    self.initial_stroke_width=self.stroke_width;self.normal_vector=V(opts.normal_vector or {0,0,1});self.tip_style=U.copy(opts.tip_style or {})
    self._scale_handler=scale;self._add_tip_handler=add_tip
    add_tip(self,{tip_shape=opts.tip_shape});stroke_width(self);return self
end
return A
