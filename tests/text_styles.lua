local l=require('luanim')
local U=require('luanim.util')
local data=dofile('tests/reference_text_styles.lua')
local checks=0
local function eq(a,b,label)
    if type(a)=='table' then
        assert(type(b)=='table' and #a==#b,label..' length '..#a..' vs '..tostring(type(b)=='table' and #b or b))
        for i=1,#a do eq(a[i],b[i],label..'['..i..']') end
    else checks=checks+1;assert(math.abs(a-b)<=1e-8,('%s: %.17g vs %.17g'):format(label,a,b)) end
end
U.mkdir('artifacts/text-styles')
for i,c in ipairs(data.cases) do
    local obj=l.Text(c.text,c.options);local p,f,fo,s,so,w={},{},{},{},{},{}
    for j,g in ipairs(obj) do
        p[j]=g.points;f[j]={table.unpack(g.fill_color,1,3)};fo[j]=g.fill_color[4]
        s[j]={table.unpack(g.stroke_color,1,3)};so[j]=g.stroke_color[4];w[j]=g.stroke_width
    end
    eq(p,c.points,'style '..i..' points');eq(f,c.fills,'fill '..i);eq(fo,c.fill_opacity,'fill opacity '..i)
    eq(s,c.strokes,'stroke '..i);eq(so,c.stroke_opacity,'stroke opacity '..i);eq(w,c.widths,'stroke width '..i)
    local r=l.Renderer{pixel_width=480,pixel_height=270,frame_height=8,frame_width=128/9}
    r:render({obj},'artifacts/text-styles/'..c.image);r:close()
end
for _,c in ipairs(data.colors) do eq(l.color_gradient(c.colors,c.length),c.expected,'color gradient') end
local function fails(fn) checks=checks+1;assert(not pcall(fn),'expected style rejection') end
fails(function() l.Text('abc',{t2c={ab=l.RED,bc=l.BLUE}}) end)
fails(function() l.Text('abc',{t2c={['']=l.RED}}) end)
fails(function() l.Text('abc',{t2c={['[0:9]']=l.RED}}) end)
fails(function() l.Text('abc',{t2w={abc='INVALID'}}) end)
fails(function() l.color_gradient({},2) end)
local group=l.VGroup(l.Circle{fill_opacity=.3},l.Square{fill_opacity=.6},l.Triangle{fill_opacity=.9})
group:set_color_by_gradient(l.RED,l.BLUE)
local gradient=l.color_gradient({l.RED,l.BLUE},3)
for i,m in ipairs(group) do eq({table.unpack(m.fill_color,1,3)},{table.unpack(gradient[i],1,3)},'family gradient');eq(m.fill_color[4],i*.3,'retained alpha') end
group:set_submobject_colors_by_gradient(l.GREEN);eq(group[1].fill_color[2],193/255,'single-color family')
fails(function() group:set_color_by_gradient() end)
print(('PASS: %d styled text + %d color gradient cases, %d checks'):format(#data.cases,#data.colors,checks))
