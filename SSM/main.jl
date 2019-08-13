#-------------------------------------------------------------------------------
#
# Solar System Modeling
#
#-------------------------------------------------------------------------------

using LinearAlgebra
using CSV
using GR

#-------------------------------------------------------------------------------

const Day_s=24*60*60
const AU_m=149597870700
const Earthmass_kg=5.97237e24
const s_Day=1/Day_s
const m_AU=1/AU_m
const kg_Earthmass=1/Earthmass_kg
const TotalBody=11
const TotalStep=365
const TimeInterval=1.
const BeginTime=2440400.5 # 1969.06.28
const c=299792458*m_AU*s_Day^-1
const G=6.67408e-11*s_Day^-2*m_AU^3*kg_Earthmass^-1 # G=6.67408e-11 (s-2 m3 kg-1)

#-------------------------------------------------------------------------------

mutable struct Body
  name    ::String
  mass    ::Float64
  radius  ::Float64
  x       ::Array{Float64,1}
  v       ::Array{Float64,1}
end





mutable struct Step
  time    ::Float64
  body    ::Array{Body,1}
end





# Step + Step
import Base.+
function +(step1::Step,step2::Step)
  output=deepcopy(step1)
  output.time =step1.time+step2.time
  for i in 1:TotalBody
    output.body[i].x=step1.body[i].x+step2.body[i].x
    output.body[i].v=step1.body[i].v+step2.body[i].v
  end
  output
end





# Constant * Step
import Base.*
function *(c::Real,step::Step)
  output=deepcopy(step)
  output.time=c*step.time
  for i in 1:TotalBody
    output.body[i].x=c*output.body[i].x
    output.body[i].v=c*output.body[i].v
  end
  output
end

#-------------------------------------------------------------------------------

function gravity_Newton(step::Step,testnum::Int)
  function gravity_Newton1(test::Body,source::Body)
    dx=source.x-test.x
    G*test.mass*source.mass/sqrt(sum(dx.^2))^3*dx # return the gravity
  end

  gravity=[0.,0.,0.]
  for i in 1:TotalBody
    if i==testnum continue end
    gravity=gravity+gravity_Newton1(step.body[testnum],step.body[i])
  end
  gravity
end





function gravity_PPN(step::Step,A::Int) # (27) in 196C
  beta=1.
  gamma=1.
  m(i::Int)=step.body[i].mass
  x(i::Int)=step.body[i].x
  v(i::Int)=step.body[i].v
  a(i::Int)=1/m(i)*gravity_Newton(step,i)

  r(A::Int,B::Int)=x(B)-x(A)
  v(A::Int,B::Int)=v(B)-v(A)
  norm_r(A::Int,B::Int)=norm(r(A,B))
  norm_v(A::Int,B::Int)=norm(v(A,B))
  norm_v(A::Int)=norm(v(A))
    
  function gravity_PPN1(step::Step,A::Int,B::Int)
    T1 =G*m(B)*r(A,B)/norm_r(B,A)^3
    T2 =-2*(beta+gamma)/c^2*sum( G*m(C)/norm_r(A,C) for C=1:TotalBody if C!=A )
    T3 =-(2*beta-1)/c^2*sum( G*m(C)/norm_r(B,C) for C=1:TotalBody if C!=B )
    T4 =gamma*(norm_v(A)/c)^2
    T5 =(1+gamma)*(norm_v(B)/c)^2
    T6 =-2(1+gamma)/c^2*dot(v(A),v(B))
    T7 =-3/(2*c^2)*(dot(r(B,A),v(B))/norm_r(A,B))^2
    T8 =1/(2*c^2)*dot(r(A,B),a(B))
    T9 =1/c^2*G*m(B)/norm_r(A,B)^3*dot(r(B,A),(2+2*gamma)*v(A)-(1+2*gamma)*v(B))*v(B,A)
    T10=(3+4*gamma)/(2*c^2)*G*m(B)/norm_r(A,B)*a(B)
    T1*(1+T2+T3+T4+T5+T6+T7+T8)+T9+T10 # acceleration without sum for B
  end
 
  # return the gravity itself, not the acceleration
  m(A)*sum(gravity_PPN1(step,A,B) for B=1:TotalBody if B!=A)
end





gravity=gravity_Newton

#-------------------------------------------------------------------------------

function rk_rk4(thestep::Step,dt::Float64)
  function rk_dstep(thestep::Step,dt::Float64)
    tmp=deepcopy(thestep)
    tmp.time=dt
    for i in 1:TotalBody
      tmp.body[i].x=thestep.body[i].v*dt # dx=v*dt
      tmp.body[i].v=1/thestep.body[i].mass*gravity(thestep,i)*dt # dv=a*dt
    end
    tmp
  end

  # k1=f(t,y)dt
  k1=rk_dstep(thestep,dt)
  # k2=f(t+dt/2,y+k1/2)dt
  k2=rk_dstep(thestep+0.5*k1,dt)
  # k3=f(t+dt/2,y+k2/2)dt
  k3=rk_dstep(thestep+0.5*k2,dt)
  # k4=f(t+dt,y+k3)dt
  k4=rk_dstep(thestep+k3,dt)
  # dy=(k1+2k2+2k3+k4)/6
  nextstep=thestep+1/6*(k1+2*k2+2*k3+k4)

  return nextstep
end

#-------------------------------------------------------------------------------

# construct the initial step
step1=Step(BeginTime,[])
bodycsv=CSV.read("body.csv")

for i in 1:TotalBody
  state=Vector{Cdouble}(undef,6)
  ccall((:readstate,"./jpleph.so"),Cvoid,
        (Cdouble,Cint,Cint,Ptr{Cdouble}),BeginTime,i,12,state) # 12 means SSB

  name=bodycsv[i,1]
  mass=bodycsv[i,2]*kg_Earthmass
  radius=bodycsv[i,3]*m_AU
  x=state[1:3]
  v=state[4:6] # What is the unit of velocity in JPL ephemeris?

  push!(step1.body,Body(name,mass,radius,x,v))
end





# construct stepDE reading from JPL ephemeris
stepDE=Step[]
push!(stepDE,step1)

for i in 2:TotalStep
  steptmp=deepcopy(step1)
  steptmp.time=stepDE[i-1].time+TimeInterval

  for j in 1:TotalBody
    state=Vector{Cdouble}(undef,6)
    ccall((:readstate,"./jpleph.so"),Cvoid,
          (Cdouble,Cint,Cint,Ptr{Cdouble}),steptmp.time,j,12,state) # 12 means SSB
    steptmp.body[j].x=state[1:3]
    steptmp.body[j].v=state[4:6]
  end

  push!(stepDE,steptmp)
end





# construct step using RK4
step=Step[]
push!(step,step1)

for i in 2:TotalStep
  push!(step,rk_rk4(step[i-1],TimeInterval))
end

#-------------------------------------------------------------------------------
# plot

# let
  # t=1:TotalStep
  # x=[step[i].body[3].x[1] for i=t]
  # y=[step[i].body[3].x[2] for i=t]
  # z=[step[i].body[3].x[3] for i=t]
  # xDE=[stepDE[i].body[3].x[1] for i=t]
  # yDE=[stepDE[i].body[3].x[2] for i=t]
  # zDE=[stepDE[i].body[3].x[3] for i=t]

  # xlabel("step / Day")
  # ylabel("x,y,z / AU")
  # plot(t,xDE)
  # savefig("out/txyz.svg")
# end

