!------------------------------------------------------------------------------
! Solar System Modeling
!                                                                     by LiHuan
!------------------------------------------------------------------------------

module state
  implicit none

  integer,parameter :: TotalBody=13
  integer,parameter :: TotalStep=365

  type body
    character(len=20)   :: name
    real                :: mass
    real                :: radius
    real,dimension(3)   :: x
    real,dimension(3)   :: v
  end type



  type step
    real                                :: time
    type(body),dimension(TotalBody)     :: bodys
  end type



  interface assignment(=)
    module procedure clone
  end interface



  interface operator(+)
    module procedure add
  end interface



  interface operator(*)
    module procedure mul
  end interface


contains


  function add(body1,body2) result(body3)
    type(body),intent(in)   :: body1,body2
    type(body)              :: body3
    body3%name  =body1%name
    body3%mass  =body1%mass
    body3%radius=body1%radius
  end function


  
  function add(step1,step2) result(step3)
    type(step),intent(in)   :: step1,step2
    type(step)              :: step3
    step3%time=step1%time + step2%time
    do i=1,TotalBody
      step3%body[i]=step1%body[i] + step2%body[i]
    end do
  end function 

    

  subroutine mul
  end subroutine

end module

!------------------------------------------------------------------------------

program main
  implicit none
end program

