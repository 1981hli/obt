read: read.f90 trytesteph.o
	gfortran read.f90 trytesteph.o -o read

trytesteph.o: trytesteph.f
	gfortran -c trytesteph.f

clean:
	rm *.o read
