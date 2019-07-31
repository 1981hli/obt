Compiler_C=gcc
Compiler_F=gfortran
Flag=-lm
Flag_Lua=-shared -fPIC -ILua
Dir_mod_C=mod

all: Cgravity.so CDE430.so
	rm *.o

clean:
	rm *.o $(Dir_mod_C)/*.so

cleanout:
	rm data/out_*

#-------------------------------------------------------------------------------

CDE430.so: CDE430.o trytesteph.o 
	$(Compiler_F) -o $(Dir_mod_C)/$@ $^ $(Flag) $(Flag_Lua) 

CDE430.o: CDE430.c
	$(Compiler_C) -o $@ -c $^ $(Flag) $(Flag_Lua) 

trytesteph.o: trytesteph.f
	$(Compiler_F) -o $@ -c $^ $(Flag) $(Flag_Lua) 

#-------------------------------------------------------------------------------

Cgravity.so: Cgravity.c common.c
	$(Compiler_C) -o $(Dir_mod_C)/$@ $^ $(Flag) $(Flag_Lua) 

