!------------------------------------------------------------------------------
! Solar System Modeling
!                                                                     by LiHuan
!------------------------------------------------------------------------------

module constants

implicit none

integer,parameter      :: BodyTotal=13
integer,parameter      :: StepTotal=365
integer,parameter      :: dt=1

end module constants

!------------------------------------------------------------------------------

module motion

use constants
implicit none

type Body
  character(len=20)               :: name
  real                            :: mass
  real                            :: radius
  real,dimension(3)               :: x
  real,dimension(3)               :: v
end type



type Step
  real                                :: time
  type(Body),dimension(StepTotal)     :: steps
end type Step

contains

type(Step) function StepAddStep(step1,step2)
  type(Step),intent(in)     :: step1,step2
end function

end module motion

!------------------------------------------------------------------------------

program main

use motion
implicit none

type(Body) :: pp
pp%name="hahaha"
pp%mass=100.2
pp%radius=192938.
pp%x=[1.0, 9.0, 100.02]
pp%v=[0.2, 2.94, 2999.0]

print *,pp%name

end program main

