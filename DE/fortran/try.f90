program try

  implicit none

  real(8)               :: JuliaDate
  integer               :: Planet,Centre
  real(8),dimension(6)  :: StateVector

  call pleph(JuliaDate,Planet,Centre,StateVector)

  JuliaDate = 102488
  Planet    = 3
  Centre    = 11

  write(*,*) "The state vector is:"
  write(*,*) StateVector

end program try
