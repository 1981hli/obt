#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
#include <stdio.h>
#include <math.h>
#include "Vector.h"

typedef double Real;

int BodyTotal=13;

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
  double time;
  Body body[BodyTotal];
} Step;

//-----------------------------------------------------------------------------
// gravityby1_C

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

r_()



void gravity_PPN_by1( Step step,int A,int B,double a[],
                      int BodyTotal,double G,double c   )
{
  double c2=power(c,2);
  double r_AB[3],r_BA[3],r_AC[3];
  double tmp;
  int C;

  // r_AB=r_B-r_A
  VSUBV(step.body[B].x,step.body[A].x,r_AB);
  CMULV(-1.,r_AB,r_BA);

  // T1=GM_B(r_B-r_A) / r_AB^3
  CMULV(G*step.body[B].mass/pow(MODV(r_AB),3),r_AB,T1);

  // T2=-2(beta+gamma)/c^2 Sum_{C/=A} GM_C/r_AC
  tmp=0.;
  for(C=0;C<BodyTotal;C++){
    if(C==A) continue;
    VSUBV(step.body[C].x,step.body[A].x,r_AC);
    tmp+=G*step.body[C].mass/MODV(r_AC);
  }
  T2=-2*(beta+gamma)/c2*tmp;

  // T3=-(2beta-1)/c^2 Sum_{C/=B} GM_C/r_BC
  tmp=0.;
  for(C=0;C<BodyTotal;C++){
    if(C==B) continue;
    VSUBV(step.body[C].x,step.body[B].x,r_BC);
    tmp+=G*step.body[C].mass/r_BC;
  }
  T3=-(2*beta-1)/c2*tmp;

  // T4=gamma*(v_A/c)^2
  T4=gamma*power(MODV(step.body[A].v)/c,2);

  // T5=(1+gamma)(v_B/c)^2
  T5=(1+gamma)*power(MODV(step.body[B].v),2);

  // T6=-2(1+gamma)/c^2 v_A \dot v_B
  T6=-2*(1+gamma)/c2*VDOTV(step.body[A].v,step.body[B].v);

  // T7=-3/2c^2 ((r_A-r_B) \dot v_B / r_AB)^2
  T7=-3/(2*c2)*power(-VDOTV(r_BA,step.body[B].v)/MODV(r_AB),2);

  // T8=1/2c^2 (r_B-r_A) \dot a_B
  T8=1/(2*c2)*VDOTV(r_AB,a_B);

  // T9=1/c^2 Sum_{B/=A} GM_B/r_AB^3
  //    ((r_A-r_B)\dot((2+2gamma)v_A-(1+2gamma)v_B))(v_A-v_B)
  CMULV(2+2*gamma,)
  T9=1/c2*sum(G*step.body[B].mass/power(r_AB,3));

  CMULV(2+2*gamma,step.body[A].v,T10_1);
  CMULV(-(1+2*gamma),step.body[B].v,T10_2);
  VADDV(T10_1,T10_2);
  T10=VDOTV(3,rBA,);

  for(B=0;B<BodyTotal;B++){
    if(B==A) continue;
    CMULV(G*step.body[B].mass/rAB,aB);
  }
  T11;
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
