#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
#include <stdio.h>
#include <math.h>
#include "Vector.h"
#define BodyTotal 13

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
  double time;
  Body body[BodyTotal];
} Step;

//-----------------------------------------------------------------------------

void gravity_Newton_by1(Real G,Real force[],Body test,Body source)
{
  Real distance;
  Real term;
  int  i;
  distance= sqrt( pow(test.x[0]-source.x[0],2)+ 
                  pow(test.x[1]-source.x[1],2)+ 
                  pow(test.x[2]-source.x[2],2)  );
  // term= G m1 m2 / r^3
  term= G*test.mass*source.mass/pow(distance,3);
  for(i=0;i<3;i++) force[i]= term*(source.x[i]-test.x[i]);
}



void gravity_Newton_byall(Step *step,int i,double f[],double G)
{
  int dim=3;
  for(int j=0;j<dim;j++) f[j]=0.;
  for(int j=0;j<BodyTotal;j++){
    if(i==j) continue;
    double force[dim];
    for(int j2=0;j2<dim;j2++) force[j2]=0.;
    gravity_Newton_by1(G,force,step->body[i],step->body[j]);
    VADDV(f,force,f);
  }
}



void passarray(Real array[],lua_State *L,int index)
{
  int dim=3;
  for(int i=1;i<=dim;i++){
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
  gravity_Newton_by1(G,force,test,source);
  for(int i=0;i<3;i++) lua_pushnumber(L,force[i]);
  return 3;
}

//-----------------------------------------------------------------------------

#if (0)

void gravity_PPN( Step *step,int A,double a[],double G,double c )
{
  int dim=3;
  double c2=pow(c,2);
  double *r_A=step->body[A].x;
  double beta=1.,gamma=1.;

  for(int B=0;B<BodyTotal;B++){
    double M_B=step->body[B].mass;
    double *r_B=step->body[B].x;

    double r_AB[dim];
    VSUBV(r_B,r_A,r_AB);

    // T1=GM_B(r_B-r_A) / r_AB^3
    double T1[dim];
    CMULV(G*M_B/pow(MOD(r_AB),3),r_AB,T1);

    // T2=-2(beta+gamma)/c^2 Sum_{C/=A} GM_C/r_AC
    double tmp=0.;
    for(int C=0;C<BodyTotal;C++){
      double *r_C=step->body[C].x;
      double r_AC[dim];
      double M_C=step->body[C].mass;
      if(C==A) continue;
      VSUBV(r_C,r_A,r_AC);
      tmp+=G*M_C/MOD(r_AC);
    }
    double T2=-2*(beta+gamma)/c2*tmp;

    // T3=-(2beta-1)/c^2 Sum_{C/=B} GM_C/r_BC
    tmp=0.;
    for(int C=0;C<BodyTotal;C++){
      double M_C=step->body[C].mass;
      double *r_B=step->body[B].x;
      double *r_C=step->body[C].x;
      double r_BC[dim];
      if(C==B) continue;
      VSUBV(r_C,r_B,r_BC);
      tmp+=G*M_C/MOD(r_BC);
    }
    double T3=-(2*beta-1)/c2*tmp;

    // T4=gamma*(v_A/c)^2
    double T4=gamma*pow(MOD(step->body[A].v)/c,2);

    // T5=(1+gamma)(v_B/c)^2
    double T5=(1+gamma)*pow(MOD(step->body[B].v)/c,2);

    // T6=-2(1+gamma)/c^2 v_A \dot v_B
    double T6=-2*(1+gamma)/c2*VDOTV(step->body[A].v,step->body[B].v);

    // T7=-3/2c^2 ((r_A-r_B) \dot v_B / r_AB)^2
    double r_BA[3];
    CMULV(-1.,r_AB,r_BA);
    double *v_B=step->body[B].v;
    double T7=-3/(2*c2)*pow(-VDOTV(r_BA,v_B)/MOD(r_AB),2);

    // T8=1/2c^2 (r_B-r_A) \dot a_B
    double f_Newton_B[dim],a_B[dim];
    gravity_Newton_byall(step,A,f_Newton_B,G);
    CMULV(1./M_B,f_Newton_B,a_B);
    double T8=1/(2*c2)*VDOTV(r_AB,a_B);

    // T9=1/c^2 Sum_{B/=A} GM_B/r_AB^3
    // ((r_A-r_B)\dot((2+2gamma)v_A-(1+2gamma)v_B))(v_A-v_B)
    CMULV(2+2*gamma,)
    T9=1/c2*sum(G*step.body[B].mass/pow(r_AB,3));

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
}

//-----------------------------------------------------------------------------

#endif 

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
