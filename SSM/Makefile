Flag=-shared -fPIC

all: jpleph.so
	rm *.o
clean:
	rm *.o *.so

jpleph.so: jpleph.o trytesteph.o
	gfortran -o $@ $^ $(Flag)
jpleph.o: jpleph.c
	gcc -o $@ -c $^ $(Flag)
trytesteph.o: trytesteph.f
	gfortran -o $@ -c $^ $(Flag) 
