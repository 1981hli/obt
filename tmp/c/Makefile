# examples/c/Makefile.examples.in for PLplot
###
### Configure this file with CMake to produce Makefile.examples
###
# Copyright (C) 2002-2015  Alan W. Irwin
# Copyright (C) 2004  Rafael Laboissiere
# Copyright (C) 2004  Andrew Ross
#
# This file is part of PLplot.
#
# PLplot is free software; you can redistribute it and/or modify
# it under the terms of the GNU Library General Public License as published by
# the Free Software Foundation; version 2 of the License.
#
# PLplot is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Library General Public License for more details.
#
# You should have received a copy of the GNU Library General Public License
# along with the file PLplot; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA

SHELL = /bin/bash
CC = /usr/bin/cc  
EXEEXT = 

PKG_CONFIG_ENV = PKG_CONFIG_PATH="/home/lihuan/soft/plplot/lib/pkgconfig"
RPATHCMD = -Wl,-rpath -Wl,"/home/lihuan/soft/plplot/lib"

#extXdrawable_EXECUTABLES_list = \
#	extXdrawable_demo$(EXEEXT)

#extcairo_EXECUTABLES_list = \
#	ext-cairo-test$(EXEEXT)

EXECUTABLES_list = \
		 1$(EXEEXT) \
		 $(extXdrawable_EXECUTABLES_list) \
		 $(extcairo_EXECUTABLES_list)

all: $(EXECUTABLES_list)

clean:
	rm -f $(EXECUTABLES_list)

# target_link_libraries(extXdrawable_demo  plplot)
# N.B. the above CMake method derives  from pkg-config
# results determined by CMake.  Instead of transforming those back
# to pkg-config form, we instead use the the pkg-config gtk+-x11-2.0 package directly.
#extXdrawable_demo$(EXEEXT): extXdrawable_demo.c
#	$(CC) $< -o $@ $(RPATHCMD) \
#	$(shell $(PKG_CONFIG_ENV) pkg-config  --cflags --libs plplot gtk+-x11-2.0)

# target_link_libraries(ext-cairo-test  plplot)
# N.B. the above CMake method derives  from pkg-config
# results determined by CMake.  Instead of transforming those back
# to pkg-config form, we instead use the
# the cairo pkg-config package directly.
#ext-cairo-test$(EXEEXT): ext-cairo-test.c
#	$(CC) $< -o $@ $(RPATHCMD) \
#	$(shell $(PKG_CONFIG_ENV) pkg-config  --cflags --libs plplot cairo)

# target_link_libraries(xc plplot /usr/lib/x86_64-linux-gnu/libm.so)
.c$(EXEEXT):
	$(CC) $< -o $@ $(RPATHCMD) $(shell $(PKG_CONFIG_ENV) pkg-config  --cflags --libs plplot) /usr/lib/x86_64-linux-gnu/libm.so

.SUFFIXES: .c $(EXEEXT)
