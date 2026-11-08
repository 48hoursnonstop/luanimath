-- Source-derived MathTypst capture parsing and layout-preserving SVG probes.
local SVG=require('luanimath.svg')
local G={}
local function trim(text) return text:match('^%s*(.-)%s*$') end
function G.preprocess(expression)
    assert(type(expression)=='string','MathTypst requires a string')
    local labels={};local auto=0
    local function process(text)
        local result={};local i=1;local quoted=false;local brackets=0
        while i<=#text do
            local ch=text:sub(i,i)
            if quoted then
                result[#result+1]=ch
                if ch=='\\' and i<#text then result[#result+1]=text:sub(i+1,i+1);i=i+2
                else if ch=='"' then quoted=false end;i=i+1 end
            elseif ch=='"' then quoted=true;result[#result+1]=ch;i=i+1
            elseif ch=='[' then brackets=brackets+1;result[#result+1]=ch;i=i+1
            elseif ch==']' and brackets>0 then brackets=brackets-1;result[#result+1]=ch;i=i+1
            elseif brackets>0 or text:sub(i,i+1)~='{{' then result[#result+1]=ch;i=i+1
            else
                local group_start=i;local first=i+2;local depth=1;local in_string=false;local square=0;i=i+2
                local finish
                while i<=#text do
                    ch=text:sub(i,i)
                    if in_string then
                        if ch=='\\' and i<#text then i=i+2 else if ch=='"' then in_string=false end;i=i+1 end
                    elseif ch=='"' then in_string=true;i=i+1
                    elseif ch=='[' then square=square+1;i=i+1
                    elseif ch==']' and square>0 then square=square-1;i=i+1
                    elseif square>0 then i=i+1
                    elseif text:sub(i,i+1)=='{{' then depth=depth+1;i=i+2
                    elseif text:sub(i,i+1)=='}}' then
                        depth=depth-1;if depth==0 then finish=i-1;i=i+2;break end;i=i+2
                    else i=i+1 end
                end
                if not finish then result[#result+1]=text:sub(group_start);return table.concat(result) end
                local content=text:sub(first,finish)
                local body,label=content:match('^(.*)%s*:%s*([a-zA-Z_][a-zA-Z0-9_%-]*)%s*$')
                if not body then body=content;label='_grp-'..auto;auto=auto+1 end
                labels[#labels+1]=label
                result[#result+1]='manimgrp("'..label..'", '..process(trim(body))..')'
            end
        end
        return table.concat(result)
    end
    local processed=process(expression);return processed,labels
end
function G.preamble(label)
    local target=label and '"'..label..'"' or 'none'
    return '#let manimgrp(lbl, body) = if lbl == '..target..' { hide(body) } else { body }'
end
local leaves={circle=true,ellipse=true,image=true,line=true,path=true,polygon=true,polyline=true,rect=true,text=true,use=true}
function G.leaves(root)
    local result={}
    local function visit(parent,matrix,inside_defs)
        for index,node in ipairs(parent.children) do
            local defs=inside_defs or node.name=='defs'
            local effective=SVG._multiply(matrix,SVG._transform(node.attributes.transform))
            if not defs and leaves[node.name] then result[#result+1]={node=node,parent=parent,index=index,matrix=effective} end
            visit(node,effective,defs)
        end
    end
    visit(root,{1,0,0,1,0,0},false);return result
end
local function signature(leaf)
    local parts={leaf.node.name};local names={}
    for key in pairs(leaf.node.attributes) do if key~='transform' then names[#names+1]=key end end;table.sort(names)
    for _,key in ipairs(names) do
        local value=leaf.node.attributes[key];parts[#parts+1]=#key..':'..key..#value..':'..value
    end
    for _,value in ipairs(leaf.matrix) do
        if math.abs(value)<.5e-12 then value=0 end
        parts[#parts+1]=('%.12f'):format(value)
    end
    return table.concat(parts,'|')
end
function G.hidden(visible,probe)
    local hidden={};local at=1
    for i,leaf in ipairs(visible) do
        if probe[at] and signature(leaf)==signature(probe[at]) then at=at+1 else hidden[#hidden+1]=i end
    end
    assert(at>#probe,'MathTypst hide probe changed visible geometry; a custom hide show rule may interfere with selection')
    return hidden
end
function G.decorate(root,captures)
    local counts={}
    local function next_id(label)
        local n=counts[label] or 0;counts[label]=n+1
        return n==0 and label or label..'__manim_typst_dup_'..n
    end
    if captures then
        for index,leaf in ipairs(G.leaves(root)) do
            local node=leaf.node;local labels=captures[index] or {}
            for i=#labels,1,-1 do node={name='g',attributes={id=next_id(labels[i])},children={node}} end
            leaf.parent.children[leaf.index]=node
        end
    end
    local function promote(node)
        local label=node.attributes['data-typst-label']
        if label then node.attributes.id=next_id(label);node.attributes['data-typst-label']=nil end
        for _,child in ipairs(node.children) do promote(child) end
    end
    promote(root)
end
return G
