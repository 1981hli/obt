#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
#define DEBUG(format,...) printf(format,##__VA_ARGS__)

//-----------------------------------------------------------------------------
// readstate

static int readstate(lua_State *L)
{
  double  juliandate;
  int     planet,center,i;
  double  state[6];

  juliandate=lua_tonumber(L,1);
  planet=lua_tonumber(L,2);
  center=lua_tonumber(L,3);

  // pleph in trytesteph.f
  pleph_(&juliandate,&planet,&center,state);

  for(i=0;i<6;i++)
    lua_pushnumber(L,state[i]);
  return 6;
}

//-----------------------------------------------------------------------------

static const struct luaL_Reg functionlist[]=
{
  {"readstate",readstate},
  {NULL,NULL}
};

int luaopen_LC_de430(lua_State *L)
{
  luaL_register(L,"LC_de430",functionlist);
  return 1;
}

