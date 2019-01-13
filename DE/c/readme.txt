*****************************************************************************
*****      C version software for the JPL planetary ephemerides.        *****
*****************************************************************************

version 1.4, March 13, 2014

Piotr A. Dybczynski, Astronomical Observatory of the A. Mickiewicz Universty,
Sloneczna 36, 60-286 Poznan, POLAND.
e-mail: dybol@amu.edu.pl
www: http://apollo.astro.amu.edu.pl/PAD/index.php?n=Dybol.JPLEph

*****************************************************************************
File list:
   Size   date     time   file
  2168 mar 13 09:59 jplbin.h
  2697 mar 13 10:29 readme.txt
 33138 mar 13 10:00 testeph.c

****************************************************************************

CHANGES FROM VERSION 1.3: added support for DE430 and DE431.
                          The main change is to allow for more than 400 ephemeris
                          constants, as required in case of DE430 and DE431.
                          Some minor improvements are also done.

******************************************************************************
 The original JPL datafiles, FORTRAN code and documentation can be found at:
              http://ssd.jpl.nasa.gov/?planet_eph_export
******************************************************************************

Version (1.4) works with:

DE200, DE403, DE404, DE405, DE406, DE421, DE422, DE430 and DE431

This file describes public domain software for using and manipulating
JPL export planetary ephemerides, written in C language.

In original JPL export packages you can find several FORTRAN source files
for reading and testing ephemerides.

Here you can find C version of TESTEPH program.

TESTEPH.C is a manual translation of the original JPL 
FORTRAN code, slightly changed and adapted for C language.

*****************************************************************************
IT IS NECESSARY TO ADJUST MANUALLY SOURCE FILES before you compile and run
them. First, look at the file: JPLBIN.H, used by TESTEPH.C
It contains the definition of DENUM, JPL ephemeris number. Some variables
obtain their values depending on DENUM (eg. RECSIZE - record size ).
Second, look at lines with fopen() calls in TESTEPH.C 
Adjust them for your environment, adding a path before filenames where necessary.
******************************************************************************

All source files are rich of comments and ( I hope ) therefore are
self explanatory. Works in standard 32-bit linux environment.

All suggestions, bug reports or questions may be directed to the author:

Piotr A. Dybczynski, e-mail: dybol@amu.edu.pl

Please send me also a word if you use my software with success.

April 13, 2015.


