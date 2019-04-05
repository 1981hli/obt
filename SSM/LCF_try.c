#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
#include <stdio.h>

static int LCF_try(lua_State *L)
{
  int a,b,c;

  a=lua_tonumber(L,1);
  b=lua_tonumber(L,2);
  add_(&a,&b,&c);
  lua_pushnumber(L,c);
  return 1;
}
