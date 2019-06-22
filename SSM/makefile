all: Cgravity.so CDE430.so
	rm *.o

clean:
	rm *.o *.so

#------------------------------------------------------------------------------

CDE430.o: CDE430.c
	gcc -c CDE430.c -shared -fPIC -ILua -o CDE430.o

trytesteph.o: trytesteph.f
	gfortran -c trytesteph.f -shared -fPIC -ILua -o trytesteph.o

CDE430.so: CDE430.o trytesteph.o 
	gfortran CDE430.o trytesteph.o -shared -fPIC -ILua -o CDE430.so

#------------------------------------------------------------------------------

Cgravity.so: Cgravity.c Vector.c
	gcc Cgravity.c Vector.c -shared -fPIC -ILua -o Cgravity.so

