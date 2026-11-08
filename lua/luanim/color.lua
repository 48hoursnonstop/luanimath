local U = require('luanim.util')
local M = {
    WHITE='#FFFFFF', BLACK='#000000', RED='#FC6255', BLUE='#58C4DD', GREEN='#83C167',
    YELLOW='#FFFF00', PURPLE='#9A72AC', TEAL='#5CD0B3', ORANGE='#FF862F', PINK='#D147BD',
    GREY='#888888', GRAY='#888888', BLUE_D='#29ABCA', RED_D='#E65A4C', GREEN_D='#77B05D',
}
function M.parse(c, alpha)
    if type(c) == 'string' then
        c = M[c] or c
        c = c:gsub('^#','')
        if #c == 3 then c = c:gsub('.',function(x) return x..x end) end
        assert((#c == 6 or #c == 8) and c:match('^%x+$'), 'color must be a name, RGB(A) hex, or a unit RGB(A) table')
        c = {tonumber(c:sub(1,2),16)/255, tonumber(c:sub(3,4),16)/255,
             tonumber(c:sub(5,6),16)/255, #c == 8 and tonumber(c:sub(7,8),16)/255 or 1}
    end
    assert(type(c) == 'table' and (#c == 3 or #c == 4), 'color requires 3 or 4 components')
    local out = {c[1],c[2],c[3],alpha == nil and (c[4] or 1) or alpha}
    for _, n in ipairs(out) do U.number(n,'color component'); assert(n >= 0 and n <= 1,'color components must be in [0,1]') end
    return out
end
function M.interpolate(a,b,t)
    a,b = M.parse(a), M.parse(b)
    local r = {}
    for i=1,4 do r[i] = a[i]*(1-t)+b[i]*t end
    return r
end
function M.color_gradient(colors,length)
    U.integer(length,'gradient length',0);assert(type(colors)=='table','reference colors must be a sequence')
    if length==0 then return {} end
    assert(#colors>0,'gradient needs at least one reference color')
    local parsed={};for i,c in ipairs(colors) do parsed[i]=M.parse(c) end
    local result={}
    for i=1,length do
        if #parsed==1 then result[i]=M.parse(parsed[1])
        else
            local step=length>1 and (#parsed-1)/(length-1) or 0
            local x=i==length and #parsed-1 or (i-1)*step
            local at=math.min(math.floor(x),#parsed-2);local t=x-at
            local color=M.interpolate(parsed[at+1],parsed[at+2],t);color[4]=1;result[i]=color
        end
    end
    return result
end
return M
