all: LCC.so LCF.so
	rm *.o



# Lua Call C
LCC.so: LCC.c
	gcc LCC.c -shared -fPIC -Iapi -lm -o LCC.so



# Lua Call Fortran
LCF.so: LCF.o try_f.o
	gfortran LCF.o try_f.o -shared -fPIC -Iapi -lm -o LCF.so

LCF.o: LCF.c
	gcc -c LCF.c -shared -fPIC -Iapi -lm -o LCF.o

try_f.o: try.f90
	gfortran -c try.f90 -o try_f.o



clean:
	rm *.o *.so
