#------------------------------------------------------------------------------
# Solar System Modeling
#                                                                     by LiHuan
#------------------------------------------------------------------------------

module c

BodyTotal=13
BeginTime=2451545
dt=1                     # day
StepTotal=365
Day=24*60*60
AU=149597870700          # m
EarthMass=5.97237e24     # kg
# G=6.67408e-11 (s-2.m3.kg-1)
G=6.67408e-11*(1/const.Day)^-2*(1/const.AU)^3*(1/const.EarthMass)^-1

end # module c

#------------------------------------------------------------------------------

mutable struct Body
  name    ::String
  mass    ::Float64
  radius  ::Float64
  x       ::Array{Float64,1}
  v       ::Array{Float64,1}
end



mutable struct Step
  time    ::Float64
  bodys   ::Array{Body,1}
end



import Base.*

function *(c1::Number,step1::Step)
  step2=step1
  step2.time=c1*step1.time
  for i in 1:c.BodyTotal
    step2.bodys[i].x=c1*step1.bodys[i].x
    step2.bodys[i].v=c1*step1.bodys[i].v
  end
  step2
end



function *(step1::Step,c1::Number)
  *(c1,step1)
end



import Base.+

function +(step1::Step,step2::Step)
  step3=step1
  step3.time=step1.time+step2.time
  for i in 1:c.BodyTotal
    step3.bodys[i].x=step1.bodys[i].x+step2.bodys[i].x
    step3.bodys[i].v=step1.bodys[i].v+step2.bodys[i].v
  end
  step3
end

#------------------------------------------------------------------------------

module gravity

function by1(test::Body, source::Body)
  dx=source.x-test.x
  force=c.G*test.mass*source.mass /sqrt(sum(dx.^2))^3 *dx
end



function byAll(numOftest::Int, theStep::Step)
  force=[0,0,0.]
  for i in 1:c.BodyTotal
    if i==numOftest continue end     # escape itself
    force=force + by1(theStep.bodys[numOftest], theStep.bodys[i])
  end
  force
end

end # module gravity

#------------------------------------------------------------------------------

function stepMultiplyConstant(input::Step, c::Float64)
  output =input
  output.time =output.time *c
  for i in 1:BodyTotal
    output.body[i].x =output.body[i].x *c
    output.body[i].v =output.body[i].v *c
  end
  output
end



function stepPlusStep(step1::Step, step2::Step)
  output =step1
  output.time =step1.time+step2.time
  for i in 1:BodyTotal
    output.body[i].x =step1.body[i].x+step2.body[i].x
    output.body[i].v =step1.body[i].v+step2.body[i].v
  end
  output
end

#------------------------------------------------------------------------------

# dstep=fdt(step,dt)
function fdt(input::Step, dt::Float64)
  dstep =input
  dstep.time =dt
  for i in 1:BodyTotal
    dstep.body[i].x =input.body[i].v *dt
    dstep.body[i].v =gravitybyAll(i,input)/input.body[i].mass *dt
  end
  dstep
end



function rk4(currentStep::Step, dt::Float64)
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

