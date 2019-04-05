#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

#include "gravityby1.c"

//-----------------------------------------------------------------------------
// gravityby1_LCC

void passVector(Real vector[],lua_State *L,int index)
{
  int i,dim=3;
  for(i=1;i<=dim;i++){
    lua_rawgeti(L,index,i);
    vector[i-1]=lua_tonumber(L,-1);
    lua_pop(L,1);
  }
}



static int gravityby1_LCC(lua_State *L)
{
  Real G;
  Real force[3]={0.,0.,0.};
  Body test,source;

  // G=const.G
  G=lua_tonumber(L,1);

  // test.mass=test.mass
  test.mass=lua_tonumber(L,2);

  // test.x[]=test.x[]
  passVector(test.x,L,3);

  // source.mass=source.mass
  source.mass=lua_tonumber(L,4);

  // source.x[]=source.x[]
  passVector(source.x,L,5);

  gravityby1(G,force,test,source);
  
  lua_pushnumber(L,force[0]);
  lua_pushnumber(L,force[1]);
  lua_pushnumber(L,force[2]);
  return 3;
}

//-----------------------------------------------------------------------------
// LCC

static const struct luaL_Reg LCC[]=
{
  {"gravityby1",gravityby1_LCC},
  {NULL,NULL}
};



int luaopen_LCC(lua_State *L)
{
  luaL_register(L,"LCC",LCC);
  return 1;
}

