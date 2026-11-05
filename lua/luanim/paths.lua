local V=require('luanim.vector')
local U=require('luanim.util')
local P={}
function P.straight_path()
    return function(start,finish,alpha)
        assert(#start==#finish,'path point arrays must have equal lengths')
        local out={};for i,p in ipairs(start) do out[i]=V.lerp(p,finish[i],alpha) end;return out
    end
end
function P.path_along_arc(angle,axis)
    U.number(angle,'arc angle')
    if math.abs(angle)<.01 then return P.straight_path() end
    axis=V(axis or {0,0,1});axis=V.norm(axis)==0 and V(0,0,1) or V.normalize(axis)
    return function(start,finish,alpha)
        assert(#start==#finish,'path point arrays must have equal lengths')
        local out={}
        for i,p in ipairs(start) do
            p=V(p);local delta=V(finish[i])-p;local center=p+delta/2
            if angle~=math.pi then center=center+V.cross(axis,delta/2)/math.tan(angle/2) end
            out[i]=center+V.rotate(p-center,alpha*angle,axis)
        end
        return out
    end
end
function P.path_along_circles(angle,centers,axis)
    U.number(angle,'arc angle');assert(type(centers)=='table','circle centers must be a point or point array')
    axis=V(axis or {0,0,1});axis=V.norm(axis)==0 and V(0,0,1) or V.normalize(axis)
    local single=type(centers[1])=='number'
    return function(start,finish,alpha)
        assert(#start==#finish,'path point arrays must have equal lengths')
        local out={}
        for i,p in ipairs(start) do
            local center=V(single and centers or assert(centers[i],'missing circle center'))
            local end_point=center+V.rotate(V(finish[i])-center,-angle,axis)
            out[i]=center+V.rotate(V.lerp(p,end_point,alpha)-center,alpha*angle,axis)
        end
        return out
    end
end
function P.clockwise_path() return P.path_along_arc(-math.pi) end
function P.counterclockwise_path() return P.path_along_arc(math.pi) end
return P
