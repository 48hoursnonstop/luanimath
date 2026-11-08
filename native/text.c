/* Pango-shaped Unicode outlines, using the same Pango/Cairo stack as Manim.
 * See manim/mobject/text/text_mobject.py and UPSTREAM.md. */
#include <lua.h>
#include <lauxlib.h>
#include <cairo-svg.h>
#include <pango/pangocairo.h>
#include <math.h>
#include <string.h>

static cairo_status_t collect_svg(void *closure,const unsigned char *data,unsigned int length) {
    GString *buffer=closure;
    if(buffer->len+length>16777216) return CAIRO_STATUS_WRITE_ERROR;
    g_string_append_len(buffer,(const char*)data,length);return CAIRO_STATUS_SUCCESS;
}
static int text_svg(lua_State *L) {
    size_t size=0;const char *text=luaL_checklstring(L,1,&size);
    const char *font=luaL_checkstring(L,2);double font_size=luaL_checknumber(L,3);
    const char *weights[]={"NORMAL","BOLD","LIGHT",NULL};
    const PangoWeight weight_values[]={PANGO_WEIGHT_NORMAL,PANGO_WEIGHT_BOLD,PANGO_WEIGHT_LIGHT};
    int weight=luaL_checkoption(L,4,"NORMAL",weights);
    const char *slants[]={"NORMAL","ITALIC","OBLIQUE",NULL};
    const PangoStyle slant_values[]={PANGO_STYLE_NORMAL,PANGO_STYLE_ITALIC,PANGO_STYLE_OBLIQUE};
    int slant=luaL_checkoption(L,5,"NORMAL",slants);
    int disable_ligatures=lua_toboolean(L,6);double spacing=luaL_checknumber(L,7);
    luaL_argcheck(L,isfinite(font_size) && font_size>0 && font_size<=10000,3,"font_size outside (0,10000]");
    luaL_argcheck(L,isfinite(spacing) && spacing>=0,7,"line spacing must be nonnegative");
    luaL_argcheck(L,size<=1048576 && strlen(text)==size,1,"text too large or contains NUL");
    luaL_argcheck(L,g_utf8_validate(text,(gssize)size,NULL),1,"invalid UTF-8 text");
    GString *buffer=g_string_new(NULL);
    /* A vector surface has no pixel allocation. Leave room for unwrapped text;
     * unlike upstream's canvas-wide RTL layout, natural-width shaping remains visible. */
    double extent=fmax(1024,font_size*(size+1)+32+spacing*(size+1));
    cairo_surface_t *surface=cairo_svg_surface_create_for_stream(collect_svg,buffer,extent,extent);
    cairo_t *cr=cairo_create(surface);
    cairo_set_source_rgb(cr,1,1,1);
    PangoLayout *layout=pango_cairo_create_layout(cr);
    PangoContext *context=pango_layout_get_context(layout);
    pango_context_set_round_glyph_positions(context,FALSE);
    PangoFontDescription *desc=pango_font_description_new();
    if(strlen(font)) pango_font_description_set_family(desc,font);
    /* Manim divides its public font size by 4.8 before supplying Pango points. */
    pango_font_description_set_size(desc,(int)round(font_size/4.8*PANGO_SCALE));
    pango_font_description_set_weight(desc,weight_values[weight]);
    pango_font_description_set_style(desc,slant_values[slant]);
    pango_layout_set_font_description(layout,desc);pango_font_description_free(desc);
    if(disable_ligatures) {
        PangoAttrList *attributes=pango_attr_list_new();
        pango_attr_list_insert(attributes,pango_attr_font_features_new("liga=0,dlig=0,clig=0,hlig=0"));
        pango_layout_set_attributes(layout,attributes);pango_attr_list_unref(attributes);
    }
    const char *start=text;unsigned int line=0;
    while(1) {
        const char *end=strchr(start,'\n');size_t n=end ? (size_t)(end-start) : strlen(start);
        pango_layout_set_text(layout,start,(int)n);
        cairo_move_to(cr,30,20+line*spacing/4.8);
        pango_cairo_update_layout(cr,layout);
        pango_cairo_show_layout(cr,layout);
        if(!end) break;
        start=end+1;line++;
    }
    g_object_unref(layout);cairo_destroy(cr);cairo_surface_finish(surface);
    cairo_status_t status=cairo_surface_status(surface);cairo_surface_destroy(surface);
    if(status!=CAIRO_STATUS_SUCCESS) {g_string_free(buffer,TRUE);return luaL_error(L,"Pango SVG conversion failed: %s",cairo_status_to_string(status));}
    lua_pushlstring(L,buffer->str,buffer->len);g_string_free(buffer,TRUE);return 1;
}
static int font_list(lua_State *L) {
    PangoFontMap *map=pango_cairo_font_map_get_default();
    PangoFontFamily **families=NULL;int count=0;pango_font_map_list_families(map,&families,&count);
    lua_createtable(L,count,0);
    for(int i=0;i<count;i++) {lua_pushstring(L,pango_font_family_get_name(families[i]));lua_seti(L,-2,i+1);}
    g_free(families);return 1;
}
static int parse_css_color(lua_State *L) {
    const char *text=luaL_checkstring(L,1);PangoColor color;guint16 alpha=65535;
    if(!pango_color_parse_with_alpha(&color,&alpha,text)) return luaL_error(L,"unsupported CSS color: %s",text);
    lua_createtable(L,4,0);
    const double rgba[]={color.red/65535.0,color.green/65535.0,color.blue/65535.0,alpha/65535.0};
    for(int i=0;i<4;i++) {lua_pushnumber(L,rgba[i]);lua_seti(L,-2,i+1);}return 1;
}
void luanim_add_text(lua_State *L) {
    lua_pushcfunction(L,text_svg);lua_setfield(L,-2,"text_svg");
    lua_pushcfunction(L,font_list);lua_setfield(L,-2,"font_list");
    lua_pushcfunction(L,parse_css_color);lua_setfield(L,-2,"parse_css_color");
}
