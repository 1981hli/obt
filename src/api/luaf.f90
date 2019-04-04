MODULE LUAF_TYPES
    USE, INTRINSIC :: ISO_C_BINDING, ONLY: C_INT, C_PTR, C_FUNPTR, C_CHAR
    IMPLICIT NONE
    PRIVATE

    INCLUDE 'luaf_conf.fi'

    TYPE, PUBLIC, BIND(C) :: luaL_Reg
        TYPE(C_PTR) :: name
        TYPE(C_FUNPTR) :: func
    END TYPE luaL_Reg

    TYPE, PUBLIC, BIND(C) :: lua_Debug
        INTEGER(KIND=C_INT) :: event
        TYPE(C_PTR) :: name
        TYPE(C_PTR) :: namewhat
        TYPE(C_PTR) :: what
        TYPE(C_PTR) :: source
        INTEGER(KIND=C_INT) :: currentline
        INTEGER(KIND=C_INT) :: nups
        INTEGER(KIND=C_INT) :: linedefined
        INTEGER(KIND=C_INT) :: lastlinedefined
        CHARACTER(KIND=C_CHAR, LEN=1), DIMENSION(LUA_IDSIZE) :: short_src
        ! private part 
    END TYPE lua_Debug

    TYPE, PUBLIC, BIND(C) :: luaL_Buffer
        TYPE(C_PTR) :: p
        INTEGER(KIND=C_INT) :: lvl
        TYPE(C_PTR) :: L
        CHARACTER(KIND=C_CHAR, LEN=1), DIMENSION(LUAL_BUFFERSIZE) :: buffer
    END TYPE luaL_Buffer

END MODULE LUAF_TYPES
    
MODULE LUAF
    USE, INTRINSIC :: ISO_C_BINDING, ONLY: C_INT
    USE LUAF_TYPES
    IMPLICIT NONE

    INCLUDE 'luaf_const.fi'
    INCLUDE 'luaf_conf.fi'

    INTERFACE
        INCLUDE 'luaf_int.fi'
    END INTERFACE

CONTAINS

    ! ==================================================================
    ! By-reference interfaces for some functions where pointer interface
    ! is default. We need them since gfortran fails to compile different
    ! subroutines with the same binding label (permitted in Fortran'08).
    ! They have _r suffix and accept C types.

!extern lua_Alloc (lua_getallocf) (lua_State *L, void **ud)
    FUNCTION lua_getallocf_r(L1, ud2)
        USE, INTRINSIC :: ISO_C_BINDING, ONLY: C_PTR, C_FUNPTR, C_LOC
        IMPLICIT NONE
        TYPE(C_PTR), INTENT(IN) :: L1
        TYPE(C_PTR), TARGET, INTENT(INOUT) :: ud2
        TYPE(C_FUNPTR) :: lua_getallocf_r
        TYPE(C_PTR) :: p
        p = C_LOC(ud2)
        lua_getallocf_r = lua_getallocf(L1, p)
    END FUNCTION lua_getallocf_r

!extern void (luaL_register) (lua_State *L, const char *libname,
!                                const luaL_Reg *l)
    SUBROUTINE luaL_register_r(L1, libname2, l3)
        USE, INTRINSIC :: ISO_C_BINDING, ONLY: C_PTR, C_CHAR, C_LOC
        USE LUAF_TYPES, ONLY: luaL_Reg
        IMPLICIT NONE
        TYPE(C_PTR), INTENT(IN) :: L1
        CHARACTER(KIND=C_CHAR, LEN=1), DIMENSION(*), TARGET, INTENT(IN) :: libname2
        TYPE(luaL_Reg), DIMENSION(*), INTENT(IN) :: l3
        TYPE(C_PTR) :: p
        p = C_LOC(libname2)
        CALL luaL_register(L1, p, l3)
    END SUBROUTINE luaL_register_r

!extern int (luaL_checkoption) (lua_State *L, int narg, const char *def,
!                                   const char *const lst[])
    FUNCTION luaL_checkoption_r(L1, narg2, def3, lst4)
        USE, INTRINSIC :: ISO_C_BINDING, ONLY: C_PTR, C_INT, C_CHAR, C_LOC
        IMPLICIT NONE
        TYPE(C_PTR), INTENT(IN) :: L1
        INTEGER(KIND=C_INT), INTENT(IN) :: narg2
        CHARACTER(KIND=C_CHAR, LEN=1), DIMENSION(*), TARGET, INTENT(IN) :: def3
        TYPE(C_PTR), DIMENSION(*), INTENT(IN) :: lst4
        INTEGER(KIND=C_INT) :: luaL_checkoption_r
        TYPE(C_PTR) :: p
        p = C_LOC(def3)
        luaL_checkoption_r = luaL_checkoption(L1, narg2, p, lst4)
    END FUNCTION luaL_checkoption_r

!extern int (luaL_loadfile) (lua_State *L, const char *filename)
    FUNCTION luaL_loadfile_r(L1, file_fname2)
        USE, INTRINSIC :: ISO_C_BINDING, ONLY: C_PTR, C_CHAR, C_INT, C_LOC
        IMPLICIT NONE
        TYPE(C_PTR), INTENT(IN) :: L1
        CHARACTER(KIND=C_CHAR, LEN=1), DIMENSION(*), TARGET, INTENT(IN) :: file_fname2
        INTEGER(KIND=C_INT) :: luaL_loadfile_r
        TYPE(C_PTR) :: p
        p = C_LOC(file_fname2)
        luaL_loadfile_r = luaL_loadfile(L1, p)
    END FUNCTION luaL_loadfile_r

    ! ==================================================================
    ! Implemented macros

!#define lua_upvalueindex(i) (LUA_GLOBALSINDEX-(i))
    FUNCTION lua_upvalueindex(i)
        USE, INTRINSIC :: ISO_C_BINDING, ONLY: C_INT
        IMPLICIT NONE
        INTEGER, INTENT(IN) :: i
        INTEGER(KIND=C_INT) :: lua_upvalueindex
        lua_upvalueindex = LUA_GLOBALSINDEX-INT(i, C_INT)
    END FUNCTION lua_upvalueindex
        
!#define lua_pop(L,n) lua_settop(L, -(n)-1)
    SUBROUTINE lua_pop(L, n)
        USE, INTRINSIC :: ISO_C_BINDING, ONLY: C_PTR, C_INT
        IMPLICIT NONE
        TYPE(C_PTR), INTENT(IN) :: L
        INTEGER, INTENT(IN) :: n
        CALL lua_settop(L, INT(-n-1, C_INT))
    END SUBROUTINE lua_pop

!#define lua_newtable(L) lua_createtable(L, 0, 0)
    SUBROUTINE lua_newtable(L)
        USE, INTRINSIC :: ISO_C_BINDING, ONLY: C_PTR, C_INT
        IMPLICIT NONE
        TYPE(C_PTR), INTENT(IN) :: L
        CALL lua_createtable(L, 0_C_INT, 0_C_INT)
    END SUBROUTINE lua_newtable

!#define lua_register(L,n,f) (lua_pushcfunction(L, (f)), lua_setglobal(L, (n)))
    SUBROUTINE lua_register(L, n, f)
        USE, INTRINSIC :: ISO_C_BINDING, ONLY: C_PTR, C_CHAR, C_FUNPTR
        IMPLICIT NONE
        TYPE(C_PTR), INTENT(IN) :: L
        CHARACTER(KIND=C_CHAR, LEN=1), DIMENSION(*), INTENT(IN) :: n
        TYPE(C_FUNPTR), INTENT(IN) :: f
        CALL lua_pushcfunction(L, f)
        CALL lua_setglobal(L, n)
    END SUBROUTINE lua_register

!#define lua_pushcfunction(L,f) lua_pushcclosure(L, (f), 0)
    SUBROUTINE lua_pushcfunction(L, f)
        USE, INTRINSIC :: ISO_C_BINDING, ONLY: C_PTR, C_FUNPTR, C_INT
        IMPLICIT NONE
        TYPE(C_PTR), INTENT(IN) :: L
        TYPE(C_FUNPTR), INTENT(IN) :: f
        CALL lua_pushcclosure(L, f, 0_C_INT)
    END SUBROUTINE lua_pushcfunction

!#define lua_isfunction(L,n) (lua_type(L, (n)) == LUA_TFUNCTION)
    FUNCTION lua_isfunction(L, n)
        USE, INTRINSIC :: ISO_C_BINDING, ONLY: C_PTR, C_INT
        IMPLICIT NONE
        TYPE(C_PTR), INTENT(IN) :: L
        INTEGER, INTENT(IN) :: n
        LOGICAL :: lua_isfunction
        lua_isfunction = lua_type(L, INT(n, C_INT)) == LUA_TFUNCTION
    END FUNCTION lua_isfunction

!#define lua_istable(L,n) (lua_type(L, (n)) == LUA_TTABLE)
    FUNCTION lua_istable(L, n)
        USE, INTRINSIC :: ISO_C_BINDING, ONLY: C_PTR, C_INT
        IMPLICIT NONE
        TYPE(C_PTR), INTENT(IN) :: L
        INTEGER, INTENT(IN) :: n
        LOGICAL :: lua_istable
        lua_istable = lua_type(L, INT(n, C_INT)) == LUA_TTABLE
    END FUNCTION lua_istable

!#define lua_islightuserdata(L,n) (lua_type(L, (n)) == LUA_TLIGHTUSERDATA)
    FUNCTION lua_islightuserdata(L, n)
        USE, INTRINSIC :: ISO_C_BINDING, ONLY: C_PTR, C_INT
        IMPLICIT NONE
        TYPE(C_PTR), INTENT(IN) :: L
        INTEGER, INTENT(IN) :: n
        LOGICAL :: lua_islightuserdata
        lua_islightuserdata = lua_type(L, INT(n, C_INT)) == LUA_TLIGHTUSERDATA
    END FUNCTION lua_islightuserdata

!#define lua_isnil(L,n) (lua_type(L, (n)) == LUA_TNIL)
    FUNCTION lua_isnil(L, n)
        USE, INTRINSIC :: ISO_C_BINDING, ONLY: C_PTR, C_INT
        IMPLICIT NONE
        TYPE(C_PTR), INTENT(IN) :: L
        INTEGER, INTENT(IN) :: n
        LOGICAL :: lua_isnil
        lua_isnil = lua_type(L, INT(n, C_INT)) == LUA_TNIL
    END FUNCTION lua_isnil

!#define lua_isboolean(L,n) (lua_type(L, (n)) == LUA_TBOOLEAN)
    FUNCTION lua_isboolean(L, n)
        USE, INTRINSIC :: ISO_C_BINDING, ONLY: C_PTR, C_INT
        IMPLICIT NONE
        TYPE(C_PTR), INTENT(IN) :: L
        INTEGER, INTENT(IN) :: n
        LOGICAL :: lua_isboolean
        lua_isboolean = lua_type(L, INT(n, C_INT)) == LUA_TBOOLEAN
    END FUNCTION lua_isboolean

!#define lua_isthread(L,n) (lua_type(L, (n)) == LUA_TTHREAD)
    FUNCTION lua_isthread(L, n)
        USE, INTRINSIC :: ISO_C_BINDING, ONLY: C_PTR, C_INT
        IMPLICIT NONE
        TYPE(C_PTR), INTENT(IN) :: L
        INTEGER, INTENT(IN) :: n
        LOGICAL :: lua_isthread
        lua_isthread = lua_type(L, INT(n, C_INT)) == LUA_TTHREAD
    END FUNCTION lua_isthread

!#define lua_isnone(L,n) (lua_type(L, (n)) == LUA_TNONE)
    FUNCTION lua_isnone(L, n)
        USE, INTRINSIC :: ISO_C_BINDING, ONLY: C_PTR, C_INT
        IMPLICIT NONE
        TYPE(C_PTR), INTENT(IN) :: L
        INTEGER, INTENT(IN) :: n
        LOGICAL :: lua_isnone
        lua_isnone = lua_type(L, INT(n, C_INT)) == LUA_TNONE
    END FUNCTION lua_isnone

!#define lua_isnoneornil(L,n) (lua_type(L, (n)) <= 0)
    FUNCTION lua_isnoneornil(L, n)
        USE, INTRINSIC :: ISO_C_BINDING, ONLY: C_PTR, C_INT
        IMPLICIT NONE
        TYPE(C_PTR), INTENT(IN) :: L
        INTEGER, INTENT(IN) :: n
        LOGICAL :: lua_isnoneornil
        lua_isnoneornil = lua_type(L, INT(n, C_INT)) <= 0
    END FUNCTION lua_isnoneornil

! This macro/subroutine is useless in Fortran since we always know
! string length. Use lua_pushstring_f instead.
!#define lua_pushliteral(L,s) lua_pushlstring(L, "" s, (sizeof(s)/sizeof(char))-1)

!#define lua_setglobal(L,s) lua_setfield(L, LUA_GLOBALSINDEX, (s))
    SUBROUTINE lua_setglobal(L, s)
        USE, INTRINSIC :: ISO_C_BINDING, ONLY: C_PTR, C_CHAR
        IMPLICIT NONE
        TYPE(C_PTR), INTENT(IN) :: L
        CHARACTER(KIND=C_CHAR, LEN=1), DIMENSION(*), INTENT(IN) :: s
        CALL lua_setfield(L, LUA_GLOBALSINDEX, s)
    END SUBROUTINE lua_setglobal

!#define lua_getglobal(L,s) lua_getfield(L, LUA_GLOBALSINDEX, (s))
    SUBROUTINE lua_getglobal(L, s)
        USE, INTRINSIC :: ISO_C_BINDING, ONLY: C_PTR, C_CHAR
        IMPLICIT NONE
        TYPE(C_PTR), INTENT(IN) :: L
        CHARACTER(KIND=C_CHAR, LEN=1), DIMENSION(*), INTENT(IN) :: s
        CALL lua_getfield(L, LUA_GLOBALSINDEX, s)
    END SUBROUTINE lua_getglobal

! Macro corresponds to wrapper lua_tostring_f, see below
!#define lua_tostring(L,i) lua_tolstring(L, (i), NULL)

!#define luaL_argcheck(L,cond,numarg,extramsg) ((void)((cond) || luaL_argerror(L, (numarg), (extramsg))))
    SUBROUTINE luaL_argcheck(L, cond, numarg, extramsg)
        USE, INTRINSIC :: ISO_C_BINDING, ONLY: C_PTR, C_INT, C_CHAR
        IMPLICIT NONE
        TYPE(C_PTR), INTENT(IN) :: L
        LOGICAL, INTENT(IN) :: cond
        INTEGER, INTENT(IN) :: numarg
        CHARACTER(KIND=C_CHAR, LEN=1), DIMENSION(*), INTENT(IN) :: extramsg
        INTEGER :: dummy
        IF (cond) THEN
            dummy = luaL_argerror(L, INT(numarg, C_INT), extramsg)
        ENDIF
    END SUBROUTINE luaL_argcheck
    
! Macro corresponds to wrapper lua_checkstring_f, see below
!#define luaL_checkstring(L,n) (luaL_checklstring(L, (n), NULL))

! Macro corresponds to wrapper lua_optstring_f, see below
!#define luaL_optstring(L,n,d) (luaL_optlstring(L, (n), (d), NULL))

!#define luaL_checkint(L,n) ((int)luaL_checkinteger(L, (n)))
    FUNCTION luaL_checkint(L, n)
        USE, INTRINSIC :: ISO_C_BINDING, ONLY: C_PTR, C_INT
        IMPLICIT NONE
        TYPE(C_PTR), INTENT(IN) :: L
        INTEGER, INTENT(IN) :: n
        INTEGER :: luaL_checkint
        luaL_checkint = INT(luaL_checkinteger(L, INT(n, C_INT)), &
            & KIND(luaL_checkint))
    END FUNCTION luaL_checkint

!#define luaL_optint(L,n,d) ((int)luaL_optinteger(L, (n), (d)))
    FUNCTION luaL_optint(L, n, d)
        USE, INTRINSIC :: ISO_C_BINDING, ONLY: C_PTR, C_INT, C_INTPTR_T
        IMPLICIT NONE
        TYPE(C_PTR), INTENT(IN) :: L
        INTEGER, INTENT(IN) :: n
        INTEGER, INTENT(IN) :: d
        INTEGER :: luaL_optint
        luaL_optint = INT(luaL_optinteger(L, INT(n, C_INT), &
            & INT(d, C_INTPTR_T)), KIND(d))
    END FUNCTION luaL_optint

! Assume long = 8
!#define luaL_checklong(L,n) ((long)luaL_checkinteger(L, (n)))
    FUNCTION luaL_checklong(L, n)
        USE, INTRINSIC :: ISO_C_BINDING, ONLY: C_PTR, C_LONG, C_INT
        IMPLICIT NONE
        TYPE(C_PTR), INTENT(IN) :: L
        INTEGER, INTENT(IN) :: n
        INTEGER(8) :: luaL_checklong
        luaL_checklong = INT(luaL_checkinteger(L, INT(n, C_INT)), &
            & KIND(luaL_checklong))
    END FUNCTION luaL_checklong

!#define luaL_optlong(L,n,d) ((long)luaL_optinteger(L, (n), (d)))
    FUNCTION luaL_optlong(L, n, d)
        USE, INTRINSIC :: ISO_C_BINDING, ONLY: C_PTR, C_LONG, C_INTPTR_T, C_INT
        IMPLICIT NONE
        TYPE(C_PTR), INTENT(IN) :: L
        INTEGER, INTENT(IN) :: n
        INTEGER(8), INTENT(IN) :: d
        INTEGER(8) :: luaL_optlong
        luaL_optlong = INT(luaL_optinteger(L, INT(n, C_INT), &
            & INT(d, C_INTPTR_T)), KIND(d))
    END FUNCTION luaL_optlong

! Macro corresponds to wrapper lua_typename_f, see below
!#define luaL_typename(L,i) lua_typename(L, lua_type(L,(i)))

! Two interfaces
!#define luaL_dofile(L,fn) (luaL_loadfile(L, fn) || lua_pcall(L, 0, LUA_MULTRET, 0))
    FUNCTION luaL_dofile(L, fn)
        USE, INTRINSIC :: ISO_C_BINDING, ONLY: C_PTR, C_INT
        IMPLICIT NONE
        TYPE(C_PTR), INTENT(IN) :: L
        TYPE(C_PTR), INTENT(IN) :: fn
        INTEGER :: luaL_dofile
        INTEGER :: r
        r = luaL_loadfile(L, fn)
        IF (r == 0) THEN
            r = lua_pcall(L, 0_C_INT, LUA_MULTRET, 0_C_INT)
        END IF
        luaL_dofile = r 
    END FUNCTION luaL_dofile

    FUNCTION luaL_dofile_r(L, fn)
        USE, INTRINSIC :: ISO_C_BINDING, ONLY: C_PTR, C_INT, C_CHAR
        IMPLICIT NONE
        TYPE(C_PTR), INTENT(IN) :: L
        CHARACTER(KIND=C_CHAR, LEN=1), DIMENSION(*), INTENT(IN) :: fn
        INTEGER :: luaL_dofile_r
        INTEGER :: r
        r = luaL_loadfile_r(L, fn)
        IF (r == 0) THEN
            r = lua_pcall(L, 0_C_INT, LUA_MULTRET, 0_C_INT)
        END IF
        luaL_dofile_r = r 
    END FUNCTION luaL_dofile_r

!#define luaL_dostring(L,s) (luaL_loadstring(L, s) || lua_pcall(L, 0, LUA_MULTRET, 0))
    FUNCTION luaL_dostring(L, s)
        USE, INTRINSIC :: ISO_C_BINDING, ONLY: C_PTR, C_INT, C_CHAR
        IMPLICIT NONE
        TYPE(C_PTR), INTENT(IN) :: L
        CHARACTER(KIND=C_CHAR, LEN=1), DIMENSION(*), INTENT(IN) :: s
        INTEGER :: luaL_dostring
        INTEGER :: r
        r = luaL_loadstring(L, s)
        IF (r == 0) THEN
            r = lua_pcall(L, 0_C_INT, LUA_MULTRET, 0_C_INT)
        END IF
        luaL_dostring = r 
    END FUNCTION luaL_dostring

!#define luaL_getmetatable(L,n) (lua_getfield(L, LUA_REGISTRYINDEX, (n)))
    SUBROUTINE luaL_getmetatable(L, n)
        USE, INTRINSIC :: ISO_C_BINDING, ONLY: C_PTR, C_CHAR
        IMPLICIT NONE
        TYPE(C_PTR), INTENT(IN) :: L
        CHARACTER(KIND=C_CHAR, LEN=1), DIMENSION(*), INTENT(IN) :: n
        CALL lua_getfield(L, LUA_REGISTRYINDEX, n)
    END SUBROUTINE luaL_getmetatable


    ! These functions assume that C_PTR and INTEGER(C_INTPTR_T)
    ! have the same internal representation and that C character is 1 byte
    ! This might be invalid on some platforms.

!#define luaL_addchar(B,c) ((void)((B)->p < ((B)->buffer+LUAL_BUFFERSIZE) || luaL_prepbuffer(B)), (*(B)->p++ = (char)(c)))
    SUBROUTINE luaL_addchar(B, c)
        USE, INTRINSIC :: ISO_C_BINDING, ONLY: C_CHAR, C_INTPTR_T, C_PTR, C_LOC
        USE LUAF_TYPES, ONLY: luaL_Buffer
        IMPLICIT NONE
        TYPE(luaL_Buffer), TARGET, INTENT(INOUT) :: B
        CHARACTER(KIND=C_CHAR, LEN=1), INTENT(IN) :: c
        INTEGER(KIND=C_INTPTR_T) :: ipp, ipbuf, idx
        TYPE(C_PTR) :: dummy

        ! Convert ptrs to integer addresses
        ! Without (1), some versions of gfortran fail w/segfault
        ipbuf = TRANSFER(C_LOC(B%buffer(1)), 0_C_INTPTR_T)
        ipp = TRANSFER(B%p, 0_C_INTPTR_T)
        idx = ipp - ipbuf
        
        IF (idx >= LUAL_BUFFERSIZE) THEN
            dummy = luaL_prepbuffer(B)
            ! Recalculate addresses
            ipbuf = TRANSFER(C_LOC(B%buffer(1)), 0_C_INTPTR_T)
            ipp = TRANSFER(B%p, 0_C_INTPTR_T)
            idx = ipp - ipbuf
        ENDIF
        B%buffer(1+idx) = c
        ! Convert back to ptr
        B%p = TRANSFER(ipp+1, B%p)
    END SUBROUTINE luaL_addchar

!#define luaL_addsize(B,n) ((B)->p += (n))
    SUBROUTINE luaL_addsize(B, n)
        USE, INTRINSIC :: ISO_C_BINDING, ONLY: C_INTPTR_T
        USE LUAF_TYPES, ONLY: luaL_Buffer
        IMPLICIT NONE
        TYPE(luaL_Buffer), TARGET, INTENT(INOUT) :: B
        INTEGER, INTENT(IN) :: n
        INTEGER(KIND=C_INTPTR_T) :: ipp

        ! Convert ptr to integer addresses
        ipp = TRANSFER(B%p, 0_C_INTPTR_T)
        ! Convert back to ptr
        B%p = TRANSFER(ipp+INT(n, C_INTPTR_T), B%p)
    END SUBROUTINE luaL_addsize

    ! ==================================================================
    ! Fortran <---> C string conversion functions.
    ! Note that C_CHAR kind is assumed here to be equal to default kind.
    ! This might be invalid on some platforms.

    ! Function to add terminating null char to Fortran string

    ! 1nd variant: default length
    FUNCTION F_C_STR(fstr)
        USE, INTRINSIC :: ISO_C_BINDING, ONLY: C_CHAR, C_NULL_CHAR
        IMPLICIT NONE
        CHARACTER(*), INTENT(IN) :: fstr
        CHARACTER(KIND=C_CHAR, LEN=LEN(fstr)+1) :: F_C_STR

        F_C_STR = fstr // C_NULL_CHAR
    END FUNCTION F_C_STR

    ! 2nd variant: trimmed length
    FUNCTION F_C_STRT(fstr)
        USE, INTRINSIC :: ISO_C_BINDING, ONLY: C_CHAR
        IMPLICIT NONE
        CHARACTER(*), INTENT(IN) :: fstr
        CHARACTER(KIND=C_CHAR, LEN=LEN_TRIM(fstr)+1) :: F_C_STRT

        F_C_STRT = F_C_STR(TRIM(fstr))
    END FUNCTION F_C_STRT

    ! Subroutines to convert C_PTR to Fortran string.
    ! Fortran buffer is specified as INOUT parameter.
    ! Result length is specified as length of the buffer.
    ! Output is truncated if required.

    ! 1st variant:
    ! Optional output parameters:
    ! actual string length determined from null character.
    ! logical flag if result isn't truncated.
    SUBROUTINE C_F_STR(cstr, fstr, lact, stat)
        USE, INTRINSIC :: ISO_C_BINDING, ONLY: C_PTR, C_CHAR,&
            & C_NULL_CHAR, C_F_POINTER
        IMPLICIT NONE
        TYPE(C_PTR), INTENT(IN) :: cstr
        CHARACTER(*), INTENT(INOUT) :: fstr
        INTEGER, OPTIONAL, INTENT(OUT) :: lact
        LOGICAL, OPTIONAL, INTENT(OUT) :: stat
        CHARACTER(KIND=C_CHAR, LEN=1), DIMENSION(:), POINTER :: fptr
        INTEGER :: l, l1

        l = LEN(fstr)
        fstr = ''

        ! Associate
        CALL C_F_POINTER(cstr, fptr, [l+1])

        l1 = 0
        DO WHILE (l1 < l .AND. fptr(l1+1) /= C_NULL_CHAR)
            l1 = l1 + 1
            fstr(l1:l1) = fptr(l1)
        ENDDO

        ! Now l1 <= l
        IF (PRESENT(lact)) THEN
            lact = l1
        ENDIF
        IF (PRESENT(stat)) THEN
            stat = fptr(l1+1) == C_NULL_CHAR
        END IF
    END SUBROUTINE C_F_STR

    ! 2nd variant:
    ! Input parameter:
    ! actual string length.
    ! Optional output parameters:
    ! logical flag if result isn't truncated.
    SUBROUTINE C_F_STRL(cstr, fstr, lact, stat)
        USE, INTRINSIC :: ISO_C_BINDING, ONLY: C_PTR, C_CHAR, C_F_POINTER
        IMPLICIT NONE
        TYPE(C_PTR), INTENT(IN) :: cstr
        CHARACTER(*), INTENT(INOUT) :: fstr
        INTEGER, INTENT(IN) :: lact
        LOGICAL, OPTIONAL, INTENT(OUT) :: stat
        CHARACTER(KIND=C_CHAR, LEN=1), DIMENSION(:), POINTER :: fptr
        INTEGER :: l, k

        l = LEN(fstr)
        fstr = ''

        ! Associate
        CALL C_F_POINTER(cstr, fptr, [l+1])

        DO k = 1, MIN(l, lact)
            fstr(k:k) = fptr(k)
        ENDDO

        IF (PRESENT(stat)) THEN
            stat = lact <= l
        END IF
    END SUBROUTINE C_F_STRL

    ! ==================================================================
    ! Fortran convenience wrappers
    ! Functon/macro is wrapped iff:
    ! * it returns (pointer to) C string, or
    ! * length of input (Fortran) string can be used somehow
    ! Output strings are truncated if required, 
    ! actual length and status args are ignored

!extern const char *(lua_typename) (lua_State *L, int tp)
    SUBROUTINE lua_typename_f(L1, tp2, fstr)
        USE, INTRINSIC :: ISO_C_BINDING, ONLY: C_PTR
        IMPLICIT NONE
        TYPE(C_PTR), INTENT(IN) :: L1
        INTEGER, INTENT(IN) :: tp2
        CHARACTER(*), INTENT(INOUT) :: fstr
        TYPE(C_PTR) :: cstr

        cstr = lua_typename(L1, tp2)
        CALL C_F_STR(cstr, fstr)
    END SUBROUTINE lua_typename_f

!extern const char *(lua_tolstring) (lua_State *L, int idx, size_t *len)
    FUNCTION lua_tolstring_f(L, idx, len, fstr) RESULT(r)
        USE, INTRINSIC :: ISO_C_BINDING, ONLY: C_PTR, C_INT, C_SIZE_T, &
            & C_LOC, C_ASSOCIATED
        IMPLICIT NONE
        TYPE(C_PTR), INTENT(IN) :: L
        INTEGER, INTENT(IN) :: idx
        INTEGER, INTENT(OUT) :: len
        CHARACTER(*), INTENT(INOUT) :: fstr
        LOGICAL :: r
        INTEGER(KIND=C_SIZE_T), TARGET :: ls
        TYPE(C_PTR) :: cstr
        TYPE(C_PTR) :: p

        p = C_LOC(ls)
        cstr = lua_tolstring(L, INT(idx, C_INT), p)
        len = INT(ls, KIND(len))

        r = C_ASSOCIATED(cstr)
        IF (r) THEN
            CALL C_F_STRL(cstr, fstr, len)
        END IF
    END FUNCTION lua_tolstring_f

! Since we always know string length, this wrapper calls lua_pushlstring
!extern void (lua_pushstring) (lua_State *L, const char *s)
    SUBROUTINE lua_pushstring_f(L, s)
        USE, INTRINSIC :: ISO_C_BINDING, ONLY: C_PTR, C_CHAR, C_SIZE_T
        IMPLICIT NONE
        TYPE(C_PTR), INTENT(IN) :: L
        CHARACTER(*), INTENT(IN) :: s
        CALL lua_pushlstring(L, s, INT(LEN(s), C_SIZE_T))
    END SUBROUTINE lua_pushstring_f

!extern const char *(luaL_checklstring) (lua_State *L, int numArg,
!                                                          size_t *l)
    SUBROUTINE luaL_checklstring_f(L1, numArg2, l3, fstr)
        USE, INTRINSIC :: ISO_C_BINDING, ONLY: C_PTR, C_INT, C_SIZE_T, C_LOC
        IMPLICIT NONE
        TYPE(C_PTR), INTENT(IN) :: L1
        INTEGER, INTENT(IN) :: numArg2
        INTEGER, INTENT(INOUT) :: l3
        CHARACTER(*), INTENT(INOUT) :: fstr
        INTEGER(KIND=C_SIZE_T), TARGET :: ls
        TYPE(C_PTR) :: cstr
        TYPE(C_PTR) :: p

        p = C_LOC(ls)
        cstr = luaL_checklstring(L1, INT(numArg2, C_INT), p)
        l3 = INT(ls, KIND(l3))
        CALL C_F_STRL(cstr, fstr, l3)
    END SUBROUTINE luaL_checklstring_f

!extern const char *(luaL_optlstring) (lua_State *L, int numArg,
!                                          const char *def, size_t *l)
    SUBROUTINE luaL_optlstring_f(L1, numArg2, def3, l4, fstr)
        USE, INTRINSIC :: ISO_C_BINDING, ONLY: C_PTR, C_INT, C_SIZE_T, C_LOC
        IMPLICIT NONE
        TYPE(C_PTR), INTENT(IN) :: L1
        INTEGER, INTENT(IN) :: numArg2
        CHARACTER(*), INTENT(IN) :: def3
        INTEGER, INTENT(INOUT) :: l4
        CHARACTER(*), INTENT(INOUT) :: fstr
        INTEGER(KIND=C_SIZE_T), TARGET :: ls
        TYPE(C_PTR) :: cstr
        TYPE(C_PTR) :: p

        p = C_LOC(ls)
        cstr = luaL_optlstring(L1, INT(numArg2, C_INT), &
            & F_C_STRT(def3), p)
        l4 = INT(ls, KIND(l4))
        CALL C_F_STRL(cstr, fstr, l4)
    END SUBROUTINE luaL_optlstring_f

!extern const char *(luaL_gsub) (lua_State *L, const char *s, const char *p,
!                                                  const char *r)
    SUBROUTINE luaL_gsub_f(L1, s2, p3, r4, fstr)
        USE, INTRINSIC :: ISO_C_BINDING, ONLY: C_PTR
        IMPLICIT NONE
        TYPE(C_PTR), INTENT(IN) :: L1
        CHARACTER(*), INTENT(IN) :: s2, p3, r4
        CHARACTER(*), INTENT(INOUT) :: fstr
        TYPE(C_PTR) :: cstr

        cstr = luaL_gsub(L1, F_C_STRT(s2), F_C_STRT(p3), F_C_STRT(r4))
        CALL C_F_STR(cstr, fstr)
    END SUBROUTINE luaL_gsub_f

!extern void (luaL_addstring) (luaL_Buffer *B, const char *s)
! Since we always know string length, this wrapper calls luaL_addlstring
    SUBROUTINE luaL_addstring_f(B, s)
        USE, INTRINSIC :: ISO_C_BINDING, ONLY: C_PTR, C_SIZE_T
        USE LUAF_TYPES, ONLY: luaL_Buffer
        IMPLICIT NONE
        TYPE(luaL_Buffer), INTENT(INOUT) :: B
        CHARACTER(*), INTENT(IN) :: s

        CALL luaL_addlstring(B, s, INT(LEN(s), C_SIZE_T))
    END SUBROUTINE luaL_addstring_f

!#define lua_tostring(L,i) lua_tolstring(L, (i), NULL)
    FUNCTION lua_tostring_f(L, idx, fstr) RESULT(r)
        USE, INTRINSIC :: ISO_C_BINDING, ONLY: C_PTR, C_INT, &
            & C_NULL_PTR, C_ASSOCIATED
        IMPLICIT NONE
        TYPE(C_PTR), INTENT(IN) :: L
        INTEGER, INTENT(IN) :: idx
        CHARACTER(*), INTENT(INOUT) :: fstr
        LOGICAL :: r
        TYPE(C_PTR) :: cstr

        cstr = lua_tolstring(L, INT(idx, C_INT), C_NULL_PTR)

        r = C_ASSOCIATED(cstr)
        IF (r) THEN
            CALL C_F_STR(cstr, fstr)
        END IF
    END FUNCTION lua_tostring_f

!#define luaL_checkstring(L,n) (luaL_checklstring(L, (n), NULL))
    SUBROUTINE luaL_checkstring_f(L, idx, fstr)
        USE, INTRINSIC :: ISO_C_BINDING, ONLY: C_PTR, C_INT, C_NULL_PTR
        IMPLICIT NONE
        TYPE(C_PTR), INTENT(IN) :: L
        INTEGER, INTENT(IN) :: idx
        CHARACTER(*), INTENT(INOUT) :: fstr
        TYPE(C_PTR) :: cstr

        cstr = luaL_checklstring(L, INT(idx, C_INT), C_NULL_PTR)
        CALL C_F_STR(cstr, fstr)
    END SUBROUTINE luaL_checkstring_f

!#define luaL_optstring(L,n,d) (luaL_optlstring(L, (n), (d), NULL))
    SUBROUTINE luaL_optstring_f(L, n, d, fstr)
        USE, INTRINSIC :: ISO_C_BINDING, ONLY: C_PTR, C_INT, C_NULL_PTR
        IMPLICIT NONE
        TYPE(C_PTR), INTENT(IN) :: L
        INTEGER, INTENT(IN) :: n
        CHARACTER(*), INTENT(IN) :: d
        CHARACTER(*), INTENT(INOUT) :: fstr
        TYPE(C_PTR) :: cstr

        cstr = luaL_optlstring(L, INT(n, C_INT), &
            & F_C_STRT(d), C_NULL_PTR)
        CALL C_F_STR(cstr, fstr)
    END SUBROUTINE luaL_optstring_f

!#define luaL_typename(L,i) lua_typename(L, lua_type(L,(i)))
    SUBROUTINE luaL_typename_f(L, i, fstr)
        USE, INTRINSIC :: ISO_C_BINDING, ONLY: C_PTR, C_INT
        IMPLICIT NONE
        TYPE(C_PTR), INTENT(IN) :: L
        INTEGER, INTENT(IN) :: i
        CHARACTER(*), INTENT(INOUT) :: fstr
        TYPE(C_PTR) :: cstr

        cstr = lua_typename(L, lua_type(L, INT(i, C_INT)))
        CALL C_F_STR(cstr, fstr)
    END SUBROUTINE luaL_typename_f
    
END MODULE LUAF
