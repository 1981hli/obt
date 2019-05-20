#------------------------------------------------------------------------------
# Solar System Modeling
#                                                                     by LiHuan
#------------------------------------------------------------------------------

using LinearAlgebra
using CSV

#------------------------------------------------------------------------------

module C

TotalBody=2
TotalStep=365
StartTime=2440400.5
Day=24*60*60
dt=1
AU=149597870700
EarthMass=5.97237e24
G=6.67408e-11*(1/Day)^-2*(1/AU)^3*(1/EarthMass)^-1
c=3

end

#------------------------------------------------------------------------------

mutable struct Body
  name    ::String
  mass    ::Float64
  x       ::Array{Float64,1}
  v       ::Array{Float64,1}
end



mutable struct Step
  time    ::Float64
  body    ::Array{Body,1}
end



import Base.+

+(step1::Step,step2::Step)=function(step1::Step,step2::Step)
  output=step1
  output.time =step1.time+step2.time
  for i in 1:C.TotalBody
    output.body[i].x=step1.body[i].x+step2.body[i].x
    output.body[i].v=step1.body[i].v+step2.body[i].v
  end
  output
end



import Base.*

*(c::Real,step::Step)=function(c::Real,step::Step)
  output=step
  output.time=c*step.time
  for i in 1:C.TotalBody
    output.body[i].x=c*output.body[i].x
    output.body[i].v=c*output.body[i].v
  end
  output
end



tmp1=[]
append!(tmp1,C.StartTime)
append!(tmp1,[])


#------------------------------------------------------------------------------

function forceNewtonby1(test::Body,source::Body)
  dx=source.x-test.x
  force=C.G*test.mass*source.mass/sqrt(sum(dx.^2))^3*dx
end



function forceNewtonbyall(step::Step,testnum::Int)
  force=[0.,0.,0.]
  for i in 1:C.TotalBody
    if i==testnum continue end
    force=force+forceNewtonby1(step.body[testnum],step.body[i])
  end
  force
end



function forcePPN(step::Step,A::Int)
  m(i::Int)=step.body[i].mass
  x(i::Int)=step.body[i].x
  v(i::Int)=step.body[i].v
  a(i::Int)=1/m(i)*forceNewtonbyall(step,i) # to be accelerated

  r(A::Int,B::Int)=x(B)-x(A)
  v(A::Int,B::Int)=v(B)-v(A)
  norm_r(A::Int,B::Int)=norm(r(A,B))
  norm_v(A::Int,B::Int)=norm(v(A,B))
    
  function forcePPNby1(step::Step,A::Int,B::Int)
    T1 =C.G*m(B)*r(A,B)/norm_r(B,A)^3
    T2 =-2*(beta+gamma)/C.c^2*
        sum( C.G*m(i)/norm_r(A,i) for i=[1:C.TotalBody;] if i!=A )
    T3 =-(2*beta-1)/C.c^2*
        sum( C.G*m(i)/norm_r(B,i) for i=[1:C.TotalBody;] if i!=B )
    T4 =gamma*(v(A)/C.c)^2
    T5 =(1+gamma)*(v(B)/C.c)^2
    T6 =-2(1+gamma)/C.c^2*dot(v(A),v(B))
    T7 =-3/(2*C.c^2)*(dot(r(B,A),v(B))/norm_r(A,B))^2
    T8 =1/(2*C.c^2)*dot(r(A,B),a(B))
    T9 =1/C.c^2*C.G*m(B)/norm_r(A,B)^3*
        dot(r(B,A),(2+2*gamma)*v(A)-(1+2*gamma)*v(B))*v(B,A)
    T10=(3+4*gamma)/(2*C.c^2)*C.G*m(B)/r(A,B)*a(B)
    acceleration=T1*(1+T2+T3+T4+T5+T6+T7+T8)+T9+T10
  end

  sum(forcePPNby1(step,A,B) for B=[1:C.TotalBody;] if B!=A)
end

#------------------------------------------------------------------------------

function dstep(thestep::Step,dt::Float64)
  tmp=thestep
  tmp.time=dt
  for i in 1:C.TotalBody
    force=gravity.Newton_byall(i,thestep)
    tmp.body[i].x=thestep.body[i].v*dt
    tmp.body[i].v=1/thestep.body[i].mass*force*dt
  end
  tmp
end



function rk4(thestep::Step,dt::Float64)
  # k1=f(t,y)dt
  k1 =fdt(currentStep,dt)

  # k2=f(t+dt/2,y+k1/2)dt
  k2 =fdt()

  # k3=f(t+dt/2,y+k2/2)dt
  k3

  # k4=f(t+dt,y+k3)dt
  k4

  # dy=(k1+2k2+2k3+k4)/6
end

