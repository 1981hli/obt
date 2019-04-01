// gcc gravity.c -shared -fPIC -Iapi -lm -o gravity.so

#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

//-----------------------------------------------------------------------------

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



void gravity_by1(Real G,Real force[],Body testMass,Body source)
{
  Real distance;
  Real term;
  int  i;

  distance= sqrt( pow(testMass.x[0]-source.x[0],2)+ 
                  pow(testMass.x[1]-source.x[1],2)+ 
                  pow(testMass.x[2]-source.x[2],2)  );

  // term= G m1 m2 / r^3
  term= G*testMass.mass*source.mass/pow(distance,3);

  for(i=0;i<3;i++)
    force[i]= term*(source.x[i]-testMass.x[i]);
}

//-----------------------------------------------------------------------------

void passVector(Real vector[],lua_State *L,int index)
{
  int i;
  
  for(i=1;i<=3;i++){
    lua_rawgeti(L,index,i);
    vector[i-1]=lua_tonumber(L,index);
    lua_pop(L,1);
  }
}



void passBody(Body body,lua_State *L,int index)
{
  // body.mass=body.mass
  lua_getfield(L,index,"mass");
  body.mass=lua_tonumber(L,-1);

  // body.x[]=body.x[]
  lua_getfield(L,index,"x");
  passVector(body.x[],L,-1);

  // body.v[]=body.v[]
  lua_getfield(L,index,"v");
  passVector(body.v[],L,-1);
}



static int gravity_by1_LCC(lua_State *L)
{
  Real G;
  Real force[3]={0.,0.,0.};
  Body testMass,source;

  // G=const.G
  lua_getglobal(L,"const");
  lua_getfield(L,-1,"G");
  G=lua_tonumber(L,-1);

  
}



static const struct luaL_Reg gravity[]=
{
  {"by1", gravity_by1_LCC},
  {NULL, NULL}
};

int luaopen_gravity(lua_State *L)
{
  luaL_register(L, "gravity", gravity);
  return 1;
}

