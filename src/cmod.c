//-----------------------------------------------------------------------------

#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
#include <stdio.h>

//-----------------------------------------------------------------------------

static int f1(lua_State *L)
{
  printf("hello\n");
}



static const struct luaL_Reg mod1[]=
{
  {"f1", f1},
  {NULL, NULL}
};

//-----------------------------------------------------------------------------

int luaopen_cmod(lua_State *L)
{
  luaL_register(L, "mod1", mod1);
  return 1;
}

