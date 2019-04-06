#include "LCF_try.c"
#include "LCF_pleph.c"



static const struct luaL_Reg LCF[]=
{
  {"try",LCF_try},
  {"pleph",LCF_pleph},
  {NULL,NULL}
};



int luaopen_LCF(lua_State *L)
{
  luaL_register(L,"LCF",LCF);
  return 1;
}

