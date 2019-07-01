//------------------------------------------------------------------------------
// Commonly used functions
//------------------------------------------------------------------------------

#include "common.h"
#define DIM 3

void VADDV(double *v1,double *v2,double *v3)
{
  for(int i=0;i<DIM;i++)
    v3[i]=v1[i]+v2[i];
}



void CADDV(double c,double *v,double *v2)
{
  for(int i=0;i<DIM;i++)
    v2[i]=c+v[i];
}



void VADDC(double *v,double c,double *v2)
{
  CADDV(c,v,v2);
}



void VSUBV(double *v1,double *v2,double *v3)
{
  for(int i=0;i<DIM;i++)
    v3[i]=v1[i]-v2[i];
}



void CSUBV(double c,double *v,double *v2)
{
  for(int i=0;i<DIM;i++)
    v2[i]=c-v[i];
}



void CMULV(double c,double *v,double *v2)
{
  for(int i=0;i<DIM;i++)
    v2[i]=c*v[i];
}



void VMULC(double *v,double c,double *v2)
{
  CMULV(c,v,v2);
}



double VDOTV(double *v1,double *v2)
{
  double dot=0.;
  for(int i=0;i<DIM;i++)
    dot+=v1[i]*v2[i];
  return dot;
}



double MOD(double *v)
{
  return sqrt(VDOTV(v,v));
}



void COPY(double *v1,double *v2)
{
  for(int i=0;i<DIM;i++)
    v2[i]=v1[i];
}

//------------------------------------------------------------------------------

void passarray(lua_State *L,int index,Real array[])
{
  int dim=3;
  for(int i=1;i<=dim;i++){
    lua_rawgeti(L,index,i); // push t[i]
    array[i-1]=lua_tonumber(L,-1);
    lua_pop(L,1); // pop t[i]
  }
}



void passBody(lua_State *L,int index,Body *body)
{
  lua_getfield(L,index,"name"); // push t.name
  strcpy(body->name,lua_tostring(L,-1));
  lua_pop(L,1); // pop t.name

  lua_getfield(L,index,"mass"); // push t.mass
  body->mass=lua_tonumber(L,-1);
  lua_pop(L,1); // pop t.mass

  lua_getfield(L,index,"radius"); // push t.radius
  body->radius=lua_tonumber(L,-1);
  lua_pop(L,1); // pop t.radius

  lua_getfield(L,index,"x"); // push t.x[]
  passarray(L,-1,body->x);
  lua_pop(L,1); // pop t.x[]

  lua_getfield(L,index,"v"); // push t.v[]
  passarray(L,-1,body->v);
  lua_pop(L,1); // pop t.v[]
}



void passStep(lua_State *L,int index,Step *step)
{
  lua_getfield(L,index,"time"); // push t.time
  step->time=lua_tonumber(L,-1);
  lua_pop(L,1); // pop t.time

  lua_getfield(L,index,"body"); // push t.body[]

  for(int i=1;i<=TotalBody;i++){
    lua_rawgeti(L,-1,i); // push t.body[i]
    passBody(L,-1,&(step->body[i-1]));
    lua_pop(L,1); // pop t.body[i]
  }

  lua_pop(L,1); // pop t.body[]
}

//------------------------------------------------------------------------------

