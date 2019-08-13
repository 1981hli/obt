#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

#define TotalBody 11

typedef double Real;

typedef struct
{
  char  name[20];
  Real  mass;
  Real  radius;
  Real  x[3];
  Real  v[3];
} Body;

typedef struct
{
  Real time;
  Body body[TotalBody];
} Step;

void VADDV(double *v1,double *v2,double *v3);
void CADDV(double c,double *v,double *v2);
void VADDC(double *v,double c,double *v2);
void VSUBV(double *v1,double *v2,double *v3);
void CSUBV(double c,double *v,double *v2);
void CMULV(double c,double *v,double *v2);
void VMULC(double *v,double c,double *v2);
double VDOTV(double *v1,double *v2);
double MOD(double *v);
void COPY(double *v1,double *v2);

void passarray(lua_State *L,int index,Real array[]);
void passBody(lua_State *L,int index,Body *body);
void passStep(lua_State *L,int index,Step *step);
