cmake_minimum_required(VERSION 2.6)
project(testluaf Fortran C)

# Prefer static
find_library(LUA_STATIC_LIB NAMES 
	liblua51.a liblua5.1.a liblua-5.1.a liblua.a
	lua51 lua5.1 lua-5.1 lua)

if(LUA_STATIC_LIB)
	message(STATUS "Lua 5.1 found: ${LUA_STATIC_LIB}")
else()
	message(SEND_ERROR "Lua 5.1 not found")
endif()

find_package(Lua51 REQUIRED)

include_directories(${LUA_INCLUDE_DIR})
add_executable(genconf ../genconf.c)
target_link_libraries(genconf ${LUA_LIBRARIES})

add_custom_command(
	OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/luaf_conf.fi
	COMMAND genconf > luaf_conf.fi
	DEPENDS genconf
	)

set (src
	test.f90
	../luaf.f90
	../luafe.f90
	${CMAKE_CURRENT_BINARY_DIR}/luaf_conf.fi
	)

add_executable(testluaf ${src})
target_link_libraries(testluaf ${LUA_STATIC_LIB})
set_target_properties(testluaf PROPERTIES COMPILE_FLAGS "-fp-model precise -xHOST -O0 -g -traceback")
#set_target_properties(testluaf PROPERTIES COMPILE_FLAGS "-fp-model precise -xHOST -O2")

#set_target_properties(tr2surf PROPERTIES LINK_FLAGS_VADIM "-mkl -static-intel")

# Ad-hoc
set(CMAKE_SHARED_LIBRARY_LINK_Fortran_FLAGS "")
