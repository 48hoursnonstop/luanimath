local l=require('luanimath')
local U=require('luanimath.util')
local data=dofile('tests/reference_glyphs.lua')
local checks=0
local function eq(a,b,label)
    if type(a)=='table' then
        assert(type(b)=='table' and #a==#b,label..' length '..#a..' vs '..tostring(type(b)=='table' and #b or b))
        for i=1,#a do eq(a[i],b[i],label..'['..i..']') end
    else checks=checks+1;assert(math.abs(a-b)<=1e-8,('%s: %.17g vs %.17g'):format(label,a,b)) end
end
local function compare(obj,c,label)
    local p,f,fo,s,so,w={},{},{},{},{},{}
    for i,g in ipairs(obj) do
        p[i]=g.points;f[i]={table.unpack(g.fill_color,1,3)};fo[i]=g.fill_color[4]
        s[i]={table.unpack(g.stroke_color,1,3)};so[i]=g.stroke_color[4];w[i]=g.stroke_width
    end
    eq(p,c.points,label..' points');eq(f,c.fills,label..' fill');eq(fo,c.fill_opacity,label..' fill opacity')
    eq(s,c.strokes,label..' stroke');eq(so,c.stroke_opacity,label..' stroke opacity');eq(w,c.widths,label..' stroke width')
end
for i,c in ipairs(data.cases) do
    local obj=l.Text(c.text,c.options);compare(obj,c,'glyph case '..i)
    eq(#obj,#obj.chars,'chars identity length')
    for j,g in ipairs(obj) do checks=checks+1;assert(g==obj.chars[j],'chars must share actual glyph identity') end
    local copy=obj:copy()
    for j,g in ipairs(copy) do checks=checks+1;assert(g==copy.chars[j] and g~=obj[j],'copy must preserve graph identity') end
end
U.mkdir('artifacts/glyphs')
for i,c in ipairs(data.states) do
    local obj=l.Text(c.text,c.options);local anim=l[c.kind](obj,c.animation_options);anim:begin();anim:interpolate(c.alpha)
    eq(anim.run_time,c.run_time,'Write duration');eq(anim.lag_ratio,c.lag_ratio,'Write lag')
    checks=checks+1;assert(not not anim.remover==c.remover,'remover semantics')
    compare(obj,c,'Write state '..i)
    local r=l.Renderer{pixel_width=480,pixel_height=270,frame_height=8,frame_width=128/9}
    r:render({obj},'artifacts/glyphs/'..c.image);r:close()
end
for i,c in ipairs(data.resizes) do
    local obj=l.Text('Size',U.merge({font='Liberation Sans',font_size=32},c.options)):scale(1.25)
    eq(obj.font_size,c.before,'font size after scaling');obj.font_size=72;eq(obj.font_size,c.after,'font size assignment')
    compare(obj,c,'font resize '..i)
end
local text=l.Text('Lua',{font='Liberation Sans'});local a,b,c=text[1],text[2],text[3]
checks=checks+1;assert(text:slice(1,2)[2]==b and text:slice(-2,-1)[2]==c and text:slice(nil,nil,-1)[3]==a,'slice identity/order')
checks=checks+1;assert(#text:slice(4,8)==0 and #text:slice(1,-10)==0,'empty slices')
text:slice(1,2):set_color(l.RED);eq(a.fill_color,b.fill_color,'slice style propagation')
checks=checks+1;assert(c.fill_color[2]==1,'unselected glyph must retain style')
local primitive=l.Square();local child=l.Circle();primitive:add(child)
checks=checks+1;assert(#primitive==2 and primitive[1]==primitive and primitive[-1]==child and #primitive:split()==2,'point-bearing iteration')
local nested=l.VGroup(l.VGroup(a,b),c);nested:invert({recursive=true})
checks=checks+1;assert(nested[1]==c and nested[2][1]==b,'recursive invert')
local original={table.unpack(text.submobjects)}
local reverse=l.Write(text,{reverse=true,remover=false});reverse:begin();reverse:finish()
for i,g in ipairs(original) do checks=checks+1;assert(text[i]==g,'finish must restore glyph order') end
local scene=l.Scene(function() end);scene:add(text)
local erase=l.Unwrite(text);erase:begin(scene);erase:finish();checks=checks+1;assert(#scene.mobjects==0,'Unwrite scene cleanup')
local function fails(fn) checks=checks+1;assert(not pcall(fn),'expected rejection') end
fails(function() text:slice(1,2,0) end);fails(function() text:slice(.5,2) end)
fails(function() text.font_size=0 end);fails(function() text.font_size=0/0 end)
fails(function() l.Text(' ',{disable_ligatures=true}) end)
local empty=l.Write(l.Text(''));empty:begin();empty:finish();checks=checks+1;assert(empty.finished,'empty Write')
print(('PASS: %d glyph cases, %d Write states; %d numerical/identity checks'):format(#data.cases,#data.states,checks))
