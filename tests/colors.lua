local l=require('luanimath')
local U=require('luanimath.util')
local colors=dofile('tests/reference_colors.lua')
local names={};local checks=0
for name,expected in pairs(colors) do
    names[#names+1]=name
    checks=checks+1;assert(l[name]==expected.hex,'palette hex mismatch: '..name)
    for _,input in ipairs({l[name],name}) do
        local actual=l.parse(input)
        for i=1,4 do checks=checks+1;assert(math.abs(actual[i]-expected.rgba[i])<1e-15,'palette RGBA mismatch: '..name) end
    end
end
table.sort(names);assert(#names==89)
local shapes={}
for index,name in ipairs(names) do
    local at=index-1;local x=(at%10-4.5)*1.2;local y=(4-math.floor(at/10))*.7
    shapes[#shapes+1]=l.Rectangle{width=1,height=.5,color=l[name],fill_opacity=1,stroke_width=0}:shift(l.vec(x,y,0))
end
U.mkdir('artifacts/colors');local renderer=l.Renderer{pixel_width=480,pixel_height=270}
renderer:render(shapes,'artifacts/colors/palette.png');renderer:close()
print(('PASS: 89 named colors/aliases and %d exact value/parse checks; actual native palette image'):format(checks))
