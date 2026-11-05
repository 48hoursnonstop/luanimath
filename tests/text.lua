local l=require('luanim')
local U=require('luanim.util')
local checks,known_differences=0,0
local function eq(a,b,label)
    checks=checks+1
    assert(math.abs(a-b)<=1e-4,label..': '..a..' vs '..b)
end
U.mkdir('artifacts/text')
local cases=dofile('tests/reference_text.lua')
for i,case in ipairs(cases) do
    local obj=l.Text(case.text,case.options)
    local expected=case
    if case.known_difference then
        assert(not pcall(eq,obj:get_width(),case.width,'known upstream mismatch'),'known mismatch unexpectedly disappeared; re-audit')
        known_differences=known_differences+1
        print('KNOWN DIFFERENCE: '..case.known_difference)
        expected=case.diagnostic
    end
    eq(obj:get_width(),expected.width,'width '..i);eq(obj:get_height(),expected.height,'height '..i)
    for d=1,3 do eq(obj:get_center()[d],expected.center[d],'center '..i) end
    local renderer=l.Renderer{pixel_width=480,pixel_height=270,frame_height=8,frame_width=128/9}
    renderer:render({obj},'artifacts/text/'..case.image);renderer:close()
end
local function fails(fn) checks=checks+1;assert(not pcall(fn),'expected rejection') end
fails(function() l.Text('bad',{font_size=0}) end)
fails(function() l.Text('bad',{font_size=0/0}) end)
fails(function() l.Text('bad',{weight='INVALID'}) end)
fails(function() l.Text('\255') end)
fails(function() l.Text('a\0b') end)
assert(#l.font_list()>0);checks=checks+1
local dot=l.Text('A',{font='Liberation Sans'}):shift(l.RIGHT):rotate(0.2)
assert(#dot.points>0 and #dot.points%4==0);checks=checks+1
assert(known_differences==1,'known differences must remain explicitly enumerated')
print(('PASS: %d native text cases, %d checks; %d original-upstream difference, separately validated with corrected Pango layout'):format(#cases,checks,known_differences))
