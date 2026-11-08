local G=require('luanimath.geometry')
local N=require('luanimath_native')
local V=require('luanimath.vector')
local U=require('luanimath.util')
local SVG=require('luanimath.svg')
local B=require('luanimath.bezier')
local C=require('luanimath.color')
local Settings=require('luanimath.text_settings')
local T={}
local function is_space(code)
    return (code>=9 and code<=13) or (code>=28 and code<=32) or code==0x85 or code==0xa0 or code==0x1680
        or (code>=0x2000 and code<=0x200a) or code==0x2028 or code==0x2029 or code==0x202f or code==0x205f or code==0x3000
end
local function make_text(text,opts,markup)
    assert(type(text)=='string','Text requires a UTF-8 string');opts=opts or {}
    local size=U.number(opts.font_size or 48,'font_size');assert(size>0,'font_size must be positive')
    local tabs=U.integer(opts.tab_width or 4,'tab_width',0)
    local expanded=text:gsub('\t',string.rep(' ',tabs))
    local spacing=opts.line_spacing
    if spacing==nil or spacing==-1 then spacing=size*1.3 else spacing=size*(1+U.number(spacing,'line_spacing')) end
    local input=expanded
    if markup then
        local c=C.parse(opts.color or '#FFFFFF')
        input=('<span foreground="#%02X%02X%02X">%s</span>'):format(math.floor(c[1]*255),math.floor(c[2]*255),math.floor(c[3]*255),text)
        -- Upstream MarkupUtils ignores its positional line-spacing argument.
        spacing=0
    end
    local settings=not markup and Settings.build(expanded,opts) or nil
    local data=N.text_svg(input,opts.font or '',size,opts.weight or 'NORMAL',opts.slant or 'NORMAL',not not opts.disable_ligatures,spacing,markup,not not opts.justify,settings)
    local object=SVG._from_data(data,{height=opts.height or false,width=opts.width,should_center=opts.should_center})
    object.kind=markup and 'MarkupText' or 'Text';object.original_text=text;object._font_size=size;object.font=opts.font or ''
    object.text=expanded:gsub(' ',''):gsub('\n','')
    object:set_color(opts.color or C.WHITE,{family=false})
    object:set_fill(opts.fill_color,opts.fill_opacity or 1)
    object:set_stroke(opts.stroke_color,opts.stroke_width or 0,opts.stroke_opacity)
    if opts.disable_ligatures and not markup then
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
    if markup and opts.gradient and #opts.gradient>0 then object:set_color_by_gradient(table.unpack(opts.gradient)) end
    object.chars=G.VGroup(table.unpack(object.submobjects));object.initial_height=object:get_height()
    return object
end
function T.Text(text,opts) return make_text(text,opts,false) end
function T.MarkupText(text,opts) return make_text(text,opts,true) end
function T.font_list() local fonts=N.font_list();table.sort(fonts);return fonts end
return T
