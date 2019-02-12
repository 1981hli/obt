program read
  implicit none
  real(8)               :: JuliaDate
  integer               :: Planet,Centre,TotalBody,i
  real(8),dimension(6)  :: StateVector
  JuliaDate =2451545
  !JuliaDate = 2440400.5
  TotalBody =13
  Centre    =12
  open(100,file="../data/initdata.csv")
  write(100,*) 'x1',',','x2',',','x3',',','v1',',','v2',',','v3'
  do i=1,TotalBody
    Planet=i
    call pleph(JuliaDate,Planet,Centre,StateVector)
    write(100,*) StateVector(1),',',StateVector(2),',',StateVector(3),',',&
                 StateVector(4),',',StateVector(5),',',StateVector(6)
    !write(*,*) "time="
    !write(*,*) JuliaDate
    !write(*,*) "position="
    !write(*,*) StateVector(1:3)
    !write(*,*) "velocity="
    !write(*,*) StateVector(4:6)
  end do
  close(100)
end program
