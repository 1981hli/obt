#include <stdio.h>

int f(int s[])
{
  printf("%d",s[1]);
  return 0;
}



int main()
{
  int x[3]={1,9,100};
  f(x);
  return 0;
}

