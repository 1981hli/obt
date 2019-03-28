// gcc cmod.c -shared -fPIC -Ih -o cmod.so

#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
#include <stdio.h>

//-----------------------------------------------------------------------------
 
static int my_add(lua_State *L)
{
  double x = lua_tonumber(L,1);
  double y = lua_tonumber(L,2);
  double sum = x + y;
  lua_pushnumber(L, sum);
  return 1;
}


 
static int showstr(lua_State *L)
{
  const char *str = lua_tostring (L, 1);
  printf ("c program str = %s\n", str);
  return 0;
}



static int gravityby1(lua_State *L)
{
  return 1;
}

//-----------------------------------------------------------------------------

static struct luaL_reg listofmod1[] =
{
  {"add", my_add},
  {"show", showstr},
  {"gravityby1",gravityby1},
  {NULL, NULL}
};
 


LUALIB_API int luaopen_cmod(lua_State *L)
{
    luaL_register(L,"mod1",listofmod1);
    return 1;
}
 
