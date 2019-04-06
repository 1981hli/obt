#include "LCC_gravity.c"

static const struct luaL_Reg LCC[]=
{
  {"gravityby1",LCC_gravityby1},
  {NULL,NULL}
};

int luaopen_LCC(lua_State *L)
{
  luaL_register(L,"LCC",LCC);
  return 1;
}
