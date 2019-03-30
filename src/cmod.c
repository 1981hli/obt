//-----------------------------------------------------------------------------
// gcc cmod.c -shared -fPIC -lm -Ih -o cmod.so
//-----------------------------------------------------------------------------

#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
#include <stdio.h>
#include <string.h>
#include <math.h>

//-----------------------------------------------------------------------------

typedef double Real;

typedef struct
{
  char  name[20];
  Real  mass;
  Real  radius;
  Real  x[3];
  Real  v[3];
} Body;
 
//-----------------------------------------------------------------------------

static int my_add(lua_State *L)
{
  double x = lua_tonumber(L,1);
  double y = lua_tonumber(L,2);
  double sum = x + y;
  lua_pushnumber(L, sum);
  return 3;
}


 
static int showstr(lua_State *L)
{
  const char *str = lua_tostring (L, 1);
  printf ("c program str = %s\n", str);
  return 0;
}



static int l_map (lua_State *L)
{
  int i, n;
  luaL_checktype(L, 1, LUA_TTABLE);
  luaL_checktype(L, 2, LUA_TFUNCTION);
  n = lua_objlen(L, 1);
  for (i = 1; i <= n; i++) {
    lua_pushvalue(L, 2);
    lua_rawgeti(L, 1, i);
    lua_call(L, 1, 1);
    lua_rawseti(L, 1, i);
  }
  return 0;
}



/*static int try(lua_State *L)*/
/*{*/
  /*int i,n,x;*/
  /*luaL_checktype(L,1,LUA_TTABLE); */
  /*n=lua_objlen(L,1);*/
  /*for(i=1;i<=n;i++){*/
    /*x=lua_rawgeti(L,1,i);*/
    /*printf("%d",x);*/
  /*}*/
  /*return 0;*/
/*}*/



static int try(lua_State *L)
{
  int i;
  int n = lua_objlen(L, 1);
  double x;
  for (i = 1; i <= n; i++) {
    /*lua_pushinteger(L,i);*/
    /*lua_gettable(L,1);*/
    lua_rawgeti(L,1,i);
    lua_rawgeti(L,-1,1);
    x=lua_tonumber(L,-1);
    printf("%f\n",x);
  }
  return 0;
}



static int gravityby1(lua_State *L)
{
  Body *x;
  x=(Body *)lua_newuserdata(L,sizeof(Body));
  strcpy(x->name,"terra");
  x->mass=1.2;
  return 1;
}



static const struct luaL_Reg mod1[]=
{
  {"add", my_add},
  {"show", showstr},
  {"l_map",l_map},
  {"try",try},
  {"gravityby1",gravityby1},
  {NULL, NULL}
};
 
//-----------------------------------------------------------------------------

int luaopen_cmod(lua_State *L)
{
    luaL_register(L,"mod1",mod1);
    return 1;
}

