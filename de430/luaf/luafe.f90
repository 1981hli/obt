MODULE LUAFE
    ! Fortran extensions to Lua API

    USE LUAF
    IMPLICIT NONE

CONTAINS

    SUBROUTINE luaFE_register(L, n, f)
        USE, INTRINSIC :: ISO_C_BINDING, ONLY: C_PTR, C_CHAR, C_FUNPTR, C_FUNLOC
        IMPLICIT NONE
        TYPE(C_PTR), INTENT(IN) :: L
        CHARACTER(LEN=*), INTENT(IN) :: n
        INTERFACE
            FUNCTION f(L) BIND(C)
                USE, INTRINSIC :: ISO_C_BINDING, ONLY: C_PTR, C_INT
                IMPLICIT NONE
                TYPE(C_PTR), VALUE, INTENT(IN) :: L
                INTEGER(KIND=C_INT) :: f
            END FUNCTION f
        END INTERFACE

        TYPE(C_FUNPTR) :: fptr
        
        fptr = C_FUNLOC(f)
        CALL lua_pushstring_f(L, n)
        CALL lua_pushcfunction(L, fptr)
        CALL lua_settable(L, -3)
    END SUBROUTINE luaFE_register

END MODULE LUAFE
    
