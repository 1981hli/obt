Compiler_C=gcc
Compiler_F=gfortran
Flag=-lm
Flag_Lua=-shared -fPIC -ILua
Flag_PGPLOT=-IPGPLOT -LPGPLOT -lcpgplot -lpgplot
Dir_mod_C=mod
Dir_PGPLOT=PGPLOT

all: Cgravity.so CDE430.so Cplot.so
	rm *.o

clean:
	rm *.o $(Dir_mod_C)/*.so $(Dir_PGPLOT)/*.so

#-------------------------------------------------------------------------------

CDE430.so: CDE430.o trytesteph.o 
	$(Compiler_F) -o $(Dir_mod_C)/$@ $^ $(Flag_Lua) 

CDE430.o: CDE430.c
	$(Compiler_C) -o $@ -c $^ $(Flag_Lua) 

trytesteph.o: trytesteph.f
	$(Compiler_F) -o $@ -c $^ $(Flag_Lua) 

#-------------------------------------------------------------------------------

Cgravity.so: Cgravity.c common.c
	$(Compiler_C) -o $(Dir_mod_C)/$@ $^ $(Flag_Lua) 

#-------------------------------------------------------------------------------

Cplot.so: Cplot.o
	$(Compiler_F) -o $(Dir_mod_C)/$@ $^ $(Flag) $(Flag_Lua) $(Flag_PGPLOT) 

Cplot.o: Cplot.c
	$(Compiler_C) -o $@ -c $^ $(Flag_Lua) $(Flag_PGPLOT)

