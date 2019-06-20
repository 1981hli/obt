all: LC_gravity.so LC_de430.so
	rm *.o

clean:
	rm *.o *.so

#------------------------------------------------------------------------------

LC_de430.o: LC_de430.c
	gcc -c LC_de430.c -shared -fPIC -ILua -o LC_de430.o

trytesteph.o: trytesteph.f
	gfortran -c trytesteph.f -shared -fPIC -ILua -o trytesteph.o

LC_de430.so: LC_de430.o trytesteph.o 
	gfortran LC_de430.o trytesteph.o -shared -fPIC -ILua -o LC_de430.so

#------------------------------------------------------------------------------

LC_gravity.so: LC_gravity.c Vector.c
	gcc LC_gravity.c Vector.c -shared -fPIC -ILua -o LC_gravity.so

