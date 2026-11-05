local G=require('luanim.geometry')
local N=require('luanim_native')
local V=require('luanim.vector')
local U=require('luanim.util')
local T={}
function T.Text(text,opts)
    assert(type(text)=='string','Text requires a UTF-8 string');opts=opts or {}
    local size=U.number(opts.font_size or 48,'font_size');assert(size>0,'font_size must be positive')
    local tabs=U.integer(opts.tab_width or 4,'tab_width',0)
    local expanded=text:gsub('\t',string.rep(' ',tabs))
    local spacing=opts.line_spacing
    if spacing==nil or spacing==-1 then spacing=size*1.3 else spacing=size*(1+U.number(spacing,'line_spacing')) end
    local points=N.text_path(expanded,opts.font or '',size,opts.weight or 'NORMAL',opts.slant or 'NORMAL',not not opts.disable_ligatures,spacing)
    local object=G.VMobject(U.merge({fill_opacity=1,stroke_width=0},opts))
    object.kind='Text';object.text=text;object.font_size=size;object.font=opts.font or ''
    object:set_points(points)
    if opts.should_center~=false then object:move_to(V()) end
    if opts.height then
        assert(object:get_height()>0,'cannot resize empty text');object:scale(opts.height/object:get_height())
    end
    if opts.width then
        assert(object:get_width()>0,'cannot resize empty text');object:scale(opts.width/object:get_width())
    end
    return object
end
function T.font_list() local fonts=N.font_list();table.sort(fonts);return fonts end
return T
