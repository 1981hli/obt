/*
gfortran -o trytesteph.o -c trytesteph.f -fPIC -shared
gcc -o jpleph.o -c jpleph.c -fPIC -shared
gfortran -o jpleph.so trytesteph.o jpleph.o -fPIC -shared
*/

extern void pleph_(); // pleph in trytesteph.f

void readstate(double juliandate, int planet, int center, double state[])
{
  pleph_(&juliandate,&planet,&center,state);
}
