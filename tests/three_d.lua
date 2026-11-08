local l=require('luanimath')
local U=require('luanimath.util')
local data=dofile('tests/reference_three_d.lua')
local checks=0
local function eq(a,b,label)
    if type(a)=='table' then
        assert(type(b)=='table' and #a==#b,label..' lengths '..#a..' vs '..tostring(type(b)=='table' and #b or b))
        for i=1,#a do eq(a[i],b[i],label..'['..i..']') end
    else
        checks=checks+1
        -- Behind-focal-plane projection uses upstream's 1e6 sentinel scale.
        -- Allow <=1e-14 relative rounding there, retaining 1e-9 absolute elsewhere.
        local tolerance=1e-9+1e-14*math.abs(b)
        assert(math.abs(a-b)<=tolerance,('%s: %.17g vs %.17g (difference %.17g)'):format(label,a,b,math.abs(a-b)))
    end
end
for _,c in ipairs(data.projections) do
    local cam=l.ThreeDCamera(c.options)
    eq(cam:project_points(c.points),c.projected,'projection');eq(cam:get_rotation_matrix(),c.rotation,'rotation matrix')
    eq(cam:project_point(c.points[1]),c.projected[1],'project point')
end
local function build(kind,opts)
    if kind=='Surface' then return l.Surface(function(u,v) return l.vec(u,v,.3*math.sin(u)*math.cos(v)) end,opts) end
    return l[kind](opts)
end
for _,c in ipairs(data.objects) do
    local obj=build(c.kind,c.options);local points,fill,stroke,widths={},{},{},{}
    for i,m in ipairs(obj:get_family()) do points[i]=m.points;fill[i]=m.fill_color;stroke[i]=m.stroke_color;widths[i]=m.stroke_width end
    eq(points,c.expected.points,c.kind..' points');eq(fill,c.expected.fill,c.kind..' fill');eq(stroke,c.expected.stroke,c.kind..' stroke');eq(widths,c.expected.widths,c.kind..' width')
end
U.mkdir('artifacts/three-d')
local viewport={pixel_width=400,pixel_height=300,frame_height=8,frame_width=32/3}
for _,c in ipairs(data.images) do
    local cam=l.ThreeDCamera(U.merge(viewport,c.camera));local r=l.Renderer(viewport,cam)
    r:render({build(c.kind,c.options)},'artifacts/three-d/'..c.image);r:close()
end
local camera=l.MovingCamera(viewport);camera.frame:scale(.6):shift(l.RIGHT)
local r=l.Renderer(viewport,camera)
r:render({l.Square{color=l.BLUE,fill_opacity=.4},l.Circle{color=l.GREEN}:shift(2*l.RIGHT)},'artifacts/three-d/moving.png');r:close()
local c=l.ThreeDCamera();local square=l.Square():shift(l.RIGHT)
c:add_fixed_in_frame_mobjects(square);eq(c:transform_points(square,square.points),square.points,'fixed frame')
c:remove_fixed_in_frame_mobjects(square);c:add_fixed_orientation_mobjects(square)
eq(c:transform_points(square,square.points),square.points,'fixed orientation default camera')
c:set_phi(.4):set_theta(.7):set_gamma(.2):set_zoom(.9):set_focal_distance(10)
eq(c:get_phi(),.4,'phi');eq(c:get_theta(),.7,'theta');eq(c:get_gamma(),.2,'gamma');eq(c:get_zoom(),.9,'zoom');eq(c:get_focal_distance(),10,'focal')
eq(#c:get_value_trackers(),5,'trackers');eq(c:copy():get_phi(),.4,'camera copy')
local function fails(fn) checks=checks+1;assert(not pcall(fn),'expected rejection') end
fails(function() l.ThreeDCamera{focal_distance=0} end)
fails(function() l.Sphere{resolution={0,2}} end)
fails(function() l.Surface(function() return {0/0,0,0} end,{resolution=1}) end)
fails(function() l.Surface(function() return {} end,{resolution=1}) end)
fails(function() l.Surface(function() return nil end,{resolution=1}) end)
fails(function() l.Surface(function() return {0,0,0} end,{resolution=1,u_range={1,0}}) end)
local native=require('luanimath_native');local canvas=native.surface(32,32,4,4,0,0)
fails(function() canvas:set_frame(0,4,0,0) end)
local sample=l.Square()
fails(function() canvas:draw(sample.points,sample.fill_color,sample.stroke_color,4,'miter','butt',{}) end)
canvas:close()
local scene=l.ThreeDScene(function() end,{frame_rate=4})
scene:set_camera_orientation{phi=.3,theta=.5,gamma=.1,zoom=.8,frame_center={.1,.2,0}}
scene:move_camera{phi=.6,theta=.8,zoom=1.2,frame_center={0,0,0},run_time=1,rate_func=l.linear}
eq(scene.camera:get_phi(),.6,'camera animation');eq(scene.camera:get_zoom(),1.2,'zoom animation')
eq(scene.frame_count,4,'camera animation frames')
local fixed=l.Square();scene:add_fixed_in_frame_mobjects(fixed);assert(scene.camera.fixed_in_frame_mobjects[fixed])
print(('PASS: %d camera + %d 3D geometry cases, %d scalar/invalid-input checks; 7 native images'):format(#data.projections,#data.objects,checks))
