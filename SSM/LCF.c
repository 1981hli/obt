#include "LCF_de430.c"

static const struct luaL_Reg LCF[]=
{
  {"readstate",LCF_readstate},
  {NULL,NULL}
};

int luaopen_LCF(lua_State *L)
{
  luaL_register(L,"LCF",LCF);
  return 1;
}
