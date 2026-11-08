-- Cubic representation and de Casteljau subdivision follow Manim utils/bezier.py.
local V = require('luanimath.vector')
local U = require('luanimath.util')
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
    assert(#points%4==0 or #points%4==1,'cubic point count requires complete curves and an optional pending anchor')
    local out={}
    for i=1,#points-3,4 do out[#out+1]={points[i],points[i+1],points[i+2],points[i+3]} end
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
function B.subpaths(points)
    local out,current={},nil
    for _,c in ipairs(B.curves(points)) do
        if not current or not V.close(current[#current],c[1],1e-6) then current={};out[#out+1]=current end
        B.append(current,c)
    end
    return out
end
local function tridiagonal(lower,diagonal,upper,rhs)
    local n=#diagonal;local c,d={},{ }
    c[1]=(upper[1] or 0)/diagonal[1];d[1]=rhs[1]/diagonal[1]
    for i=2,n do
        local denominator=diagonal[i]-lower[i]*c[i-1]
        c[i]=(upper[i] or 0)/denominator;d[i]=(rhs[i]-d[i-1]*lower[i])/denominator
    end
    local result={[n]=d[n]}
    for i=n-1,1,-1 do result[i]=d[i]-result[i+1]*c[i] end
    return result
end
function B.smooth(anchors)
    assert(#anchors>=1,'at least one anchor required')
    if #anchors==1 then return {} end
    local a={};for i,p in ipairs(anchors) do a[i]=V(p) end
    local n=#a-1
    if n==1 then return B.line(a[1],a[2]) end
    local closed=V.close(a[1],a[#a],1e-6)
    local lower,diagonal,upper,rhs={},{},{},{}
    for i=1,n do lower[i]=1;diagonal[i]=4;upper[i]=1;rhs[i]=a[i]*4+a[i+1]*2 end
    if closed then
        diagonal[1]=3;diagonal[n]=3
    else
        diagonal[1]=2;diagonal[n]=7;lower[n]=2
        rhs[1]=a[1]+a[2]*2;rhs[n]=a[n]*8+a[n+1]
    end
    local handles=tridiagonal(lower,diagonal,upper,rhs)
    if closed then
        local unit={};for i=1,n do unit[i]=(i==1 or i==n) and 1 or 0 end
        local q=tridiagonal(lower,diagonal,upper,unit)
        local correction=(handles[1]+handles[n])/(1+q[1]+q[n])
        for i=1,n do handles[i]=handles[i]-correction*q[i] end
    end
    local points={}
    for i=1,n do
        local second=i<n and a[i+1]*2-handles[i+1] or closed and a[1]*2-handles[1] or (a[n+1]+handles[n])/2
        B.append(points,{a[i],handles[i],second,a[i+1]})
    end
    return points
end
function B.partial_path(points,a,b)
    U.number(a,'a');U.number(b,'b')
    if #points==0 then return {} end
    if a<=0 and b>=1 then return U.copy(points) end
    a,b=U.clamp(a),U.clamp(b)
    assert(a<=b,'partial path requires a <= b after clamping')
    local curves=B.curves(points)
    local n=#curves
    if n==0 then return U.copy(points) end
    local low=math.min(n-1,math.floor(a*n))
    local high=math.min(n-1,math.floor(b*n))
    local result={}
    for i=low,high do
        B.append(result,B.partial(curves[i+1],i==low and a*n-low or 0,i==high and b*n-high or 1))
    end
    return result
end
return B
