local U=require('luanimath.util')
local S={}
local Scale={};Scale.__index=Scale
local function values(value,fn)
    if type(value)=='table' then local out={};for i,x in ipairs(value) do out[i]=values(x,fn) end;return out end
    return U.number(fn(U.number(value,'scale input')),'scale result')
end
function Scale:map(value)
    return values(value,function(x) return self.kind=='LinearBase' and x*self.scale_factor or self.base^x end)
end
function Scale:inverse(value)
    return values(value,function(x)
        if self.kind=='LinearBase' then return x/self.scale_factor end
        assert(x>0,'logarithmic scale input must be positive')
        return math.log(x)/math.log(self.base)
    end)
end
function S.LinearBase(opts)
    opts=opts or {};local factor=U.number(opts.scale_factor or 1,'scale_factor')
    assert(factor~=0,'scale_factor must be nonzero')
    return setmetatable({kind='LinearBase',scale_factor=factor,custom_labels=false},Scale)
end
function S.LogBase(opts)
    opts=opts or {};local base=U.number(opts.base or 10,'log base')
    assert(base>0 and base~=1,'log base must be positive and different from 1')
    return setmetatable({kind='LogBase',base=base,custom_labels=opts.custom_labels~=false},Scale)
end
function S._resolve(scale)
    scale=scale or S.LinearBase()
    assert(type(scale)=='table' and type(scale.map)=='function' and type(scale.inverse)=='function','scaling requires map and inverse methods')
    return scale
end
return S
