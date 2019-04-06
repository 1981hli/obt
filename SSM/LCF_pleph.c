#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
#include <stdio.h>



static int LCF_pleph(lua_State *L)
{
  double  juliandate;
  int     planet,center;
  double  state[6];

  juliandate=lua_tonumber(L,1);
  planet=lua_tonumber(L,2);
  center=lua_tonumber(L,3);
  pleph_(&juliandate,&planet,&center,state);

  for(i=0;i<6;i++)
    lua_pushnumber(L,state(i));
  return 6;
}
