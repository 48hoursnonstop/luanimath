-- Enumerate the actual exported Lua surface without parsing Python signatures.
local l=require('luanimath')
local seen={};local id=0
local function info(name,fn,category)
    if not seen[fn] then id=id+1;seen[fn]=id end
    local detail=debug.getinfo(fn,'Su');local args={}
    for i=1,detail.nparams do local key=debug.getlocal(fn,i);if key~='self' then args[#args+1]=key end end
    local source=(detail.source or ''):gsub('^@',''):gsub('^%./','')
    io.write(table.concat({'F',name,table.concat(args,','),tostring(detail.isvararg),source,tostring(detail.linedefined),tostring(seen[fn]),category},'\t'),'\n')
end
local function methods(owner,object,category)
    local keys={};for key,fn in pairs(object) do if type(fn)=='function' and key:sub(1,1)~='_' and key~='new' then keys[#keys+1]=key end end;table.sort(keys)
    for _,key in ipairs(keys) do
        local first=debug.getlocal(object[key],1)
        info(owner..(first=='self' and ':' or '.')..key,object[key],category)
    end
end
local roots={};for key in pairs(l) do roots[#roots+1]=key end;table.sort(roots)
for _,key in ipairs(roots) do
    local value=l[key]
    if type(value)=='function' then info(key,value,'exports')
    elseif key=='Mobject' or key=='Scene' or key=='Renderer' then info(key,value.new,key:lower())
    elseif key=='vec' or key=='Vector' then info(key,value.new,'vectors')
    elseif type(value)=='number' or type(value)=='string' then io.write('D\t',key,'\t',tostring(value),'\n')
    elseif type(value)=='table' and type(value[1])=='number' then io.write('D\t',key,'\t',table.concat(value,', '),'\n') end
end
methods('Mobject',l.Mobject,'mobjects')
methods('Scene',l.Scene,'scenes')
methods('Renderer',l.Renderer,'rendering')
methods('Camera',getmetatable(l.ThreeDCamera()),'cameras')
methods('Animation',getmetatable(l.Write(l.Square())),'animations')
methods('AnimationGroup',getmetatable(l.AnimationGroup({l.Create(l.Square())})),'animations')
for _,module in ipairs({'vector','bezier','rate_functions','config'}) do
    local value=require('luanimath.'..module)
    local keys={};for key,fn in pairs(value) do if type(fn)=='function' and key:sub(1,1)~='_' then keys[#keys+1]=key end end;table.sort(keys)
    for _,key in ipairs(keys) do info((module=='vector' and 'vec' or module)..'.'..key,value[key],module) end
end
