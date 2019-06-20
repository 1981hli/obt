#include <stdio.h>
#include <math.h>
#define dim 3

void VADDV(double *v1,double *v2,double *v3)
{
  for(int i=0;i<dim;i++)
    v3[i]=v1[i]+v2[i];
}



void CADDV(double c,double *v,double *v2)
{
  for(int i=0;i<dim;i++)
    v2[i]=c+v[i];
}



void VADDC(double *v,double c,double *v2)
{
  CADDV(c,v,v2);
}



void VSUBV(double *v1,double *v2,double *v3)
{
  for(int i=0;i<dim;i++)
    v3[i]=v1[i]-v2[i];
}



void CSUBV(double c,double *v,double *v2)
{
  for(int i=0;i<dim;i++)
    v2[i]=c-v[i];
}



void CMULV(double c,double *v,double *v2)
{
  for(int i=0;i<dim;i++)
    v2[i]=c*v[i];
}



void VMULC(double *v,double c,double *v2)
{
  CMULV(c,v,v2);
}



double VDOTV(double *v1,double *v2)
{
  double dot=0.;
  for(int i=0;i<dim;i++)
    dot+=v1[i]*v2[i];
  return dot;
}



double MOD(double *v)
{
  return sqrt(VDOTV(v,v));
}



void COPY(double *v1,double *v2)
{
  for(int i=0;i<dim;i++)
    v2[i]=v1[i];
}

