#include <stdio.h>

void main()
{
  double  jdate;
  int     planet,center; 
  double  state[6];

  jdate=2451545;
  planet=1;
  center=12;
  pleph_(&jdate,&planet,&center,state);
  printf("x1=%f\n",state[0]);
}
