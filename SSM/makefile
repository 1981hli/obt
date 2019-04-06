all: LCC.so LCF.so
	rm *.o

clean:
	rm *.o *.so

#------------------------------------------------------------------------------

LCC.so: LCC.c
	gcc LCC.c -shared -fPIC -ILua -o LCC.so

#------------------------------------------------------------------------------

LCF.o: LCF.c
	gcc -c LCF.c -shared -fPIC -ILua -o LCF.o

trytesteph.o: trytesteph.f
	gfortran -c trytesteph.f -shared -fPIC -ILua -o trytesteph.o

LCF.so: LCF.o trytesteph.o 
	gfortran LCF.o trytesteph.o -shared -fPIC -ILua -o LCF.so
