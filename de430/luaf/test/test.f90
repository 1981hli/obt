module ltest
contains
    function lsub(L) bind(C) result(r)
        use, intrinsic :: iso_c_binding, only: c_int, c_ptr
        use :: LuaF
        implicit none
        type(c_ptr), value, intent(in) :: L
        integer(c_int) :: r
        character(10) :: buf
        integer :: ls
        logical :: lr
        
        lr = lua_tolstring_f(L, -1, ls, buf)
        print 10, lr, ls, buf
10      format (L,X,I2,X,'<',A,'>')

        call lua_pop(L, 1)
        r = 0

    end function lsub

    function lmain(L) bind(C) result(r)
        use, intrinsic :: iso_c_binding, only: c_int, c_ptr, &
            &c_f_pointer, c_size_t
        use :: LuaF
        use :: luaFE
        implicit none
        type(c_ptr), value, intent(in) :: L
        integer(c_int) :: r
        character(80) :: buf
        character(len=1), pointer, dimension(:) :: b2
        type(luaL_Buffer) :: lbuf
        integer :: i
        type(c_ptr) :: ptr
        logical :: lr

        ! Play with stack
        print *, 'Stack top is: ', lua_gettop(L)
        call luaL_typename_f(L, -1, buf)
        print *, 'Type is: ', trim(buf)
        call lua_pop(L, 1)
        print *, 'Stack top after pop is : ', lua_gettop(L)

        call luaL_openlibs(L)

        call lua_getglobal(L, F_C_STR('_VERSION'))
        call lua_pushstring_f(L, 'Lua version is: ')
        call lua_insert(L, -2)
        call lua_concat(L, 2)
        call lua_getglobal(L, F_C_STR('print'))
        call lua_insert(L, -2)
        call lua_call(L, 1, 0)
        print *, 'Stack top is: ', lua_gettop(L)

        ! Do something w/buffer
        call luaL_buffinit(L, lbuf)
        do i = 1, 9000
            call luaL_addchar(lbuf, char(mod(i,10)+48))
        enddo
        call luaL_addstring_f(lbuf, 'ejapo')
        call luaL_addlstring(lbuf, '1234567890', 5_C_SIZE_T)
        
        ptr = luaL_prepbuffer(lbuf)
        call c_f_pointer(ptr, b2, [100])
        do i = 1, 100
            b2(i) = char(mod(i,10)+65)
        enddo
        call luaL_addsize(lbuf, 100)
        call luaL_addstring_f(lbuf, '|')
        print *, 'Stack top is: ', lua_gettop(L)
        call luaL_pushresult(lbuf)
        call lua_getglobal(L, F_C_STR('print'))
        call lua_insert(L, -2)
        call lua_call(L, 1, 0)
        print *, 'Stack top is: ', lua_gettop(L)

        call lua_newtable(L)
        call luaFE_register(L, 'mysub', lsub)

        call lua_setglobal(L, F_C_STR('tab'))
        print *, 'Stack top is: ', lua_gettop(L)

        i = luaL_dostring(L, F_C_STR("tab.mysub('abcdefghijXA')"))

        print *, 'dostring returned: ', i
        print *, 'Stack top is: ', lua_gettop(L)

        if (i /= 0) then
            lr = lua_tostring_f(L, -1, buf)
            print *, 'tostring returned: ', lr
            if (lr) print *, trim(buf)
            call lua_pop(L, 1)
        end if
        print *, 'Stack top is: ', lua_gettop(L)

        r = 0

    end function lmain
end module ltest

program main
    use, intrinsic :: iso_c_binding, only: c_ptr, c_null_ptr, c_associated, c_funloc
    use :: LuaF
    use :: ltest
    implicit none

    type(c_ptr) :: L
    integer ::r
    character(100) :: buf
    logical :: lr

    ! Opening Lua
    L = luaL_newstate()

    if (c_associated(L)) then
        print *,'Lua initialized ok.'
    end if

!   call luaL_openlibs(L)
    ! Protected call of code
    r = lua_cpcall(L, C_FUNLOC(lmain), C_NULL_PTR)
    print *,'Error code is: ', r
    if (r /= 0) then
        lr = lua_tostring_f(L, -1, buf)
        print *, 'tostring returned: ', lr
        print *, trim(buf)
        call lua_pop(L, 1)
    end if

    call lua_close(L)

end program main


