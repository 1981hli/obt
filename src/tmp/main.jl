#------------------------------------------------------------------------------
# Solar System Modeling
#                                                                     by LiHuan
#------------------------------------------------------------------------------

totalBody       =2
totalStep       =365
dtBetweenSteps  =1.
gravityG        =6.67e-11

#------------------------------------------------------------------------------

mutable struct Body
  name    ::String
  mass    ::AbstractFloat
  radius  ::AbstractFloat
  x       ::Array{AbstractFloat,1}
  v       ::Array{AbstractFloat,1}
end



mutable struct Step
  time    ::AbstractFloat
  body    ::Array{Body,1}
end



step1 =Step(
  0.,
  [
    Body("Sun",  1.,1.,[0.,  0.,0.],[0.,0., 0.]),
    Body("Earth",1.,1.,[100.,0.,0.],[0.,10.,0.])
  ]
)

#------------------------------------------------------------------------------

function gravityby1(testMass::Body, source::Body)
  dx =source.x-testMass.x
  force =gravityG*testMass.mass*source.mass /sqrt(sum(dx.^2))^3 *dx
end



function gravitybyAll(testMassNumber::Int, currentStep::Step)
  force=[0.,0.,0.]
  for i in 1:totalBody
    if i==testMassNumber continue end
    force =force+
           gravityby1(currentStep.body[testMassNumber], currentStep.body[i])
  end
  force
end

#------------------------------------------------------------------------------

function stepMultiplyConstant(input::Step, c::AbstractFloat)
  output =input
  output.time =output.time *c
  for i in 1:totalBody
    output.body[i].x =output.body[i].x *c
    output.body[i].v =output.body[i].v *c
  end
  output
end



function stepPlusStep(step1::Step, step2::Step)
  output =step1
  output.time =step1.time+step2.time
  for i in 1:totalBody
    output.body[i].x =step1.body[i].x+step2.body[i].x
    output.body[i].v =step1.body[i].v+step2.body[i].v
  end
  output
end

#------------------------------------------------------------------------------

# dstep=fdt(step,dt)
function fdt(input::Step, dt::AbstractFloat)
  dstep =input
  dstep.time =dt
  for i in 1:totalBody
    dstep.body[i].x =input.body[i].v *dt
    dstep.body[i].v =gravitybyAll(i,input)/input.body[i].mass *dt
  end
  dstep
end



function rk4(currentStep::Step, dt::AbstractFloat)
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

