!------------------------------------------------------------------------------
! Solar System Modeling
!                                                                     by LiHuan
!------------------------------------------------------------------------------

module motion 
  implicit none

  integer,parameter ::TotalBody=2



  type Body
    character,dimension(20) ::name
    real                    ::mass
    real                    ::radius
    real,dimension(3)       ::x
    real,dimension(3)       ::v
  end type



  type Step
    real                            ::time
    type(Body),dimension(TotalBody) ::body
  end type

contains

end module

!------------------------------------------------------------------------------

program main
  implicit none
end program

