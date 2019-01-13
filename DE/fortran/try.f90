program try

  implicit none

  real(8)               :: JuliaDate
  integer               :: Planet,Centre
  real(8),dimension(6)  :: StateVector

  JuliaDate = 2439000
  Planet    = 3
  Centre    = 11

  call pleph(JuliaDate,Planet,Centre,StateVector)

  write(*,*) "The state vector is:"
  write(*,*) StateVector
  write(*,*) StateVector*1.5e11

end program try
