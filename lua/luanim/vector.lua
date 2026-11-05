local U = require('luanim.util')
local V = {}
local mt = {__index = V}

function V.new(x, y, z)
    if type(x) == 'table' then x, y, z = x[1], x[2], x[3] end
    return setmetatable({U.number(x or 0, 'x'), U.number(y or 0, 'y'), U.number(z or 0, 'z')}, mt)
end

function mt.__add(a, b) return V.new(a[1]+b[1], a[2]+b[2], a[3]+b[3]) end
function mt.__sub(a, b) return V.new(a[1]-b[1], a[2]-b[2], a[3]-b[3]) end
function mt.__unm(a) return V.new(-a[1], -a[2], -a[3]) end
function mt.__mul(a, b)
    if type(a) == 'number' then a, b = b, a end
    U.number(b, 'scalar')
    return V.new(a[1]*b, a[2]*b, a[3]*b)
end
function mt.__div(a, b)
    U.number(b, 'scalar'); assert(b ~= 0, 'division by zero')
    return a * (1/b)
end
function mt.__tostring(a) return ('vec(%.12g, %.12g, %.12g)'):format(a[1],a[2],a[3]) end
function V.dot(a, b) return a[1]*b[1]+a[2]*b[2]+a[3]*b[3] end
function V.cross(a, b) return V.new(a[2]*b[3]-a[3]*b[2], a[3]*b[1]-a[1]*b[3], a[1]*b[2]-a[2]*b[1]) end
function V.norm(a) return math.sqrt(V.dot(a,a)) end
function V.normalize(a)
    a = V.new(a)
    local n = V.norm(a)
    assert(n > 0, 'cannot normalize zero vector')
    return a / n
end
function V.lerp(a, b, t) return V.new(a)*(1-t)+V.new(b)*t end
function V.rotate(p, angle, axis)
    local n = V.normalize(axis or {0,0,1})
    p = V.new(p)
    return p*math.cos(angle)+V.cross(n,p)*math.sin(angle)+n*(V.dot(n,p)*(1-math.cos(angle)))
end
function V.close(a,b,tolerance)
    return V.norm(V.new(a)-V.new(b)) <= (tolerance or 1e-6)
end
return setmetatable(V, {__call = function(_, ...) return V.new(...) end})
