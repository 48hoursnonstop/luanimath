local l=require('luanim')
local U=require('luanim.util')
local data=dofile('tests/reference_svg.lua')
local checks=0
local function eq(a,b,label)
    if type(a)=='table' then
        assert(type(b)=='table' and #a==#b,label..' length '..#a..' vs '..tostring(type(b)=='table' and #b or b))
        for i=1,#a do eq(a[i],b[i],label..'['..i..']') end
    else checks=checks+1;assert(math.abs(a-b)<=1e-8,('%s: %.17g vs %.17g'):format(label,a,b)) end
end
for i,c in ipairs(data.paths) do eq(l.VMobjectFromSVGPath(c.data).points,c.points,'path '..i) end
U.mkdir('artifacts/svg')
for i,c in ipairs(data.objects) do
    local obj=l.SVGMobject('tests/svg_assets/'..c.file,c.options)
    local p,f,fo,s,so,w={},{},{},{},{},{}
    for j,m in ipairs(obj.submobjects) do
        p[j]=m.points;f[j]={table.unpack(m.fill_color,1,3)};fo[j]=m.fill_color[4]
        s[j]={table.unpack(m.stroke_color,1,3)};so[j]=m.stroke_color[4];w[j]=m.stroke_width
    end
    eq(p,c.points,'SVG points '..i);eq(f,c.fills,'fill '..i);eq(fo,c.fill_opacity,'fill opacity '..i)
    eq(s,c.strokes,'stroke '..i);eq(so,c.stroke_opacity,'stroke opacity '..i);eq(w,c.widths,'width '..i)
    if not c.options.height then
        if c.options.height~=false then
            local r=l.Renderer{pixel_width=400,pixel_height=300,frame_width=32/3,frame_height=8}
            r:render({obj},'artifacts/svg/'..c.file:gsub('%.svg$','.png'));r:close()
        end
    end
end
local function fails(fn) checks=checks+1;assert(not pcall(fn),'expected rejection') end
fails(function() l.VMobjectFromSVGPath('M0 0Lbad') end)
fails(function() l.VMobjectFromSVGPath('M0 0A1 1 0 2 0 3 4') end)
fails(function() l.SVGMobject('/missing-luanim.svg') end)
fails(function() require('luanim_native').parse_xml('<svg>') end)
fails(function() require('luanim_native').parse_xml('<!DOCTYPE svg><svg/>') end)
fails(function() require('luanim_native').parse_xml('<svg>\0</svg>') end)
local function svg(content,opts)
    local f=assert(io.open('artifacts/svg/input.svg','wb'));f:write('<svg xmlns="http://www.w3.org/2000/svg">'..content..'</svg>');f:close()
    return l.SVGMobject('artifacts/svg/input.svg',opts)
end
fails(function() svg('<use id="loop" href="#loop"/>') end)
fails(function() svg('<use href="https://example.com/a.svg#x"/>') end)
fails(function() svg('<rect width="50%" height="10"/>') end)
fails(function() svg('<path d="M0 0L10 10" fill="url(#gradient)"/>') end)
fails(function() svg('<rect width="10" height="10" style="clip-path:url(#clip)"/>') end)
fails(function() svg('<text>unsupported</text>') end)
eq(#svg('').submobjects,0,'empty SVG')
eq(#svg('<rect width="0" height="10"/>').submobjects,0,'degenerate rectangle')
local customized=svg('<rect width="10" height="5"/>',{height=1,width=3,fill_color=l.YELLOW,fill_opacity=.25,stroke_width=2,stroke_color=l.RED,stroke_opacity=.5})
eq(customized:get_width(),3,'width option');eq(customized:get_height(),1.5,'height then width')
eq(customized.submobjects[1].fill_color,{1,1,0,.25},'fill override')
eq(customized.submobjects[1].stroke_color,{252/255,98/255,85/255,.5},'stroke override')
eq(customized.submobjects[1].stroke_width,2,'stroke width override')
local ids=l.SVGMobject('tests/svg_assets/use.svg').id_to_vgroup_dict
eq(#ids.letters.submobjects,2,'group id lookup')
print(('PASS: %d path, %d SVG object cases, %d scalar/invalid-input checks'):format(#data.paths,#data.objects,checks))
