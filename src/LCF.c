#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
#include <stdio.h>

int main()
{
  int x,y,z;
  x=1;
  y=2;
  add_(&x,&y,&z);
  printf("z=%d\n",z);
  return 0;
}

//-----------------------------------------------------------------------------
// LCF

static const struct luaL_Reg LCF[]=
{
  {"add",add_LCF},
  {NULL,NULL}
};



int luaopen_LCF(lua_State *L)
{
  luaL_register(L,"LCF",LCF);
  return 1;
}
