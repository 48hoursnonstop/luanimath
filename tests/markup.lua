local l=require('luanim')
local U=require('luanim.util')
local cases=dofile('tests/reference_markup.lua')
local checks=0
local function eq(a,b,label)
    if type(a)=='table' then
        assert(type(b)=='table' and #a==#b,label..' length '..#a..' vs '..tostring(type(b)=='table' and #b or b))
        for i=1,#a do eq(a[i],b[i],label..'['..i..']') end
    else checks=checks+1;assert(math.abs(a-b)<=1e-8,('%s: %.17g vs %.17g'):format(label,a,b)) end
end
U.mkdir('artifacts/markup')
for i,c in ipairs(cases) do
    local obj=l.MarkupText(c.text,c.options)
    local p,f,fo,s,so,w={},{},{},{},{},{}
    for j,g in ipairs(obj) do
        p[j]=g.points;f[j]={table.unpack(g.fill_color,1,3)};fo[j]=g.fill_color[4]
        s[j]={table.unpack(g.stroke_color,1,3)};so[j]=g.stroke_color[4];w[j]=g.stroke_width
    end
    eq(p,c.points,'markup '..i..' points');eq(f,c.fills,'fill '..i);eq(fo,c.fill_opacity,'fill opacity '..i)
    eq(s,c.strokes,'stroke '..i);eq(so,c.stroke_opacity,'stroke opacity '..i);eq(w,c.widths,'stroke width '..i)
    if c.font_size then eq(obj.font_size,c.font_size,'markup font size') end
    local r=l.Renderer{pixel_width=480,pixel_height=270,frame_height=8,frame_width=128/9}
    r:render({obj},'artifacts/markup/'..c.image);r:close()
    if c.resize then
        obj:scale(1.25);eq(obj.font_size,c.resize.before,'markup scaled font size')
        obj.font_size=72;eq(obj.font_size,c.resize.after,'markup font size setter')
        local points={};for j,g in ipairs(obj) do points[j]=g.points end;eq(points,c.resize.points,'markup resized points')
    end
end
local function fails(fn) checks=checks+1;assert(not pcall(fn),'expected invalid markup rejection') end
for _,bad in ipairs({'<b>unclosed','<wrong>unsupported</wrong>','a & b','<span foreground="invalid-color">bad</span>','<gradient from="RED" to="BLUE">pending</gradient>'}) do
    fails(function() l.MarkupText(bad) end)
end
fails(function() l.MarkupText('\255') end)
fails(function() l.MarkupText('a\0b') end)
eq(l.MarkupText('Empty gradient',{gradient={}}):get_width(),l.MarkupText('Empty gradient'):get_width(),'empty gradient')
print(('PASS: %d markup cases and %d numerical/invalid-input checks'):format(#cases,checks))
