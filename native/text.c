/* Pango-shaped Unicode outlines, using the same Pango/Cairo stack as Manim.
 * See manim/mobject/text/text_mobject.py and UPSTREAM.md. */
#include <lua.h>
#include <lauxlib.h>
#include <cairo-svg.h>
#include <pango/pangocairo.h>
#include <math.h>
#include <string.h>

static cairo_status_t discard_svg(void *closure,const unsigned char *data,unsigned int length) {
    (void)closure;(void)data;(void)length;return CAIRO_STATUS_SUCCESS;
}
static void push_point(lua_State *L,double x,double y) {
    lua_createtable(L,3,0);
    lua_pushnumber(L,x*0.05);lua_seti(L,-2,1);
    lua_pushnumber(L,-y*0.05);lua_seti(L,-2,2);
    lua_pushnumber(L,0);lua_seti(L,-2,3);
}
static void push_curve(lua_State *L,int table,lua_Integer *count,const double p[8]) {
    for(int i=0;i<4;i++) {push_point(L,p[2*i],p[2*i+1]);lua_seti(L,table,++*count);}
}
static void push_line(lua_State *L,int table,lua_Integer *count,double x,double y,double tx,double ty) {
    double p[]={x,y,(2*x+tx)/3,(2*y+ty)/3,(x+2*tx)/3,(y+2*ty)/3,tx,ty};
    push_curve(L,table,count,p);
}
static int text_path(lua_State *L) {
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
    cairo_surface_t *surface=cairo_svg_surface_create_for_stream(discard_svg,NULL,1,1);
    cairo_t *cr=cairo_create(surface);
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
        cairo_move_to(cr,0,line*spacing/4.8);
        pango_cairo_update_layout(cr,layout);pango_cairo_layout_path(cr,layout);
        if(!end) break;
        start=end+1;line++;
    }
    cairo_path_t *path=cairo_copy_path(cr);
    g_object_unref(layout);cairo_destroy(cr);cairo_surface_destroy(surface);
    if(path->status!=CAIRO_STATUS_SUCCESS) {cairo_path_destroy(path);return luaL_error(L,"Pango outline conversion failed");}
    lua_newtable(L);int table=lua_gettop(L);lua_Integer count=0;
    double x=0,y=0,sx=0,sy=0;
    for(int i=0;i<path->num_data;) {
        cairo_path_data_t *item=&path->data[i];
        if(item->header.type==CAIRO_PATH_MOVE_TO) {x=item[1].point.x;y=item[1].point.y;sx=x;sy=y;}
        else if(item->header.type==CAIRO_PATH_LINE_TO) {
            double tx=item[1].point.x,ty=item[1].point.y;
            push_line(L,table,&count,x,y,tx,ty);x=tx;y=ty;
        } else if(item->header.type==CAIRO_PATH_CURVE_TO) {
            double p[]={x,y,item[1].point.x,item[1].point.y,item[2].point.x,item[2].point.y,item[3].point.x,item[3].point.y};
            push_curve(L,table,&count,p);x=p[6];y=p[7];
        } else if(item->header.type==CAIRO_PATH_CLOSE_PATH) {
            push_line(L,table,&count,x,y,sx,sy);x=sx;y=sy;
        }
        i+=item->header.length;
    }
    cairo_path_destroy(path);return 1;
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
    lua_pushcfunction(L,text_path);lua_setfield(L,-2,"text_path");
    lua_pushcfunction(L,font_list);lua_setfield(L,-2,"font_list");
    lua_pushcfunction(L,parse_css_color);lua_setfield(L,-2,"parse_css_color");
}
