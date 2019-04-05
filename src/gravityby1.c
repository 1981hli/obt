//-----------------------------------------------------------------------------
// gravityby1

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



void gravityby1(Real G,Real force[],Body test,Body source)
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

