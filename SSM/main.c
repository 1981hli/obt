//-----------------------------------------------------------------------------
// Solar System Modeling
//-----------------------------------------------------------------------------

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#define TotalBody 2
#define TotalStep 365
#define dtBetweenSteps 1.

//-----------------------------------------------------------------------------

typedef long double Real;



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
  Real  time;
  Body  body[TotalBody];
} Step;



Real constantG= 6.67e-11;

//-----------------------------------------------------------------------------

void gravityby1(Real *force/*output*/,Body testMass,Body source)
{
  Real distance;
  Real term;

  distance= sqrt( pow(testMass.x[0]-source.x[0],2)+ 
                  pow(testMass.x[1]-source.x[1],2)+ 
                  pow(testMass.x[2]-source.x[2],2)  );
  
  term= constantG*testMass.mass*source.mass/pow(distance,3);

  force[0]= term*(source.x[0]-testMass.x[0]);
  force[1]= term*(source.x[1]-testMass.x[1]);
  force[2]= term*(source.x[2]-testMass.x[2]);
}



void gravitybyAll(Real *force/*output*/,int testMassNumber,Step *currentStep)
{
  int i;
  Real force1[3];

  force[0]=0.;
  force[1]=0.;
  force[2]=0.;

  for(i=0;i<TotalBody;i++){
    if(i==testMassNumber) continue;

    gravityby1(force1,currentStep->body[testMassNumber],currentStep->body[i]); 

    force[0]+= force1[0];
    force[1]+= force1[1];
    force[2]+= force1[2];
  }
}

//-----------------------------------------------------------------------------

void copyBody(Body *target/*output*/,Body *body)
{
  strcpy(target->name,  body->name);
  target->mass=         body->mass;
  target->radius=       body->radius;

  target->x[0]= body->x[0];
  target->x[1]= body->x[1];
  target->x[2]= body->x[2];

  target->v[0]= body->v[0];
  target->v[1]= body->v[1];
  target->v[2]= body->v[2];
}



void copyStep(Step *target/*output*/,Step *step)
{
  int i;

  target->time= step->time;

  for(i=0;i<TotalBody;i++)
    copyBody(&(target->body[i]),&(step->body[i]));
}



//step(t,y)+c= step(t+c,y+c)
void stepMultiplyConstant(Step *inoutput,Real c)
{
  int i;

  inoutput->time*= c;

  for(i=0;i<TotalBody;i++){
    inoutput->body[i].x[0]*= c;
    inoutput->body[i].x[1]*= c;
    inoutput->body[i].x[2]*= c;

    inoutput->body[i].v[0]*= c;
    inoutput->body[i].v[1]*= c;
    inoutput->body[i].v[2]*= c;
  } 
}



//step(t1,y1)+step(t2,y2)= step(t1+t2,y1+y2)
void stepPlusStep(Step *inoutput,Step *step2)
{
  int i;

  inoutput->time+= step2->time;

  for(i=0;i<TotalBody;i++){
    inoutput->body[i].x[0]+= step2->body[i].x[0];
    inoutput->body[i].x[1]+= step2->body[i].x[1];
    inoutput->body[i].x[2]+= step2->body[i].x[2];

    inoutput->body[i].v[0]+= step2->body[i].v[0];
    inoutput->body[i].v[1]+= step2->body[i].v[1];
    inoutput->body[i].v[2]+= step2->body[i].v[2];
  }
}

//-----------------------------------------------------------------------------

//Calculate $dy=f(t,y)dt$, which is coded as dStep=fdt(step).
void fdt(Step *dStep/*output*/,Step *input,Real dt)
{
  int i;
  Real force[3];

  copyStep(dStep,input);

  //dStep is the change of step, so its time is dt.
  dStep->time= dt;
  
  for(i=0;i<TotalBody;i++){
    gravitybyAll(force,i,input);

    dStep->body[i].x[0]= input->body[i].v[0]*dt;
    dStep->body[i].x[1]= input->body[i].v[1]*dt;
    dStep->body[i].x[2]= input->body[i].v[2]*dt;

    dStep->body[i].v[0]= force[0]/(input->body[i].mass)*dt;
    dStep->body[i].v[1]= force[1]/(input->body[i].mass)*dt;
    dStep->body[i].v[2]= force[2]/(input->body[i].mass)*dt;
  }
}



//The differential equation is $\frac{dy}{dt}=f(t,y)$.
//nextStep= currentStep+dStep
void rk4(Step *nextStep/*output*/,Step *currentStep,Real dt)
{
  Step k1,k2,k3,k4;
  Step tmpStep,tmpStep2;

  //k1=f(t,y)dt=fdt(step)
  fdt(&k1,currentStep,dt);
    
  //k2=f(t+dt/2,y+k1/2)dt=fdt(step+dStep/2)
  copyStep(&tmpStep,currentStep);
  copyStep(&tmpStep2,&k1);
  stepMultiplyConstant(&tmpStep2,0.5);
  stepPlusStep(&tmpStep,&tmpStep2);
  fdt(&k2,&tmpStep,dt);
  
  //k3=f(t+dt/2,y+k2/2)dt=fdt(step+dStep/2)
  copyStep(&tmpStep,currentStep);
  copyStep(&tmpStep2,&k2);
  stepMultiplyConstant(&tmpStep2,0.5);
  stepPlusStep(&tmpStep,&tmpStep2);
  fdt(&k3,&tmpStep,dt);
  
  //k4=f(t+dt,y+k3)dt=fdt(step+dStep)
  copyStep(&tmpStep,currentStep);
  stepPlusStep(&tmpStep,&k3);
  fdt(&k4,&tmpStep,dt);
  
  //dStep=(k1+2k2+2k3+k4)/6
  copyStep(&tmpStep,&k1);

  copyStep(&tmpStep2,&k2);
  stepMultiplyConstant(&tmpStep2,2.);
  stepPlusStep(&tmpStep,&tmpStep2);

  copyStep(&tmpStep2,&k3);
  stepMultiplyConstant(&tmpStep2,2.);
  stepPlusStep(&tmpStep,&tmpStep2);

  stepPlusStep(&tmpStep,&k4);

  stepMultiplyConstant(&tmpStep,1./6.);
  //for now, dStep=tmpStep

  copyStep(nextStep,currentStep);
  stepPlusStep(nextStep,&tmpStep);
}

//-----------------------------------------------------------------------------

void bodyDataToFile(int bodyNumber,Step *steps,FILE *fp)
{
  int i;

  for(i=0;i<TotalStep;i++)
    fprintf(fp,"%Lf ",steps[i].time);
  fprintf(fp,"\n");

  for(i=0;i<TotalStep;i++)
    fprintf(fp,"%Lf ",steps[i].body[bodyNumber].x[0]);
  fprintf(fp,"\n");

  for(i=0;i<TotalStep;i++)
    fprintf(fp,"%Lf ",steps[i].body[bodyNumber].x[1]);
  fprintf(fp,"\n");

  for(i=0;i<TotalStep;i++)
    fprintf(fp,"%Lf ",steps[i].body[bodyNumber].x[2]);
  fprintf(fp,"\n");

  for(i=0;i<TotalStep;i++)
    fprintf(fp,"%Lf ",steps[i].body[bodyNumber].v[0]);
  fprintf(fp,"\n");

  for(i=0;i<TotalStep;i++)
    fprintf(fp,"%Lf ",steps[i].body[bodyNumber].v[1]);
  fprintf(fp,"\n");

  for(i=0;i<TotalStep;i++)
    fprintf(fp,"%Lf ",steps[i].body[bodyNumber].v[2]);
  fprintf(fp,"\n");
}

//-----------------------------------------------------------------------------

int main()
{
  int i;
  FILE *fp;
  Step steps[TotalStep];

  // Sun
  strcpy(steps[0].body[0].name,   "Sun");
  steps[0].body[0].mass=          19885.e30;
  steps[0].body[0].radius=        696392000.;
  steps[0].body[0].x[0]=          0.;
  steps[0].body[0].x[1]=          0.;
  steps[0].body[0].x[2]=          0.;
  steps[0].body[0].v[0]=          0.;
  steps[0].body[0].v[1]=          0.;
  steps[0].body[0].v[2]=          0.;
  
  // Earth
  strcpy(steps[0].body[1].name,   "Earth");
  steps[0].body[1].mass=          5.97238e24;
  steps[0].body[1].radius=        6371000.;
  steps[0].body[1].x[0]=          136751328832.;
  steps[0].body[1].x[1]=          -59890629319.;
  steps[0].body[1].x[2]=          -25970518175.;
  steps[0].body[1].v[0]=          1070033330.;
  steps[0].body[1].v[1]=          2128896394.;
  steps[0].body[1].v[2]=          923202104.;

  for(i=1;i<TotalStep;i++)
    rk4(&steps[i],&steps[i-1],dtBetweenSteps);

  fp=fopen("body_0","w");
  bodyDataToFile(0,steps,fp);
  fclose(fp);

  fp=fopen("body_1","w");
  bodyDataToFile(1,steps,fp);
  fclose(fp);

  return 0;
}

