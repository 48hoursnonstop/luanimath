local N=require('luanimath_native')
local G=require('luanimath.geometry')
local V=require('luanimath.vector')
local U=require('luanimath.util')
local Path=require('luanimath.svg_path')
local S={}
local identity={1,0,0,1,0,0}
local function multiply(a,b)
    return {a[1]*b[1]+a[3]*b[2],a[2]*b[1]+a[4]*b[2],a[1]*b[3]+a[3]*b[4],a[2]*b[3]+a[4]*b[4],a[1]*b[5]+a[3]*b[6]+a[5],a[2]*b[5]+a[4]*b[6]+a[6]}
end
local function transform(text)
    local result=identity;local at=1
    while text and text:sub(at):match('%S') do
        local a,b,name,args=text:find('%s*([%a]+)%s*%(([^)]*)%)',at)
        assert(a==at,'invalid SVG transform')
        local reader=Path.reader(args);local n={};while reader:peek()~='' do n[#n+1]=reader:number() end
        local m
        if name=='matrix' then assert(#n==6,'matrix requires six values');m=n
        elseif name=='translate' then assert(#n==1 or #n==2,'translate requires 1 or 2 values');m={1,0,0,1,n[1],n[2] or 0}
        elseif name=='scale' then assert(#n==1 or #n==2,'scale requires 1 or 2 values');m={n[1],0,0,n[2] or n[1],0,0}
        elseif name=='rotate' then
            assert(#n==1 or #n==3,'rotate requires angle or angle,cx,cy');local angle=n[1]*math.pi/180
            m={math.cos(angle),math.sin(angle),-math.sin(angle),math.cos(angle),0,0}
            if #n==3 then m=multiply(multiply({1,0,0,1,n[2],n[3]},m),{1,0,0,1,-n[2],-n[3]}) end
        elseif name=='skewX' or name=='skewY' then
            assert(#n==1,'skew requires one angle');local t=math.tan(n[1]*math.pi/180)
            m=name=='skewX' and {1,0,t,1,0,0} or {1,t,0,1,0,0}
        else error('unsupported SVG transform: '..name) end
        result=multiply(result,m);at=b+1
        local _,last=text:find('^[%s,]*',at);at=(last or at-1)+1
    end
    return result
end
local function number(value,default)
    if value==nil then return default end
    if type(value)=='number' then return U.number(value,'SVG length') end
    local r=Path.reader(value);local n=r:number();local suffix=value:sub(r.pos):match('^%s*(.-)%s*$')
    assert(suffix=='' or suffix=='px','SVG percentage/physical units require a viewport and are not implemented')
    return n
end
local function round_even(x)
    local n=math.floor(x)
    if x-n>.5 or (x-n==.5 and n%2==1) then n=n+1 end
    return n
end
local function color(value,current)
    value=value or 'black'
    if value=='none' then return nil end
    if value=='currentColor' then value=current or 'black' end
    if value=='transparent' then return {0,0,0,0} end
    assert(not value:find('url%('),'SVG gradient/pattern paints are not implemented')
    local fn,args=value:match('^(rgba?)%((.*)%)$')
    if fn then
        local values={};for part in args:gmatch('[^,]+') do values[#values+1]=part:match('^%s*(.-)%s*$') end
        assert(#values==(fn=='rgb' and 3 or 4),'invalid SVG RGB color')
        local rgb={}
        for i=1,3 do
            local percent=values[i]:sub(-1)=='%'
            local x=number(percent and values[i]:sub(1,-2) or values[i])
            rgb[i]=math.max(0,math.min(255,percent and round_even(x*(255/100)) or math.floor(x)))/255
        end
        rgb[4]=values[4] and number(values[4]) or 1
        return rgb
    end
    return N.parse_css_color(value)
end
local function alpha(value,fallback)
    local x=math.max(0,math.min(1,number(value,fallback)))*255
    return round_even(x)/255
end
function S.VMobjectFromSVGPath(data,opts)
    local m=G.VMobject(opts);m.kind='VMobjectFromSVGPath';return m:set_points(Path.parse(data))
end
S._transform=transform
S._multiply=multiply
function S._from_tree(root,opts,filename)
    opts=opts or {}
    assert(root.name=='svg','document root must be svg')
    local ids={}
    local function index(node) if node.attributes.id then ids[node.attributes.id]=node end;for _,c in ipairs(node.children) do index(c) end end
    index(root)
    local object=G.VGroup();object.kind='SVGMobject';object.file_name=filename;object.id_to_vgroup_dict={root=G.VGroup()};object._id_order={'root'}
    local defaults=opts.svg_default or {}
    local initial={fill=defaults.fill_color or defaults.color or 'black',['fill-opacity']=defaults.fill_opacity or defaults.opacity,
        stroke=defaults.stroke_color or defaults.color or 'none',['stroke-opacity']=defaults.stroke_opacity or defaults.opacity,
        ['stroke-width']=defaults.stroke_width or 0,color='black'}
    local function walk(node,parent,matrix,groups,depth,referenced)
        assert(depth<=256,'SVG reference nesting too deep')
        local a=node.attributes;local name=node.name
        if name=='defs' or name=='metadata' or name=='title' or name=='desc' then return end
        if name=='symbol' and not referenced then return end
        local own=U.merge({},a)
        if a.style then for key,value in a.style:gmatch('([%w%-]+)%s*:%s*([^;]+)') do own[key]=value:match('^%s*(.-)%s*$') end end
        local style=U.merge(parent,own)
        if style.display=='none' or style.visibility=='hidden' then return end
        for _,key in ipairs({'clip-path','mask','filter'}) do assert(not style[key] or style[key]=='none','SVG '..key..' is not implemented') end
        local m=multiply(matrix,transform(a.transform))
        local active={};for i,group in ipairs(groups) do active[i]=group end
        if a.id then
            local group=object.id_to_vgroup_dict[a.id]
            if not group then group=G.VGroup();object._id_order[#object._id_order+1]=a.id end
            object.id_to_vgroup_dict[a.id]=group;active[#active+1]=group
        end
        if name=='use' then
            local href=a.href;assert(href and href:sub(1,1)=='#','only local SVG use references are supported')
            local target=assert(ids[href:sub(2)],'unknown SVG reference: '..href)
            walk(target,style,multiply(m,{1,0,0,1,number(a.x,0),number(a.y,0)}),active,depth+1,true);return
        end
        if name=='svg' or name=='g' or name=='symbol' then
            if name=='symbol' then assert(not a.viewBox,'symbol viewBox is not implemented') end
            for _,child in ipairs(node.children) do walk(child,style,m,active,depth+1,false) end;return
        end
        local shape
        if name=='path' then shape=S.VMobjectFromSVGPath(a.d or '')
        elseif name=='line' then shape=G.Line(V(number(a.x1,0),number(a.y1,0)),V(number(a.x2,0),number(a.y2,0)))
        elseif name=='rect' then
            assert(number(a.rx,0)==0 and number(a.ry,0)==0,'rounded SVG rectangles are not implemented')
            local w,h=number(a.width,0),number(a.height,0)
            if w<=0 or h<=0 then return end
            shape=G.Rectangle{width=w,height=h}:shift(V(number(a.x,0)+w/2,number(a.y,0)+h/2))
        elseif name=='circle' or name=='ellipse' then
            local rx=name=='circle' and number(a.r,0) or number(a.rx,0)
            local ry=name=='circle' and rx or number(a.ry,0)
            if rx<=0 or ry<=0 then return end
            shape=G.Ellipse{width=2*rx,height=2*ry}:shift(V(number(a.cx,0),number(a.cy,0)))
        elseif name=='polygon' or name=='polyline' then
            local reader=Path.reader(a.points or '');local points={}
            while reader:peek()~='' do points[#points+1]=V(reader:number(),reader:number()) end
            if #points<2 then return end
            shape=name=='polygon' and G.Polygon(points) or G.VMobject():set_points_as_corners(points)
        else error('unsupported SVG element: '..name) end
        if #shape.points==0 then return end
        local fill,stroke=color(style.fill,style.color),color(style.stroke,style.color)
        -- svgelements quantizes alpha to 8 bits and ignores group/object opacity.
        shape:set_fill(fill,fill and alpha(style['fill-opacity'],fill[4]) or nil)
        local stroke_scale=style['vector-effect']=='non-scaling-stroke' and 1 or math.sqrt(math.abs(m[1]*m[4]-m[2]*m[3]))
        shape:set_stroke(stroke,stroke and number(style['stroke-width'],0)*stroke_scale or 0,stroke and alpha(style['stroke-opacity'],stroke[4]) or nil)
        shape:apply_matrix({{m[1],m[3]},{m[2],m[4]}}):shift(V(m[5],m[6]))
        if opts._on_shape then opts._on_shape(shape,m) end
        object:add(shape);for _,group in ipairs(active) do group:add(shape) end
    end
    -- Upstream wraps root children in style groups; root viewport/transform is discarded.
    local root_style=U.merge({},initial)
    for _,key in ipairs({'fill','fill-opacity','stroke','stroke-opacity','stroke-width','style'}) do root_style[key]=root.attributes[key] or root_style[key] end
    if root_style.style then for key,value in root_style.style:gmatch('([%w%-]+)%s*:%s*([^;]+)') do root_style[key]=value:match('^%s*(.-)%s*$') end end
    for _,child in ipairs(root.children) do walk(child,root_style,identity,{object.id_to_vgroup_dict.root},1,false) end
    object:rotate(math.pi,{axis=V(1,0,0)})
    if opts.fill_color or opts.fill_opacity then object:set_fill(opts.fill_color,opts.fill_opacity) end
    if opts.stroke_color or opts.stroke_width or opts.stroke_opacity then object:set_stroke(opts.stroke_color,opts.stroke_width,opts.stroke_opacity) end
    if opts.should_center~=false then object:move_to(V()) end
    local height=opts.height==nil and 2 or opts.height
    if height and object:get_height()>0 then object:scale(height/object:get_height()) end
    if opts.width and object:get_width()>0 then object:scale(opts.width/object:get_width()) end
    return object
end
function S._from_data(data,opts,filename) return S._from_tree(N.parse_xml(data),opts,filename) end
function S.SVGMobject(filename,opts)
    assert(type(filename)=='string','SVGMobject requires a filename')
    local handle,err=io.open(filename,'rb');assert(handle,err)
    local data=handle:read('*a');handle:close()
    return S._from_data(data,opts,filename)
end
return S
