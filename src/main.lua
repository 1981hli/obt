-------------------------------------------------------------------------------
-- Solar System Modeling
--                                                                    by LiHuan
-------------------------------------------------------------------------------

local pl=require 'pl.import_into'()
local deepcopy=pl.tablex.deepcopy
local ftcsv=require 'ftcsv'
require 'cmod'

-------------------------------------------------------------------------------

const={}

const.BodyTotal=13
const.BeginTime=2451545        -- Julian date at 2000.01.01
const.dt=1                     -- day
const.StepTotal=365
const.Day=24*60*60             -- s
const.AU=149597870700          -- m
const.EarthMass=5.97237e24     -- kg
-- G=6.67408e-11 (s-2.m3.kg-1)
const.G=6.67408e-11*(1/const.Day)^-2*(1/const.AU)^3*(1/const.EarthMass)^-1

-------------------------------------------------------------------------------

Vector={}
Vector.__index=Vector

Vector.MOD=function(self)
  local sqrt=math.sqrt
  local tmp=0
  for i=1,#self do
    tmp=tmp+self[i]^2
  end
  return sqrt(tmp)
end



Vector.__add=function(arg1,arg2)
  local output=setmetatable({},Vector)

  if(type(arg1)=='number' and type(arg2)=='table') then
    for i=1,#arg2 do output[i]=arg1+arg2[i] end

  elseif(type(arg1)=='table' and type(arg2)=='number') then
    for i=1,#arg1 do output[i]=arg1[i]+arg2 end
    
  elseif(type(arg1)=='table' and type(arg2)=='table') then
    for i=1,#arg1 do output[i]=arg1[i]+arg2[i] end

  end

  return output
end



Vector.__sub=function(arg1,arg2)
  local output=setmetatable({},Vector)
  for i=1,#arg1 do output[i]=arg1[i]-arg2[i] end
  return output
end



Vector.__mul=function(arg1,arg2)
  local output=setmetatable({},Vector)

  if(type(arg1)=='number' and type(arg2)=='table') then
    for i=1,#arg2 do output[i]=arg1*arg2[i] end

  elseif(type(arg1)=='table' and type(arg2)=='number') then
    for i=1,#arg1 do output[i]=arg1[i]*arg2 end

  end
  return output
end

-------------------------------------------------------------------------------

Step={}
Step.__index=Step

Step.proto={}
Step.proto.time=0
Step.proto.body={}
for i=1,const.BodyTotal do table.insert( Step.proto.body,
                                         {name='',
                                          mass=0,
                                          x=setmetatable({0,0,0},Vector),
                                          v=setmetatable({0,0,0},Vector)} )
end



Step.__add=function(step1,step2)
  local tmp=deepcopy(step1)
  tmp.time=step1.time+step2.time

  for i=1,#tmp.body do
    tmp.body[i].x= step1.body[i].x+step2.body[i].x
    tmp.body[i].v= step1.body[i].v+step2.body[i].v
  end

  return tmp
end



Step.__mul=function(arg1,arg2)
  if(type(arg1)=='number' and type(arg2)=='table') then
    c=arg1
    step1=arg2
  elseif(type(arg1)=='table' and type(arg2)=='number') then
    c=arg2
    step1=arg1
  end

  local tmp=deepcopy(step1)
  tmp.time=c*step1.time
  for i=1,#tmp.body do        
    tmp.body[i].x=c*step1.body[i].x
    tmp.body[i].v=c*step1.body[i].v
  end

  return tmp
end

-------------------------------------------------------------------------------
-- initialize the first step

steps={}

steps[1]=setmetatable(deepcopy(Step.proto),Step)

steps[1].time=const.BeginTime

data,head=ftcsv.parse('../data/body.csv',',')
for i=1,const.BodyTotal do
  steps[1].body[i].name  =data[i]['name']
  steps[1].body[i].mass  =data[i]['mass(kg)']/const.EarthMass
  steps[1].body[i].radius=data[i]['radius(m)']/const.AU
end

data,head=ftcsv.parse('../data/init.csv',',')
for i=1,const.BodyTotal do
  steps[1].body[i].x[1] =data[i]['x1']
  steps[1].body[i].x[2] =data[i]['x2']
  steps[1].body[i].x[3] =data[i]['x3']
  steps[1].body[i].v[1] =data[i]['v1']
  steps[1].body[i].v[2] =data[i]['v2']
  steps[1].body[i].v[3] =data[i]['v3']
end

-------------------------------------------------------------------------------

gravity={}

-- @return Vector
gravity.by1_Lua=function(testmass,source)
  local dx=setmetatable(testmass.x,Vector)-source.x
  return -const.G*testmass.mass*source.mass/(dx:MOD()^3)*dx
end 



-- alternate C module
gravity.by1_C=function(test,source)
  local force=setmetatable({},Vector)
  force[1],force[2],force[3]=cmod.gravityby1(const.G,
                                             test.mass,test.x,
                                             source.mass,source.x)
  return force
end



gravity.by1=gravity.by1_C



-- @int testmassNum
gravity.byall=function(testmassNum,step)
  local force=setmetatable({0,0,0},Vector)
  for i=1,#step.body do
    while true do
      -- change the line below at your will
      if (i==testmassNum or i==3 or i==10 or i==12) then break end
      local force1=gravity.by1(step.body[testmassNum],step.body[i])
      force=force+force1
      break
    end
  end
  return force
end

-------------------------------------------------------------------------------
-- Runge-Kutta method

rk={}

-- calculate dstep from the differential equation
rk.dstep=function(step,dt)
  local tmp=deepcopy(step)
  tmp.time=dt
  for i=1,#step.body do
    local force=gravity.byall(i,step)
    tmp.body[i].x=step.body[i].v*dt 
    tmp.body[i].v=1/step.body[i].mass*force*dt
  end
  return tmp
end



-- @para Step step
rk.rk4=function(step,dt)
  k1=rk.dstep(step,dt)
  k2=rk.dstep(step+0.5*k1,dt)
  k3=rk.dstep(step+0.5*k2,dt)
  k4=rk.dstep(step+k3,dt)
  return step+1/6*(k1+2*k2+2*k3+k4)
end



-- use Runge-Kutta method to generate all steps
for i=2,const.StepTotal do
  steps[i]=rk.rk4(steps[i-1],const.dt)
end

-------------------------------------------------------------------------------

io.output('../data/output.csv')

-- time,body1x1,body1x2,body1x3,body1v1,body1v2,body1v3,body2x1,body2x2,...
local head="time"
for i=1,const.BodyTotal do
  head=head..",".."body"..i.."x1"..","
                .."body"..i.."x2"..","
                .."body"..i.."x3"..","
                .."body"..i.."v1"..","
                .."body"..i.."v2"..","
                .."body"..i.."v3"
end
head=head.."\n"
io.write(head)

for j=1,const.StepTotal do
  io.write(steps[j].time)
  for i=1,const.BodyTotal do
    io.write(",")
    io.write(steps[j].body[i].x[1])
    io.write(",")
    io.write(steps[j].body[i].x[2])
    io.write(",")
    io.write(steps[j].body[i].x[3])
    io.write(",")
    io.write(steps[j].body[i].v[1])
    io.write(",")
    io.write(steps[j].body[i].v[2])
    io.write(",")
    io.write(steps[j].body[i].v[3])
  end
  io.write("\n")
end

io.close()

