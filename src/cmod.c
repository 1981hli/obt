// gcc cmod.c -shared -fPIC -Ih -o cmod.so

#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
#include <stdio.h>

//-----------------------------------------------------------------------------
 
static int my_add(lua_State *L)
{
  int x = lua_tonumber(L,1);
  int y = lua_tonumber(L,2);
  int sum = x + y;
  lua_pushnumber(L, sum);
  return 1;
}


 
static int showstr(lua_State *L)
{
  const char *str = lua_tostring (L, 1);
  printf ("c program str = %s\n", str);
  return 0;
}

//-----------------------------------------------------------------------------

static struct luaL_reg mod1List[] =
{
  {"add", my_add},
  {"show", showstr},
  {NULL, NULL}
};
 


LUALIB_API int luaopen_cmod(lua_State *L)
{
    luaL_register(L,"mod1",mod1List);
    return 1;
}
 
