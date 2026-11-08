local l=require('luanimath')
local T=l
local Groups=require('luanimath.typst_groups')
local U=require('luanimath.util')
local data=dofile('tests/reference_typst.lua')
local checks,known=0,0
local function eq(a,b,label)
    if type(a)=='table' then
        assert(type(b)=='table' and #a==#b,label..' length '..#a..' vs '..tostring(type(b)=='table' and #b or b))
        for i=1,#a do eq(a[i],b[i],label..'['..i..']') end
    elseif type(a)=='number' then
        checks=checks+1;assert(math.abs(a-b)<=1e-8,('%s: %.17g vs %.17g'):format(label,a,b))
    else checks=checks+1;assert(a==b,label..': '..tostring(a)..' vs '..tostring(b)) end
end
for _,c in ipairs(data.parsers) do local text,labels=Groups.preprocess(c.input);eq(text,c.processed,'capture preprocessing');eq(labels,c.labels,'capture labels') end
U.mkdir('artifacts/typst')
l.config.with({pixel_width=480,pixel_height=270},function()
    for i,c in ipairs(data.cases) do
        local obj=T[c.kind](c.text,c.options)
        if c.pose==1 then obj:rotate(.23):scale(1.2):shift(.3*l.RIGHT) end
        local expected=c.diagnostic or c
        if c.diagnostic then
            checks=checks+1;assert(#obj.baseline_frames~=#c.baselines,'known cache mismatch unexpectedly disappeared; re-audit')
            known=known+1
        end
        local p,f,fo,s,so,w={},{},{},{},{},{}
        for j,g in ipairs(obj) do
            p[j]=g.points;f[j]={table.unpack(g.fill_color,1,3)};fo[j]=g.fill_color[4]
            s[j]={table.unpack(g.stroke_color,1,3)};so[j]=g.stroke_color[4];w[j]=g.stroke_width
        end
        eq(p,expected.points,'Typst '..i..' points');eq(f,expected.fills,'fill '..i);eq(fo,expected.fill_opacity,'fill opacity '..i)
        eq(s,expected.strokes,'stroke '..i);eq(so,expected.stroke_opacity,'stroke opacity '..i);eq(w,expected.widths,'width '..i)
        eq(obj.baseline_frames,expected.baselines,'baseline '..i)
        if expected.font_size~=0 then eq(obj.font_size,expected.font_size,'font size '..i) end
        for _,selection in ipairs(c.selections) do
            local chosen=obj:select(selection.key);eq(#chosen,#selection.indices,'selection size')
            for j,index in ipairs(selection.indices) do checks=checks+1;assert(chosen[j]==obj[index],'selection identity/order') end
        end
        local r=l.Renderer{pixel_width=480,pixel_height=270};r:render({obj},'artifacts/typst/'..c.image);r:close()
    end
end)
local defaults=l.config.defaults
local a,b,c=l.config.with({pixel_width=123},function()
    eq(l.config.defaults.pixel_width,123,'temporary configuration')
    l.config.with({pixel_width=321},function() eq(l.config.defaults.pixel_width,321,'nested configuration') end)
    eq(l.config.defaults.pixel_width,123,'nested restoration')
    return 'value',nil,42
end)
checks=checks+1;assert(a=='value' and b==nil and c==42 and l.config.defaults==defaults,'config scope must preserve results and original table')
local function fails(fn) checks=checks+1;assert(not pcall(fn),'expected rejection') end
fails(function() l.config.with({pixel_width=123},function() error('scope error') end) end)
checks=checks+1;assert(l.config.defaults==defaults,'configuration must restore after error')
fails(function() l.config.with({frame_height=0},function() end) end)
fails(function() l.config.with({},false) end)
local sample=l.MathTypst('{{ x+y : sum }}',{track_baselines=true})
local copy=sample:copy();checks=checks+1;assert(copy[1]~=sample[1] and copy:select('sum')[1]==copy[1],'copy must preserve copied group identity')
eq(copy.baseline_frames,sample.baseline_frames,'copied baseline graph')
local before=sample:get_width();copy:scale(2);eq(sample:get_width(),before,'independent copy scale')
fails(function() sample:select('missing') end);fails(function() sample:select(0) end)
local untracked=l.MathTypst('x');eq(#untracked.baseline_frames,0,'disabled baseline tracking')
fails(function() untracked:get_baseline_frame(untracked[1]) end)
fails(function() l.MathTypst('x',{font_size=0}) end)
fails(function() l.MathTypst('x',{font_size=0/0}) end)
fails(function() l.Typst('x',{typst_bin='/missing-luanimath-typst'}) end)
fails(function() l.MathTypst('unknown_luanimath_variable') end)
fails(function() l.Typst('a\0b') end)
fails(function() l.Typst('\255') end)
local cache="artifacts/typst/cache 'quoted'\nUTF8-λ"
local file=l.typst_to_svg_file('$ x+1 $',{cache_dir=cache})
local function read(path) local f=assert(io.open(path,'rb'));local data=f:read('*a');f:close();return data end
local original=read(file)
eq(l.typst_to_svg_file('$ x+1 $',{cache_dir=cache}),file,'compiled cache hit')
local f=assert(io.open(file,'wb'));f:write('<svg/>');f:close()
eq(l.typst_to_svg_file('$ x+1 $',{cache_dir=cache}),file,'cache repair path')
eq(read(file),original,'corrupt cache must be recompiled')
local shape=l.Square{fill_color=l.RED,fill_opacity=.4,stroke_color=l.BLUE,stroke_opacity=.2}
eq(shape:get_color(),{252/255,98/255,85/255,1},'opaque fill color query')
shape:set_fill(nil,0);eq(shape.color,{88/255,196/255,221/255,1},'stroke fallback color')
shape.color=l.GREEN;eq(shape:get_color(),{131/255,193/255,103/255,1},'color property assignment')
shape:set_fill(l.BLACK,0):set_stroke(l.BLACK,0,0);checks=checks+1;assert(shape:get_color()==nil,'all-zero paint returns nil')
print(('PASS: %d Typst states and %d capture cases, %d checks; %d original-upstream cache differences separately diagnosed'):format(#data.cases,#data.parsers,checks,known))
