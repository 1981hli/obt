#include "LCF_try.c"



static const struct luaL_Reg LCF[]=
{
  {"try",LCF_try},
  {NULL,NULL}
};



int luaopen_LCF(lua_State *L)
{
  luaL_register(L,"LCF",LCF);
  return 1;
}

