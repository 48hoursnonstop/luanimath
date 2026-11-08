local U=require('luanimath.util')
local R={}
local function unit(fn)
    return function(t,...) U.number(t,'t'); if t<0 then return 0 elseif t>1 then return 1 end; return fn(t,...) end
end
R.linear=unit(function(t) return t end)
R.smooth=unit(function(t,k)
    k=k or 10
    local function sigmoid(x) return 1/(1+math.exp(-x)) end
    local e=sigmoid(-k/2)
    return U.clamp((sigmoid(k*(t-0.5))-e)/(1-2*e))
end)
R.smoothstep=unit(function(t) return t*t*(3-2*t) end)
R.smootherstep=unit(function(t) return t^3*(10-15*t+6*t*t) end)
R.smoothererstep=unit(function(t) return 35*t^4-84*t^5+70*t^6-20*t^7 end)
R.rush_into=unit(function(t,k) return 2*R.smooth(t/2,k) end)
R.rush_from=unit(function(t,k) return 2*R.smooth(t/2+0.5,k)-1 end)
R.slow_into=unit(function(t) return math.sqrt(1-(1-t)^2) end)
R.double_smooth=unit(function(t) if t<0.5 then return 0.5*R.smooth(2*t) end;return 0.5*(1+R.smooth(2*t-1)) end)
function R.there_and_back(t,k)
    U.number(t,'t');if t<0 or t>1 then return 0 end
    return R.smooth(t<0.5 and 2*t or 2*(1-t),k)
end
return R
