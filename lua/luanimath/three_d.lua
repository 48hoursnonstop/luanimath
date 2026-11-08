local G=require('luanimath.geometry')
local V=require('luanimath.vector')
local U=require('luanimath.util')
local C=require('luanimath.color')
local B=require('luanimath.bezier')
local D={}
function D.ThreeDVMobject(opts)
    local m=G.VMobject(U.merge({shade_in_3d=true},opts));m.kind='ThreeDVMobject';return m
end
function D.Surface(fn,opts)
    assert(type(fn)=='function','Surface requires a function');opts=opts or {}
    local ur,vr=opts.u_range or {0,1},opts.v_range or {0,1}
    assert(#ur==2 and #vr==2,'surface ranges require two endpoints')
    for _,r in ipairs({ur,vr}) do U.number(r[1],'range minimum');U.number(r[2],'range maximum');assert(r[2]>r[1],'range maximum must exceed minimum') end
    local res=opts.resolution or 32;local nu,nv
    if type(res)=='number' then nu,nv=res,res else nu,nv=res[1],res[2] end
    U.integer(nu,'u resolution',1);U.integer(nv,'v resolution',1);assert(nu*nv<=65536,'surface resolution too large')
    local factor=opts.pre_function_handle_to_anchor_scale_factor or 1e-5
    U.number(factor,'handle scale');assert(factor>0,'handle scale must be positive')
    local style=U.merge({fill_color=C.BLUE_D,fill_opacity=1,stroke_color='#BBBBBB',stroke_width=.5},opts)
    local function evaluate(u,v)
        local point=fn(u,v)
        assert(type(point)=='table' and (#point==2 or #point==3),'surface function must return a 2D/3D point table')
        return V(point)
    end
    local m=G.VGroup();m.kind='Surface';m.list_of_faces={};m.surface_function=fn
    m.pre_function_handle_to_anchor_scale_factor=factor
    m.make_smooth_after_applying_functions=not not opts.make_smooth_after_applying_functions
    m.fill_color=C.parse(style.fill_color,style.fill_opacity);m.stroke_color=C.parse(style.stroke_color,style.stroke_opacity or 1);m.stroke_width=style.stroke_width
    local checker=opts.checkerboard_colors
    if checker==nil then checker={C.BLUE_D,'#236B8E'} end
    if checker~=false then assert(type(checker)=='table' and #checker>0,'checkerboard_colors must be a nonempty color list or false') end
    for i=0,nu-1 do for j=0,nv-1 do
        local u1,u2=ur[1]+(ur[2]-ur[1])*i/nu,ur[1]+(ur[2]-ur[1])*(i+1)/nu
        local v1,v2=vr[1]+(vr[2]-vr[1])*j/nv,vr[1]+(vr[2]-vr[1])*(j+1)/nv
        local uv={V(u1,v1),V(u2,v1),V(u2,v2),V(u1,v2),V(u1,v1)}
        local points={}
        for k=1,4 do
            local cubic=B.line(uv[k],uv[k+1]);local a,b=evaluate(cubic[1][1],cubic[1][2]),evaluate(cubic[4][1],cubic[4][2])
            local h1=V.lerp(cubic[1],cubic[2],factor);local h2=V.lerp(cubic[4],cubic[3],factor)
            h1=a+(evaluate(h1[1],h1[2])-a)/factor;h2=b+(evaluate(h2[1],h2[2])-b)/factor
            if opts.should_make_jagged then h1=V.lerp(a,b,1/3);h2=V.lerp(a,b,2/3) end
            B.append(points,{a,h1,h2,b})
        end
        local face=D.ThreeDVMobject(style):set_points(points)
        face.u_index=i;face.v_index=j;face.u1=u1;face.u2=u2;face.v1=v1;face.v2=v2
        if checker then face:set_fill(checker[(i+j)%#checker+1]) end
        m:add(face);m.list_of_faces[#m.list_of_faces+1]=face
    end end
    if m.make_smooth_after_applying_functions and not opts.should_make_jagged then m:make_smooth() end
    return m
end
function D.Sphere(opts)
    opts=opts or {};local radius=U.number(opts.radius or 1,'radius')
    local m=D.Surface(function(u,v) return V(math.cos(u)*math.sin(v),math.sin(u)*math.sin(v),-math.cos(v))*radius end,
        U.merge({u_range={0,2*math.pi},v_range={0,math.pi},resolution={24,12}},opts))
    m.kind='Sphere';return m:shift(V(opts.center or {}))
end
local function z_to_vector(direction)
    local z=V.normalize(direction);local cross=V.cross(z,V(1,0,0));local x,y
    if V.norm(cross)==0 then x=V.normalize(V.cross(V(0,1,0),z));y=-V.cross(x,z)
    else y=V.normalize(cross);x=V.cross(y,z) end
    return {{x[1],y[1],z[1]},{x[2],y[2],z[2]},{x[3],y[3],z[3]}}
end
function D.Cube(opts)
    opts=opts or {};local side=U.number(opts.side_length or 2,'side_length')
    local style=U.merge({fill_color=C.BLUE,fill_opacity=.75,stroke_width=0,shade_in_3d=true,joint_type='bevel'},opts)
    local cube=G.VGroup();cube.kind='Cube'
    cube.fill_color=C.parse(style.fill_color,style.fill_opacity);cube.stroke_width=style.stroke_width
    for _,direction in ipairs({V(0,0,-1),V(0,0,1),V(-1,0,0),V(1,0,0),V(0,1,0),V(0,-1,0)}) do
        local face=G.Square(U.merge(style,{side_length=side})):rotate(math.pi,{axis=V(0,1,0)}):shift(V(0,0,side/2))
        face:apply_matrix(z_to_vector(direction));cube:add(face)
    end
    return cube
end
return D
