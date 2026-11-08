local U=require('luanimath.util')
local V=require('luanimath.vector')
local C=require('luanimath.color')
local M=require('luanimath.mobject')
local Shapes=require('luanimath.geometry')
local SVG=require('luanimath.svg')
local N=require('luanimath_native')
local Files=require('luanimath.typst_file')
local Groups=require('luanimath.typst_groups')
local Config=require('luanimath.config')
local T={}
local function read_tree(path)
    local f=assert(io.open(path,'rb'));local text=f:read('*a');f:close();return N.parse_xml(text)
end
local function compile(code,opts,preamble)
    return Files.typst_to_svg_file(code,U.merge(opts,{preamble=preamble or opts.typst_preamble or '',text_size=10}))
end
local function baseline_reference(points)
    local x,y=0,0
    for _,p in ipairs(points) do x=x+p[1];y=y+p[2] end
    x,y=x/#points,y/#points
    local xx,xy,yy=0,0,0
    for _,p in ipairs(points) do local dx,dy=p[1]-x,p[2]-y;xx=xx+dx*dx;xy=xy+dx*dy;yy=yy+dy*dy end
    local det=xx*yy-xy*xy
    if xx==0 or yy==0 or det<=1e-12*xx*yy then return nil end
    -- Upstream svgelements reifies Typst paths before the baseline hook, so
    -- its reference frame is the identity frame in the baked SVG coordinates.
    return {points=U.copy(points),center=V(x,y),xx=xx,xy=xy,yy=yy,det=det,
        frame={V(),V(1,0),V(0,1)}}
end
local function refresh_strokes(self)
    local state=self._typst_state;if not state.preserve_strokes then return end
    local pixels=Config.defaults.pixel_width/Config.defaults.frame_width
    for _,m in ipairs(state.strokes) do
        local source=m._typst_stroke
        m:set_stroke(nil,source.width*math.max(m:get_width(),m:get_height())/source.size*pixels*.5,nil,{family=false})
    end
end
local function construct(code,opts,path,root,captures,labels)
    assert(type(code)=='string','Typst requires source text');opts=opts or {}
    local size=U.number(opts.font_size or 48,'font_size');assert(size>0,'font_size must be positive')
    path=path or compile(code,opts);root=root or read_tree(path)
    Groups.decorate(root,captures)
    local state={strokes={},baselines={},aliases={},preserve_strokes=opts.stroke_width==nil,track_baselines=not not opts.track_baselines}
    local imported=U.merge(opts,{height=opts.height or false,_on_shape=function(shape)
        if state.preserve_strokes and shape.stroke_width~=0 then
            local extent=math.max(shape:get_width(),shape:get_height())
            if extent>0 then shape._typst_stroke={width=shape.stroke_width,size=extent};state.strokes[#state.strokes+1]=shape end
        end
        if state.track_baselines then
            shape._typst_baseline=baseline_reference(shape.points)
            if shape._typst_baseline then state.baselines[#state.baselines+1]=shape end
        end
    end})
    local obj=SVG._from_tree(root,imported,path);obj.kind=labels and 'MathTypst' or 'Typst'
    obj.typst_code=code;obj.typst_preamble=opts.typst_preamble or '';obj._font_size=size;obj._font_size_basis=960
    obj._typst_state=state;obj._after_scale=refresh_strokes;obj.track_baselines=state.track_baselines
    for _,id in ipairs(obj._id_order) do
        if id~='root' and not id:match('^numbered_group_') and not id:match('^g%x+$') then
            local base=id:match('^(.-)__manim_typst_dup_') or id
            state.aliases[base]=state.aliases[base] or {};table.insert(state.aliases[base],id)
        end
    end
    for _,label in ipairs(labels or {}) do state.aliases[label]=state.aliases[label] or {} end
    refresh_strokes(obj)
    local base=C.parse(opts.color or C.WHITE);obj:set_color(base,{family=false})
    for _,shape in ipairs(obj.submobjects) do
        local color=shape:get_color()
        if color and color[1]==0 and color[2]==0 and color[3]==0 then shape:set_color(base) end
    end
    obj.initial_height=obj:get_height()
    if not opts.height and obj.initial_height>0 then obj.font_size=size end
    return obj
end
function T.Typst(code,opts) return construct(code,opts or {}) end
function T.MathTypst(expression,opts)
    opts=opts or {};local processed,labels=Groups.preprocess(expression)
    local code='$ '..processed..' $';local distinct,seen={},{}
    for _,label in ipairs(labels) do if not seen[label] then seen[label]=true;distinct[#distinct+1]=label end end
    if #distinct==0 then return construct(code,opts,nil,nil,nil,labels) end
    local function preamble(label)
        local text=Groups.preamble(label)
        if opts.typst_preamble and opts.typst_preamble~='' then text=text..'\n'..opts.typst_preamble end
        return text
    end
    local final_preamble=preamble(nil);local path=compile(code,opts,final_preamble);local root=read_tree(path)
    local visible=Groups.leaves(root);local captures={}
    for _,label in ipairs(distinct) do
        local probe=read_tree(compile(code,opts,preamble(label)))
        for _,index in ipairs(Groups.hidden(visible,Groups.leaves(probe))) do
            captures[index]=captures[index] or {};table.insert(captures[index],label)
        end
    end
    return construct(code,U.merge(opts,{typst_preamble=final_preamble}),path,root,captures,labels)
end
function M:select(key)
    local state=assert(self._typst_state,'select requires Typst or MathTypst')
    if type(key)=='number' then U.integer(key,'group index',1);key='_grp-'..(key-1) end
    assert(type(key)=='string','group selection requires a label or 1-based capture index')
    local ids=assert(state.aliases[key],'unknown Typst group label: '..key)
    local result=Shapes.VGroup();local seen={}
    for _,id in ipairs(ids) do for _,shape in ipairs(self.id_to_vgroup_dict[id].submobjects) do
        if not seen[shape] then seen[shape]=true;result:add(shape) end
    end end
    return result
end
function M:get_baseline_frame(shape)
    assert(self._typst_state,'baseline frames require Typst or MathTypst')
    local ref=assert(shape and shape._typst_baseline,'no tracked baseline; construct with track_baselines=true and select a nondegenerate leaf')
    assert(#ref.points==#shape.points,'baseline geometry point count changed')
    local mean=V();for _,p in ipairs(shape.points) do mean=mean+p end;mean=mean/#shape.points
    local x,y=V(),V()
    for i,p in ipairs(ref.points) do local delta=shape.points[i]-mean;x=x+delta*(p[1]-ref.center[1]);y=y+delta*(p[2]-ref.center[2]) end
    local a=(x*ref.yy-y*ref.xy)/ref.det;local b=(y*ref.xx-x*ref.xy)/ref.det
    local result={}
    for i,p in ipairs(ref.frame) do result[i]=mean+a*(p[1]-ref.center[1])+b*(p[2]-ref.center[2]) end
    return table.unpack(result)
end
function M:get_baseline_frames()
    local state=assert(self._typst_state,'baseline frames require Typst or MathTypst')
    local result={};for i,shape in ipairs(state.baselines) do result[i]={self:get_baseline_frame(shape)} end;return result
end
return T
