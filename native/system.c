/* Shared asset/cache primitives. GLib is already a Pango dependency. */
#include <lua.h>
#include <lauxlib.h>
#include <glib.h>

static int sha256(lua_State *L) {
    size_t size=0;const char *data=luaL_checklstring(L,1,&size);
    char *digest=g_compute_checksum_for_data(G_CHECKSUM_SHA256,(const guchar*)data,size);
    if(!digest) return luaL_error(L,"SHA-256 computation failed");
    lua_pushstring(L,digest);g_free(digest);return 1;
}
void luanim_add_system(lua_State *L) {
    lua_pushcfunction(L,sha256);lua_setfield(L,-2,"sha256");
}
