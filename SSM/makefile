all: LC_gravity.so LC_de430.so LC_plot.so
	rm *.o

clean:
	rm *.o *.so

#------------------------------------------------------------------------------

LC_gravity.so: LC_gravity.c
	gcc LC_gravity.c -shared -fPIC -ILua -o LC_gravity.so

#------------------------------------------------------------------------------

LC_de430.o: LC_de430.c
	gcc -c LC_de430.c -shared -fPIC -ILua -o LC_de430.o

trytesteph.o: trytesteph.f
	gfortran -c trytesteph.f -shared -fPIC -ILua -o trytesteph.o

LC_de430.so: LC_de430.o trytesteph.o 
	gfortran LC_de430.o trytesteph.o -shared -fPIC -ILua -o LC_de430.so

#------------------------------------------------------------------------------

LC_plot.o: LC_plot.c
	gcc -c LC_plot.c -shared -fPIC -IPGPLOT -ILua -o LC_plot.o

LC_plot.so: LC_plot.o
	gfortran LC_plot.o -shared -fPIC -LPGPLOT -lcpgplot -lpgplot -LLua -o LC_plot.so

#------------------------------------------------------------------------------

1.so: 1.c
	gcc   1.c -o 1 -Wl,-rpath -Wl,"/home/lihuan/soft/plplot/lib" \
		-I/home/lihuan/soft/plplot/include/plplot \
		-L/home/lihuan/soft/plplot/lib -lplplot \
		/usr/lib/x86_64-linux-gnu/libm.so
