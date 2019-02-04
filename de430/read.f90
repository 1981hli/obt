program read

  implicit none

  real(8)               :: JuliaDate
  integer               :: Planet,Centre
  real(8),dimension(6)  :: StateVector

  !JuliaDate = 2451545
  JuliaDate = 2440400.5
  Planet    = 1
  Centre    = 11

  call pleph(JuliaDate,Planet,Centre,StateVector)

  write(*,*) "time="
  write(*,*) JuliaDate
  write(*,*) "position="
  write(*,*) StateVector(1:3)
  write(*,*) "velocity="
  write(*,*) StateVector(4:6)

  open(1,file="outputde.csv")
  write(1,*) StateVector(1),',',StateVector(2),',',StateVector(3),',',&
             StateVector(4),',',StateVector(5),',',StateVector(6)
  close(1)

end program
