cc=gcc



# Lua Call C
LCC.so: LCC.c
	cc LCC.c -shared -fPIC -I../lua -lm -o LCC.so



# Lua Call Fortran
LCF.so: LCF.o *.f.o
	gfortran LCF.o *.f.o -o LCF.so

LCF.o: LCF.c
	cc -c LCF.c -o LCF.o

try.o: try.f90
	gfortran -c try.f90 -o try.f.o



clean:
	rm *.o *.so
