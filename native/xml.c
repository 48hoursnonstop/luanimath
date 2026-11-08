/* XML decoding only. SVG geometry and scene semantics are implemented in Lua. */
#include <lua.h>
#include <lauxlib.h>
#include <libxml/parser.h>
#include <libxml/tree.h>
#include <string.h>

typedef struct {xmlDocPtr doc;} XmlOwner;
static int free_xml(lua_State *L) {
    XmlOwner *owner=luaL_checkudata(L,1,"luanimath.xml_owner");
    if(owner->doc) {xmlFreeDoc(owner->doc);owner->doc=NULL;} return 0;
}
static void node_table(lua_State *L,xmlNodePtr node,unsigned depth,unsigned *count) {
    if(depth>256 || ++*count>100000) luaL_error(L,"SVG XML exceeds supported tree limits");
    lua_createtable(L,0,3);lua_pushstring(L,(const char*)node->name);lua_setfield(L,-2,"name");
    lua_newtable(L);
    for(xmlAttrPtr a=node->properties;a;a=a->next) {
        xmlChar *value=xmlNodeListGetString(node->doc,a->children,1);
        lua_pushstring(L,(const char*)a->name);lua_pushstring(L,value?(const char*)value:"");lua_settable(L,-3);
        xmlFree(value);
    }
    lua_setfield(L,-2,"attributes");lua_newtable(L);lua_Integer index=0;
    for(xmlNodePtr child=node->children;child;child=child->next) {
        if(child->type==XML_ELEMENT_NODE) {node_table(L,child,depth+1,count);lua_seti(L,-2,++index);}
    }
    lua_setfield(L,-2,"children");
}
static int parse_xml(lua_State *L) {
    size_t size=0;const char *data=luaL_checklstring(L,1,&size);
    luaL_argcheck(L,size<=16777216 && strlen(data)==size,1,"SVG XML too large or contains NUL");
    XmlOwner *owner=lua_newuserdatauv(L,sizeof(*owner),0);owner->doc=NULL;luaL_setmetatable(L,"luanimath.xml_owner");
    owner->doc=xmlReadMemory(data,(int)size,"input.svg",NULL,XML_PARSE_NONET|XML_PARSE_NOERROR|XML_PARSE_NOWARNING);
    if(!owner->doc) return luaL_error(L,"invalid SVG/XML document");
    if(owner->doc->intSubset || owner->doc->extSubset) return luaL_error(L,"SVG DTD declarations are not supported");
    xmlNodePtr root=xmlDocGetRootElement(owner->doc);
    if(!root) return luaL_error(L,"SVG XML has no root element");
    unsigned count=0;node_table(L,root,0,&count);xmlFreeDoc(owner->doc);owner->doc=NULL;return 1;
}
void luanimath_add_xml(lua_State *L) {
    luaL_newmetatable(L,"luanimath.xml_owner");lua_pushcfunction(L,free_xml);lua_setfield(L,-2,"__gc");lua_pop(L,1);
    lua_pushcfunction(L,parse_xml);lua_setfield(L,-2,"parse_xml");
}
