#include <stdio.h>
#include <math.h>

void VADDV(double *v1,double *v2,double *v3)
{
  int i;
  int dim=3;
  for(i=0;i<dim;i++)
    v3[i]=v1[i]+v2[i];
}



void CADDV(double c,double *v,double *v2)
{
  int i;
  int dim=3;
  for(i=0;i<dim;i++)
    v2[i]=c+v[i];
}



void VSUBV(double *v1,double *v2,double *v3)
{
  int i;
  int dim=3;
  for(i=0;i<dim;i++)
    v3[i]=v1[i]-v2[i];
}



void CSUBV(double c,double *v,double *v2)
{
  int i;
  int dim=3;
  for(i=0;i<dim;i++)
    v2[i]=c-v[i];
}



void CMULV(double c,double *v,double *v2)
{
  int i;
  int dim=3;
  for(i=0;i<dim;i++)
    v2[i]=c*v[i];
}



double VDOTV(double *v1,double *v2)
{
  int i;
  int dim=3;
  double dot=0.;
  for(i=0;i<dim;i++)
    dot+=v1[i]*v2[i];
  return dot;
}



double MODV(double *v)
{
  int dim=3;
  return sqrt(VDOTV(dim,v,v));
}
