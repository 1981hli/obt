#include <stdio.h>
#include <math.h>


int main()
{
  int i;
  double a[7]={1e-1,1e-2,1e-3,1e-4,1e-5,1e-6,1e-7};

  for(i=0;i<7;i++)
    printf("%f\n",sin(a[i]));


  return 0;
  
}
