/* Lua/Cairo boundary for Luanim. MIT; see LICENSE and LICENSE.manim*. */
#include <lua.h>
#include <lauxlib.h>
#include <cairo.h>
#include <pango/pangocairo.h>
#include <math.h>

#define SURFACE_MT "luanim.surface"
typedef struct { cairo_surface_t *surface; cairo_t *cr; } Surface;

static double finite_number(lua_State *L, int i) {
    double n=luaL_checknumber(L,i);
    luaL_argcheck(L,isfinite(n),i,"expected finite number"); return n;
}
static Surface *get_surface(lua_State *L) {
    Surface *s=luaL_checkudata(L,1,SURFACE_MT);
    luaL_argcheck(L,s->surface && s->cr,1,"surface is closed"); return s;
}
static int close_surface(lua_State *L) {
    Surface *s=luaL_checkudata(L,1,SURFACE_MT);
    if(s->cr) { cairo_destroy(s->cr);s->cr=NULL; }
    if(s->surface) { cairo_surface_destroy(s->surface);s->surface=NULL; }
    return 0;
}
static int new_surface(lua_State *L) {
    lua_Integer w=luaL_checkinteger(L,1), h=luaL_checkinteger(L,2);
    double fw=finite_number(L,3),fh=finite_number(L,4);
    double cx=finite_number(L,5),cy=finite_number(L,6);
    luaL_argcheck(L,w>0 && w<=16384,1,"width outside [1,16384]");
    luaL_argcheck(L,h>0 && h<=16384 && w*h<=67108864,2,"image allocation too large");
    luaL_argcheck(L,fw>0,3,"frame width must be positive");luaL_argcheck(L,fh>0,4,"frame height must be positive");
    Surface *s=lua_newuserdatauv(L,sizeof(*s),0);s->surface=NULL;s->cr=NULL;
    luaL_setmetatable(L,SURFACE_MT);
    s->surface=cairo_image_surface_create(CAIRO_FORMAT_ARGB32,(int)w,(int)h);
    if(cairo_surface_status(s->surface)!=CAIRO_STATUS_SUCCESS) return luaL_error(L,"Cairo surface allocation failed");
    s->cr=cairo_create(s->surface);
    cairo_translate(s->cr,(double)w/2,(double)h/2);
    cairo_scale(s->cr,(double)w/fw,-(double)h/fh);
    cairo_translate(s->cr,-cx,-cy);
    return 1;
}
static void color(lua_State *L,int index,double out[4]) {
    luaL_checktype(L,index,LUA_TTABLE);
    for(int i=0;i<4;i++) {
        lua_geti(L,index,i+1);out[i]=finite_number(L,-1);lua_pop(L,1);
        luaL_argcheck(L,out[i]>=0 && out[i]<=1,index,"RGBA outside [0,1]");
    }
}
static void point(lua_State *L,int index,double out[2]) {
    lua_geti(L,index,1);out[0]=finite_number(L,-1);lua_pop(L,1);
    lua_geti(L,index,2);out[1]=finite_number(L,-1);lua_pop(L,1);
}
static int clear_surface(lua_State *L) {
    Surface *s=get_surface(L);double rgba[4];color(L,2,rgba);
    cairo_save(s->cr);cairo_set_operator(s->cr,CAIRO_OPERATOR_SOURCE);
    cairo_set_source_rgba(s->cr,rgba[0],rgba[1],rgba[2],rgba[3]);cairo_paint(s->cr);cairo_restore(s->cr);
    return 0;
}
static int draw_path(lua_State *L) {
    Surface *s=get_surface(L);luaL_checktype(L,2,LUA_TTABLE);
    size_t n=lua_rawlen(L,2);luaL_argcheck(L,n%4==0,2,"four points per cubic required");
    double fill[4],stroke[4];color(L,3,fill);color(L,4,stroke);
    double width=finite_number(L,5);luaL_argcheck(L,width>=0,5,"negative stroke width");
    const char *joins[]={"round","bevel","miter",NULL};
    const char *caps[]={"round","butt","square",NULL};
    int join=luaL_checkoption(L,6,"round",joins),cap=luaL_checkoption(L,7,"round",caps);
    const cairo_line_join_t join_values[]={CAIRO_LINE_JOIN_ROUND,CAIRO_LINE_JOIN_BEVEL,CAIRO_LINE_JOIN_MITER};
    const cairo_line_cap_t cap_values[]={CAIRO_LINE_CAP_ROUND,CAIRO_LINE_CAP_BUTT,CAIRO_LINE_CAP_SQUARE};
    /* Validate the complete input before changing the Cairo path. */
    for(size_t i=1;i<=n;i++) { double p[2];lua_geti(L,2,(lua_Integer)i);luaL_checktype(L,-1,LUA_TTABLE);point(L,lua_gettop(L),p);lua_pop(L,1); }
    cairo_new_path(s->cr);double previous[2]={0,0},first[2]={0,0};int open=0;
    for(size_t i=1;i<=n;i+=4) {
        double p[4][2];
        for(int j=0;j<4;j++) { lua_geti(L,2,(lua_Integer)i+j);point(L,lua_gettop(L),p[j]);lua_pop(L,1); }
        if(!open || fabs(previous[0]-p[0][0])>1e-6 || fabs(previous[1]-p[0][1])>1e-6) {
            if(open && fabs(previous[0]-first[0])<=1e-6 && fabs(previous[1]-first[1])<=1e-6) cairo_close_path(s->cr);
            cairo_new_sub_path(s->cr);cairo_move_to(s->cr,p[0][0],p[0][1]);first[0]=p[0][0];first[1]=p[0][1];open=1;
        }
        cairo_curve_to(s->cr,p[1][0],p[1][1],p[2][0],p[2][1],p[3][0],p[3][1]);previous[0]=p[3][0];previous[1]=p[3][1];
    }
    if(open && fabs(previous[0]-first[0])<=1e-6 && fabs(previous[1]-first[1])<=1e-6) cairo_close_path(s->cr);
    cairo_set_source_rgba(s->cr,fill[0],fill[1],fill[2],fill[3]);cairo_fill_preserve(s->cr);
    if(width>0) {
        cairo_set_line_width(s->cr,width*0.01);cairo_set_line_join(s->cr,join_values[join]);cairo_set_line_cap(s->cr,cap_values[cap]);
        cairo_set_source_rgba(s->cr,stroke[0],stroke[1],stroke[2],stroke[3]);cairo_stroke_preserve(s->cr);
    }
    cairo_new_path(s->cr);
    if(cairo_status(s->cr)!=CAIRO_STATUS_SUCCESS) return luaL_error(L,"Cairo path rendering failed: %s",cairo_status_to_string(cairo_status(s->cr)));
    return 0;
}
static int write_png(lua_State *L) {
    Surface *s=get_surface(L);const char *path=luaL_checkstring(L,2);
    cairo_status_t status=cairo_surface_write_to_png(s->surface,path);
    if(status!=CAIRO_STATUS_SUCCESS) return luaL_error(L,"PNG output failed: %s",cairo_status_to_string(status));
    return 0;
}
int luaopen_luanim_native(lua_State *L) {
    luaL_newmetatable(L,SURFACE_MT);
    lua_pushcfunction(L,close_surface);lua_setfield(L,-2,"__gc");
    lua_pushcfunction(L,close_surface);lua_setfield(L,-2,"__close");
    lua_newtable(L);
    const luaL_Reg methods[]={{"clear",clear_surface},{"draw",draw_path},{"write_png",write_png},{"close",close_surface},{NULL,NULL}};
    luaL_setfuncs(L,methods,0);lua_setfield(L,-2,"__index");lua_pop(L,1);
    const luaL_Reg functions[]={{"surface",new_surface},{NULL,NULL}};
    luaL_newlib(L,functions);lua_pushstring(L,cairo_version_string());lua_setfield(L,-2,"cairo_version");return 1;
}
