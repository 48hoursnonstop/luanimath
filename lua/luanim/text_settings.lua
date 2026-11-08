-- Manim Text._text2settings: independent shaping runs and overlapping styles.
local C=require('luanim.color')
local U=require('luanim.util')
local S={}
function S.hex(color)
    local c=C.parse(color)
    return ('#%02X%02X%02X'):format(math.floor(c[1]*255),math.floor(c[2]*255),math.floor(c[3]*255))
end
function S.build(text,opts)
    local chars={};local byte_index={}
    for pos,code in utf8.codes(text) do byte_index[pos]=#chars;chars[#chars+1]=utf8.char(code) end
    byte_index[#text+1]=#chars
    local n=#chars
    local defaults={font=opts.font or '',slant=opts.slant or 'NORMAL',weight=opts.weight or 'NORMAL',color=S.hex(opts.color or C.WHITE)}
    local maps={font=opts.text2font or opts.t2f or {},slant=opts.text2slant or opts.t2s or {},
        weight=opts.text2weight or opts.t2w or {},color=opts.text2color or opts.t2c or {}}
    local keys={}
    for _,map in pairs(maps) do
        assert(type(map)=='table','text style maps must be tables')
        for word in pairs(map) do assert(type(word)=='string' and word~='','text selector must be a nonempty string');keys[word]=true end
    end
    local function occurrences(word)
        local ranges={};local a,b=word:match('^%[([%d%-]*):([%d%-]*)%]')
        if a then
            a=a=='' and 0 or assert(tonumber(a),'invalid text slice selector')
            b=b=='' and n or assert(tonumber(b),'invalid text slice selector')
            if a<0 then a=n+a end;if b<0 then b=n+b end
            assert(a>=0 and a<=b and b<=n,'text slice selector outside supported bounds')
            return {{a,b}}
        end
        local from=1
        while true do
            local first,last=text:find(word,from,true);if not first then break end
            assert(byte_index[first] and byte_index[last+1],'text selector must align with UTF-8 characters')
            ranges[#ranges+1]={byte_index[first],byte_index[last+1]};from=last+1
        end
        return ranges
    end
    local records={};local events={[0]=true,[n]=true}
    local function add(first,last,values)
        if first==last then return end
        records[#records+1]={first=first,last=last,values=values};events[first]=true;events[last]=true
    end
    local words={};for word in pairs(keys) do words[#words+1]=word end;table.sort(words)
    for _,word in ipairs(words) do
        local values={}
        for key,map in pairs(maps) do
            if map[word]~=nil then values[key]=key=='color' and S.hex(map[word]) or map[word] end
        end
        for _,range in ipairs(occurrences(word)) do add(range[1],range[2],values) end
    end
    if opts.gradient and #opts.gradient>0 then
        local colors=C.color_gradient(opts.gradient,n)
        for i=1,n do add(i-1,i,{color=S.hex(colors[i])}) end
    end
    for word,gradient in pairs(opts.text2gradient or opts.t2g or {}) do
        local colors=C.color_gradient(gradient,assert(utf8.len(word),'invalid UTF-8 selector'))
        for _,range in ipairs(occurrences(word)) do
            for i=range[1],range[2]-1 do add(i,i+1,{color=S.hex(assert(colors[i-range[1]+1],'gradient selector too short'))}) end
        end
    end
    for i,c in ipairs(chars) do if c=='\n' then events[i]=true end end
    local boundaries={};for at in pairs(events) do boundaries[#boundaries+1]=at end;table.sort(boundaries)
    local result={};local line=0
    for i=1,#boundaries-1 do
        local first,last=boundaries[i],boundaries[i+1];local style=U.merge({},defaults)
        for _,record in ipairs(records) do
            if record.first<=first and record.last>=last then
                for key,value in pairs(record.values) do
                    if value~=defaults[key] then
                        assert(style[key]==defaults[key],'ambiguous overlapping text style: '..key)
                        style[key]=value
                    end
                end
            end
        end
        style.text=table.concat(chars,'',first+1,last):gsub('\n',' ');style.line=line
        result[#result+1]=style
        for j=first+1,last do if chars[j]=='\n' then line=line+1 end end
    end
    return result
end
return S
