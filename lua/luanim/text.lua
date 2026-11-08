local G=require('luanim.geometry')
local N=require('luanim_native')
local V=require('luanim.vector')
local U=require('luanim.util')
local SVG=require('luanim.svg')
local B=require('luanim.bezier')
local T={}
local function is_space(code)
    return (code>=9 and code<=13) or (code>=28 and code<=32) or code==0x85 or code==0xa0 or code==0x1680
        or (code>=0x2000 and code<=0x200a) or code==0x2028 or code==0x2029 or code==0x202f or code==0x205f or code==0x3000
end
function T.Text(text,opts)
    assert(type(text)=='string','Text requires a UTF-8 string');opts=opts or {}
    local size=U.number(opts.font_size or 48,'font_size');assert(size>0,'font_size must be positive')
    local tabs=U.integer(opts.tab_width or 4,'tab_width',0)
    local expanded=text:gsub('\t',string.rep(' ',tabs))
    local spacing=opts.line_spacing
    if spacing==nil or spacing==-1 then spacing=size*1.3 else spacing=size*(1+U.number(spacing,'line_spacing')) end
    local data=N.text_svg(expanded,opts.font or '',size,opts.weight or 'NORMAL',opts.slant or 'NORMAL',not not opts.disable_ligatures,spacing)
    local object=SVG._from_data(data,{height=opts.height or false,width=opts.width,should_center=opts.should_center})
    object.kind='Text';object.original_text=text;object._font_size=size;object.font=opts.font or ''
    object.text=expanded:gsub(' ',''):gsub('\n','')
    object:set_fill(opts.fill_color or opts.color or '#FFFFFF',opts.fill_opacity or 1)
    object:set_stroke(opts.stroke_color,opts.stroke_width or 0,opts.stroke_opacity)
    if opts.disable_ligatures then
        local chars={};local index=1
        for _,code in utf8.codes(text) do
            if is_space(code) then
                local anchor=assert(object.submobjects[index==1 and 1 or index-1],'cannot map whitespace without a rendered glyph')
                chars[#chars+1]=G.Dot(anchor:get_center(),{radius=0,fill_opacity=0,stroke_opacity=0})
            else
                chars[#chars+1]=assert(object.submobjects[index],'font rendered fewer glyphs than non-space characters with disable_ligatures')
                index=index+1
            end
        end
        object.submobjects=chars
    end
    for _,glyph in ipairs(object.submobjects) do
        local points=glyph.points
        if #points>0 then
            local closed={};local start=points[1]
            for i=1,#points,4 do
                for j=i,i+3 do closed[#closed+1]=V(points[j]) end
                if i+3<#points and not V.close(points[i+3],points[i+4],0) then
                    B.append(closed,B.line(points[i+3],start));start=points[i+4]
                end
            end
            B.append(closed,B.line(points[#points],start));glyph:set_points(closed)
        end
    end
    if not opts.height and not opts.width then object:scale(.05) end
    object.chars=G.VGroup(table.unpack(object.submobjects));object.initial_height=object:get_height()
    return object
end
function T.font_list() local fonts=N.font_list();table.sort(fonts);return fonts end
return T
