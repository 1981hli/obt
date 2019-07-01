//------------------------------------------------------------------------------
// C module to calculate various gravities
//------------------------------------------------------------------------------

#include "common.h"
#define DEBUG(format,...) printf(format,##__VA_ARGS__)

//------------------------------------------------------------------------------
// Newton gravity

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

//------------------------------------------------------------------------------
// Parametrized Post Newtonian gravity
// reference: 196C/p12/(27)

void gravity_PPN(Step *step,int A,Real a[],Real G,Real c)
{
  int dim=3;
  for(int i=0;i<dim;i++) a[i]=0.;
  Real c2=pow(c,2);
  Real *r_A=step->body[A].x; // Real r_A[3]
  Real beta=1., gamma=1.;

  for(int B=0;B<TotalBody;B++){
    if(B==A) continue;

    Real M_B=step->body[B].mass;
    Real *r_B=step->body[B].x; // Real r_B[3]
    Real r_AB[dim]; 
    VSUBV(r_B,r_A,r_AB);

    // T1_1[]=GM_B(r_B[]-r_A[]) / r_AB^3
    Real T1_1[dim];
    CMULV(G*M_B/pow(MOD(r_AB),3),r_AB,T1_1);

    // T1_2=-2(beta+gamma)/c^2 Sum_{C/=A} GM_C/r_AC
    Real tmp=0.;
    for(int C=0;C<TotalBody;C++){
      Real *r_C=step->body[C].x; // Real r_C[3]
      Real r_AC[dim];
      Real M_C=step->body[C].mass;
      if(C==A) continue;
      VSUBV(r_C,r_A,r_AC);
      tmp+=G*M_C/MOD(r_AC);
    }
    Real T1_2=-2*(beta+gamma)/c2*tmp;

    // T1_3=-(2beta-1)/c^2 Sum_{C/=B} GM_C/r_BC
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
    Real T1_3=-(2*beta-1)/c2*tmp;

    // T1_4=gamma*(v_A/c)^2
    Real *v_A=step->body[A].v; // Real v_A[3]
    Real T1_4=gamma*pow(MOD(v_A)/c,2);

    // T1_5=(1+gamma)(v_B/c)^2
    Real *v_B=step->body[B].v; // Real v_B[3]
    Real T1_5=(1+gamma)*pow(MOD(v_B)/c,2);

    // T1_6=-2(1+gamma)/c^2 v_A[] \dot v_B[]
    Real T1_6=-2*(1+gamma)/c2*VDOTV(v_A,v_B);

    // T1_7=-3/2c^2 ((r_A[]-r_B[]) \dot v_B[] / r_AB)^2
    Real r_BA[3];
    CMULV(-1.,r_AB,r_BA);
    Real T1_7=-3/(2*c2)*pow(-VDOTV(r_BA,v_B)/MOD(r_AB),2);

    // T1_8=1/2c^2 (r_B[]-r_A[]) \dot a_B[]
    Real f_Newton_B[dim], a_B[dim];
    gravity_Newton_byall(step,A,f_Newton_B,G);
    CMULV(1./M_B,f_Newton_B,a_B);
    Real T1_8=1/(2*c2)*VDOTV(r_AB,a_B);

    // T1[]=T1_1[]*(1+T1_2+T1_3+T1_4+T1_5+T1_6+T1_7+T1_8)
    Real T1[dim];
    CMULV(1+T1_2+T1_3+T1_4+T1_5+T1_6+T1_7+T1_8, T1_1, T1);



    // T2_1[]=(2+2gamma)v_A[]
    Real T2_1[dim];
    CMULV(2.+2.*gamma,v_A,T2_1);

    // T2_2[]=-(1+2gamma)v_B[]
    Real T2_2[dim];
    CMULV(-(1.+2.*gamma),v_B,T2_2);

    // T2_3[]=T2_1[]+T2_2[]
    Real T2_3[dim];
    VADDV(T2_1,T2_2,T2_3);

    // T2[]=1/c^2 GM_B/r_AB^3 (r_A[]-r_B[]) \dot T2_3[] (v_A[]-v_B[])
    Real T2[dim];
    Real v_BA[dim];
    VSUBV(v_A,v_B,v_BA);
    CMULV(1/c2*G*M_B/pow(MOD(r_AB),3) * VDOTV(r_BA,T2_3), v_BA, T2);



    // T3[]=(3+4gamma)/2c^2 GM_B a_B[]/r_AB
    Real T3[dim];
    CMULV((3.+4.*gamma)/(2.*c2)*G*M_B/MOD(r_AB), a_B, T3);



    // tmpT[]=T1[]+T2[]+T3[]
    Real tmpT[dim];
    VADDV(T1,T2,tmpT);
    VADDV(tmpT,T3,tmpT);

    // a[]=tmpT[]+a[]
    VADDV(tmpT,a,a);
  }
}



static int Call_gravity_PPN(lua_State *L)
{
  Step step;
  passStep(L,1,&step);

  // pass testnum
  int testnum=lua_tonumber(L,2)-1; // -1 means it is counted from 0 in C

  // pass const.G
  Real G=lua_tonumber(L,3);

  // pass const.c
  Real c=lua_tonumber(L,4);

  int dim=3;
  Real a[dim]; // gravity_PPN() return the acceleration
  gravity_PPN(&step,testnum,a,G,c);

  for(int i=0;i<3;i++) lua_pushnumber(L,step.body[i].mass*a[i]);
  return 3;
}

//------------------------------------------------------------------------------

static const struct luaL_Reg functionlist[]=
{
  {"Call_gravity_Newton_by1",Call_gravity_Newton_by1},
  {"Call_gravity_Newton_byall",Call_gravity_Newton_byall},
  {"Call_gravity_PPN",Call_gravity_PPN},
  {"try",try},
  {NULL,NULL}
};

int luaopen_mod_Cgravity(lua_State *L)
{
  luaL_register(L,"Cgravity",functionlist);
  return 1;
}

