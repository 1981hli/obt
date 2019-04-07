#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

//-----------------------------------------------------------------------------
// gravityby1_C

#include <stdio.h>
#include <math.h>

typedef double Real;

typedef struct
{
  char  name[20];
  Real  mass;
  Real  radius;
  Real  x[3];
  Real  v[3];
} Body;



void gravityby1_C(Real G,Real force[],Body test,Body source)
{
  Real distance;
  Real term;
  int  i;

  distance= sqrt( pow(test.x[0]-source.x[0],2)+ 
                  pow(test.x[1]-source.x[1],2)+ 
                  pow(test.x[2]-source.x[2],2)  );

  // term= G m1 m2 / r^3
  term= G*test.mass*source.mass/pow(distance,3);

  for(i=0;i<3;i++)
    force[i]= term*(source.x[i]-test.x[i]);
}

//-----------------------------------------------------------------------------
// gravityby1

void passarray(Real array[],lua_State *L,int index)
{
  int i,dim=3;

  for(i=1;i<=dim;i++){
    lua_rawgeti(L,index,i);
    array[i-1]=lua_tonumber(L,-1);
    lua_pop(L,1);
  }
}



static int gravityby1(lua_State *L)
{
  Real G;
  Real force[3]={0.,0.,0.};
  Body test,source;
  int  i;

  // G=const.G
  G=lua_tonumber(L,1);

  // test.mass=test.mass
  test.mass=lua_tonumber(L,2);

  // test.x[]=test.x[]
  passarray(test.x,L,3);

  // source.mass=source.mass
  source.mass=lua_tonumber(L,4);

  // source.x[]=source.x[]
  passarray(source.x,L,5);

  gravityby1_C(G,force,test,source);
  
  for(i=0;i<3;i++)
    lua_pushnumber(L,force[i]);

  return 3;
}

//-----------------------------------------------------------------------------

static const struct luaL_Reg Functions[]=
{
  {"gravityby1",gravityby1},
  {NULL,NULL}
};

int luaopen_LC_gravity(lua_State *L)
{
  luaL_register(L,"LC_gravity",Functions);
  return 1;
}

