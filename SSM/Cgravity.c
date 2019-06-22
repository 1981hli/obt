//-----------------------------------------------------------------------------
// C module to calculate various gravities
//-----------------------------------------------------------------------------

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
#include "Vector.h"
#define TotalBody 11
#define DEBUG(format,...) printf(format,##__VA_ARGS__)

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

//-----------------------------------------------------------------------------

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



//-----------------------------------------------------------------------------

void gravity_Newton_by1(Real G,Real force[],Body test,Body source)
{
  int dim=3;
  Real distance= sqrt( pow(test.x[0]-source.x[0],2)+ 
                       pow(test.x[1]-source.x[1],2)+ 
                       pow(test.x[2]-source.x[2],2)  );
  // term= G m1 m2 / r^3
  Real term= G*test.mass*source.mass/pow(distance,3);
  for(int i=0;i<dim;i++)
    force[i]= term*(source.x[i]-test.x[i]);
}



void gravity_Newton_byall(Step *step,int test,Real f[],Real G)
{
  int dim=3;
  for(int j=0;j<dim;j++) f[j]=0.;
  for(int j=0;j<TotalBody;j++){
    if(j==test) continue;
    Real force[dim];
    for(int j2=0;j2<dim;j2++) force[j2]=0.;
    gravity_Newton_by1(G,force,step->body[test],step->body[j]);
    VADDV(f,force,f);
  }
}



static int try(lua_State *L)
{
  Step s1;
  passStep(L,1,&s1);
  Real G=lua_tonumber(L,2);
  printf("%f\n",G*1e10);
  Real f[3];
  int n;
  /*gravity_Newton_byall(&s1,n,f,G);*/
  return 0;
}



// Call_gravity_Newton_by1(G,test.mass,test.x[],source.mass,source.x[])
// return force[1],force[2],force[3]
static int Call_gravity_Newton_by1(lua_State *L)
{
  Real force[3]={0.,0.,0.};
  Body test,source;
  // G=const.G
  Real G=lua_tonumber(L,1);
  // test.mass=test.mass
  test.mass=lua_tonumber(L,2);
  // test.x[]=test.x[]
  passarray(L,3,test.x);
  // source.mass=source.mass
  source.mass=lua_tonumber(L,4);
  // source.x[]=source.x[]
  passarray(L,5,source.x);
  gravity_Newton_by1(G,force,test,source);
  for(int i=0;i<3;i++) lua_pushnumber(L,force[i]);
  return 3;
}



static int Call_gravity_Newton_byall(lua_State *L)
{
  Step step;
  passStep(L,1,&step);

  // pass test
  int test=lua_tonumber(L,2)-1; // -1 means it is start from 0 in C

  // pass const.G
  Real G=lua_tonumber(L,3);

  int dim=3;
  Real f[dim];
  gravity_Newton_byall(&step,test,f,G);

  for(int i=0;i<3;i++) lua_pushnumber(L,f[i]);
  return 3;
}

//-----------------------------------------------------------------------------

#if(0)

void gravity_PPN( Step *step,int A,Real a[],Real G,Real c )
{
  int dim=3;
  Real c2=pow(c,2);
  Real *r_A=step->body[A].x;
  Real beta=1.,gamma=1.;

  for(int B=0;B<TotalBody;B++){
    Real M_B=step->body[B].mass;
    Real *r_B=step->body[B].x;

    Real r_AB[dim];
    VSUBV(r_B,r_A,r_AB);

    // T1=GM_B(r_B-r_A) / r_AB^3
    Real T1[dim];
    CMULV(G*M_B/pow(MOD(r_AB),3),r_AB,T1);

    // T2=-2(beta+gamma)/c^2 Sum_{C/=A} GM_C/r_AC
    Real tmp=0.;
    for(int C=0;C<TotalBody;C++){
      Real *r_C=step->body[C].x;
      Real r_AC[dim];
      Real M_C=step->body[C].mass;
      if(C==A) continue;
      VSUBV(r_C,r_A,r_AC);
      tmp+=G*M_C/MOD(r_AC);
    }
    Real T2=-2*(beta+gamma)/c2*tmp;

    // T3=-(2beta-1)/c^2 Sum_{C/=B} GM_C/r_BC
    tmp=0.;
    for(int C=0;C<TotalBody;C++){
      Real M_C=step->body[C].mass;
      Real *r_B=step->body[B].x;
      Real *r_C=step->body[C].x;
      Real r_BC[dim];
      if(C==B) continue;
      VSUBV(r_C,r_B,r_BC);
      tmp+=G*M_C/MOD(r_BC);
    }
    Real T3=-(2*beta-1)/c2*tmp;

    // T4=gamma*(v_A/c)^2
    Real T4=gamma*pow(MOD(step->body[A].v)/c,2);

    // T5=(1+gamma)(v_B/c)^2
    Real T5=(1+gamma)*pow(MOD(step->body[B].v)/c,2);

    // T6=-2(1+gamma)/c^2 v_A \dot v_B
    Real T6=-2*(1+gamma)/c2*VDOTV(step->body[A].v,step->body[B].v);

    // T7=-3/2c^2 ((r_A-r_B) \dot v_B / r_AB)^2
    Real r_BA[3];
    CMULV(-1.,r_AB,r_BA);
    Real *v_B=step->body[B].v;
    Real T7=-3/(2*c2)*pow(-VDOTV(r_BA,v_B)/MOD(r_AB),2);

    // T8=1/2c^2 (r_B-r_A) \dot a_B
    Real f_Newton_B[dim],a_B[dim];
    gravity_Newton_byall(step,A,f_Newton_B,G);
    CMULV(1./M_B,f_Newton_B,a_B);
    Real T8=1/(2*c2)*VDOTV(r_AB,a_B);

    // T9=1/c^2 Sum_{B/=A} GM_B/r_AB^3
    // ((r_A-r_B)\dot((2+2gamma)v_A-(1+2gamma)v_B))(v_A-v_B)
    CMULV(2+2*gamma,)
    T9=1/c2*sum(G*step.body[B].mass/pow(r_AB,3));

    CMULV(2+2*gamma,step.body[A].v,T10_1);
    CMULV(-(1+2*gamma),step.body[B].v,T10_2);
    VADDV(T10_1,T10_2);
    T10=VDOTV(3,rBA,);

    for(B=0;B<TotalBody;B++){
      if(B==A) continue;
      CMULV(G*step.body[B].mass/rAB,aB);
    }
    T11;

  }
}

#endif 

//-----------------------------------------------------------------------------

static const struct luaL_Reg functionlist[]=
{
  {"Call_gravity_Newton_by1",Call_gravity_Newton_by1},
  {"Call_gravity_Newton_byall",Call_gravity_Newton_byall},
  {"try",try},
  {NULL,NULL}
};

int luaopen_Cgravity(lua_State *L)
{
  luaL_register(L,"Cgravity",functionlist);
  return 1;
}
