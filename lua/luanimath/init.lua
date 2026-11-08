local V=require('luanimath.vector')
local api={version='0.9.0-dev',vec=V,Vector=V,Mobject=require('luanimath.mobject'),
    Scene=require('luanimath.scene'),Renderer=require('luanimath.renderer'),
    config=require('luanimath.config'),bezier=require('luanimath.bezier'),rate_functions=require('luanimath.rate_functions'),
    PI=math.pi,TAU=2*math.pi,DEGREES=math.pi/180,
    NORMAL='NORMAL',BOLD='BOLD',LIGHT='LIGHT',ITALIC='ITALIC',OBLIQUE='OBLIQUE',
    ORIGIN=V(),RIGHT=V(1,0,0),LEFT=V(-1,0,0),UP=V(0,1,0),DOWN=V(0,-1,0),OUT=V(0,0,1),IN=V(0,0,-1),
    UR=V(1,1,0),UL=V(-1,1,0),DR=V(1,-1,0),DL=V(-1,-1,0)}
for _,name in ipairs({'geometry','animation','color','text','graphing','paths','camera','three_d','svg','typst','typst_file'}) do
    for k,v in pairs(require('luanimath.'..name)) do if k:sub(1,1)~='_' then api[k]=v end end
end
function api.ThreeDScene(construct,opts)
    local U=require('luanimath.util');opts=opts or {}
    return api.Scene(construct,U.merge(opts,{camera=api.ThreeDCamera(opts)}))
end
function api.MovingCameraScene(construct,opts)
    local U=require('luanimath.util');opts=opts or {}
    return api.Scene(construct,U.merge(opts,{camera=api.MovingCamera(opts)}))
end
for k,v in pairs(api.rate_functions) do api[k]=v end
return api
