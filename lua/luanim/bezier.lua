-- Cubic representation and de Casteljau subdivision follow Manim utils/bezier.py.
local V = require('luanim.vector')
local U = require('luanim.util')
local B = {}
function B.point(c,t)
    local q=1-t
    return V(c[1])*(q*q*q)+V(c[2])*(3*q*q*t)+V(c[3])*(3*q*t*t)+V(c[4])*(t*t*t)
end
function B.split(c,t)
    local a,b,d = V.lerp(c[1],c[2],t), V.lerp(c[2],c[3],t), V.lerp(c[3],c[4],t)
    local e,f = V.lerp(a,b,t),V.lerp(b,d,t)
    local p=V.lerp(e,f,t)
    return {V(c[1]),a,e,p}, {p,f,d,V(c[4])}
end
function B.partial(c,a,b)
    assert(a >= 0 and b <= 1 and a <= b,'partial curve requires 0 <= a <= b <= 1')
    if a == 1 then local p=V(c[4]); return {p,V(p),V(p),V(p)} end
    local _,right=B.split(c,a)
    local left=B.split(right,(b-a)/(1-a))
    return left
end
function B.length(c,samples)
    samples=samples or 10
    U.integer(samples,'samples',2)
    local length,old=0,V(c[1])
    for i=1,samples-1 do local p=B.point(c,i/(samples-1));length=length+V.norm(p-old);old=p end
    return length
end
function B.curves(points)
    assert(#points%4==0,'cubic point count must be divisible by four')
    local out={}
    for i=1,#points,4 do out[#out+1]={points[i],points[i+1],points[i+2],points[i+3]} end
    return out
end
function B.append(points,c) for _,p in ipairs(c) do points[#points+1]=V(p) end end
function B.line(a,b) return {V(a),V.lerp(a,b,1/3),V.lerp(a,b,2/3),V(b)} end
function B.remap(points,count)
    local curves=B.curves(points)
    assert(#curves>0 and count>=#curves,'remap requires existing curves and a larger count')
    local split_counts={}
    for i=1,#curves do split_counts[i]=0 end
    for i=0,count-1 do local index=math.floor(i*#curves/count)+1;split_counts[index]=split_counts[index]+1 end
    local result={}
    for i,c in ipairs(curves) do
        for j=0,split_counts[i]-1 do B.append(result,B.partial(c,j/split_counts[i],(j+1)/split_counts[i])) end
    end
    return result
end
function B.partial_path(points,a,b)
    U.number(a,'a');U.number(b,'b')
    assert(a>=0 and b<=1 and a<=b,'partial path requires 0 <= a <= b <= 1')
    if #points==0 then return {} end
    if a==0 and b==1 then return U.copy(points) end
    local curves=B.curves(points)
    local n=#curves
    local low=math.min(n-1,math.floor(a*n))
    local high=math.min(n-1,math.floor(b*n))
    local result={}
    for i=low,high do
        B.append(result,B.partial(curves[i+1],i==low and a*n-low or 0,i==high and b*n-high or 1))
    end
    return result
end
return B
