-------------------------------------------------------------------------------
-- Solar System Modeling
-------------------------------------------------------------------------------

local pl={}
pl.deepcopy=require('mod.pl.tablex').deepcopy
pl.run=     require('mod.pl.comprehension').new() -- run a string as code
local ftcsv=require('mod.ftcsv')
local M=    require('mod.moses')
local gp=   require('mod.gnuplot')
require('Cgravity')
require('CDE430')
deepcopy=pl.deepcopy

-------------------------------------------------------------------------------

const={}

const.BodyTotal=11
const.BeginTime=2440400.5      -- 1969.06.28
const.dt=1                     -- day
const.StepTotal=2000
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
for i=1,const.BodyTotal do 
  table.insert( Step.proto.body, { name='',
                                   mass=0,
                                   x=setmetatable({0,0,0},Vector),
                                   v=setmetatable({0,0,0},Vector)  })
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

gravity={}

gravity.by1_Lua=function(testmass,source)
  local dx=setmetatable(testmass.x,Vector)-source.x
  return -const.G*testmass.mass*source.mass/(dx:MOD()^3)*dx -- return Vector
end 



gravity.by1_C=function(test,source)
  local force=setmetatable({},Vector)
  force[1],force[2],force[3]
  =
  Cgravity.Call_gravity_Newton_by1(const.G,
                                   test.mass,test.x,
                                   source.mass,source.x)
  return force
end



gravity.by1=gravity.by1_Lua



-- call gravity.by1() from above
gravity.byall_1=function(testmassNum,step)
  local force=setmetatable({0,0,0},Vector)
  for i=1,#step.body do
    while true do
      -- change the line below at your will
      if (i==testmassNum) then break end
      local force1=gravity.by1(step.body[testmassNum],step.body[i])
      force=force+force1
      break
    end
  end
  return force
end



-- call gravity_Newton_byall() from C code
gravity.byall_2=function(testnum,step)
  local force=setmetatable({0,0,0},Vector)
  force[1],force[2],force[3]
  =
  Cgravity.Call_gravity_Newton_byall(step,testnum,const.G)
  return force
end



gravity.byall=gravity.byall_1

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



rk.rk4=function(step,dt)
  k1=rk.dstep(step,dt)
  k2=rk.dstep(step+0.5*k1,dt)
  k3=rk.dstep(step+0.5*k2,dt)
  k4=rk.dstep(step+k3,dt)
  return step+1/6*(k1+2*k2+2*k3+k4)
end

-------------------------------------------------------------------------------
-- manipulate CSV files

CSV={}

CSV.SaveTable=function(thetable,filename)
  io.output(filename)
  for i=1,#thetable do
    io.write(table.concat(thetable[i],','))
    io.write('\n')
  end
  io.close()
end



CSV.Savestep=function(step,bodylist,filename)
  local tmp={}

  -- the CSV head
  tmp[1]={'time'}
  for _,i in pairs(bodylist) do
    M.push(tmp[1],i..'name',
                  i..'mass',
                  i..'radius',
                  i..'x',i..'y',i..'z',
                  i..'vx',i..'vy',i..'vz')
  end

  for i=1,const.StepTotal do
    tmp[1+i]={}
    M.push(tmp[1+i],step[i].time)
    for _,j in pairs(bodylist) do
      M.push(tmp[1+i],step[i].body[j].name,
                      step[i].body[j].mass,
                      step[i].body[j].radius,
                      step[i].body[j].x[1],
                      step[i].body[j].x[2],
                      step[i].body[j].x[3],
                      step[i].body[j].v[1],
                      step[i].body[j].v[2],
                      step[i].body[j].v[3]   )
    end
  end

  CSV.SaveTable(tmp,filename)
end

-------------------------------------------------------------------------------
-- generate the steps

step={}

-- initialize the first step
step[1]=setmetatable(deepcopy(Step.proto),Step)

step[1].time=const.BeginTime

bodydata,_=ftcsv.parse('data/body.csv',',')
for i=1,const.BodyTotal do
  step[1].body[i].name  =bodydata[i]['name']
  step[1].body[i].mass  =bodydata[i]['mass(kg)']/const.EarthMass
  step[1].body[i].radius=bodydata[i]['radius(m)']/const.AU
end

-- CDE430.readstate(juliandate,planet,center)
for i=1,const.BodyTotal do
  step[1].body[i].x[1],
  step[1].body[i].x[2],
  step[1].body[i].x[3],
  step[1].body[i].v[1],
  step[1].body[i].v[2],
  step[1].body[i].v[3]
  =
  CDE430.readstate(const.BeginTime,i,12) -- x[],v[] relative to the SSB
end



-- use Runge-Kutta method to generate all steps
for i=2,const.StepTotal do
  step[i]=rk.rk4(step[i-1],const.dt)
end



-- call gnuplot to plot step[]
do
  local x11=pl.run'step[i].body[11].x[1] for i=1,const.StepTotal'()
  local y11=pl.run'step[i].body[11].x[2] for i=1,const.StepTotal'()
  local z11=pl.run'step[i].body[11].x[3] for i=1,const.StepTotal'()

  local x3=pl.run'step[i].body[3].x[1] for i=1,const.StepTotal'()
  local y3=pl.run'step[i].body[3].x[2] for i=1,const.StepTotal'()
  local z3=pl.run'step[i].body[3].x[3] for i=1,const.StepTotal'()

  gp{
    width=800,height=600,xlabel='x',ylabel='y',zlabel='z',key='top left',
    data={
      gp.array{{x11,y11,z11},title='Sun',using={1,2,3},with='linespoints'},
      gp.array{{x3,y3,z3},title='Earth',using={1,2,3},with='dots'}
    }
  }:splot('data/step.svg')
end



CSV.Savestep(step,M.range(const.BodyTotal),'data/step.csv')

-------------------------------------------------------------------------------
-- data from DE430

stepDE={}

for j=1,const.StepTotal do
  stepDE[j]=setmetatable(deepcopy(Step.proto),Step)
  stepDE[j].time=const.BeginTime+(j-1)*const.dt

  for i=1,const.BodyTotal do
    stepDE[j].body[i].name  =bodydata[i]['name']
    stepDE[j].body[i].mass  =bodydata[i]['mass(kg)']/const.EarthMass
    stepDE[j].body[i].radius=bodydata[i]['radius(m)']/const.AU
  end

  for i=1,const.BodyTotal do
    stepDE[j].body[i].x[1],
    stepDE[j].body[i].x[2],
    stepDE[j].body[i].x[3],
    stepDE[j].body[i].v[1],
    stepDE[j].body[i].v[2],
    stepDE[j].body[i].v[3]
    =
    CDE430.readstate(stepDE[j].time,i,12)
  end
end

CSV.Savestep(stepDE,M.range(const.BodyTotal),'data/stepDE.csv')

-------------------------------------------------------------------------------
-- dstep

dxyz=function(bodynum,filename)
  local tmp={}
  -- the head of CSV file
  tmp[1]={bodynum..'dx',bodynum..'dy',bodynum..'dz'}
  for i=1,const.StepTotal do
    M.push(tmp,step[i].body[bodynum].x-stepDE[i].body[bodynum].x)
  end

  CSV.SaveTable(tmp,filename)
end

dxyz(3,'data/dxyz.csv')



-- plot dx
do
  local x1=M.range(const.StepTotal)
pl.run[[step[i].body[3].x[1]-stepDE[i].body[3].x[1]]]
  dx_SSM_DE=function(i) return step[i].body[3].x[1]-stepDE[i].body[3].x[1] end
  local gp_y=M.map(M.range(const.StepTotal),dx_SSM_DE)

  gp{
    width=800,height=600,xlabel='t',ylabel='dx',key='top left',
    data={
      gp.array{{gp_x,gp_y},title='dx_SSM_DE',using={1,2},with='lines'}
    }
  }:plot('data/dstep.svg')
end

-------------------------------------------------------------------------------
-- try

--for i=1,10 do
  --local ff={}
  --ff[1],ff[2],ff[3]
  --=
  --Cgravity.Call_gravity_Newton_byall(step[i],1,const.G)

  --local f1=gravity.byall(1,step[i])

  ----print(f1[1],f1[2],f1[3])
  --print(f1[1]-ff[1],f1[2]-ff[2],f1[3]-ff[3])
  --print("\n")
--end



--ftry={}
--ftry[1],ftry[2],ftry[3]
--=Cgravity.Call_gravity_Newton_by1(const.G,
                                  --step[1].body[3].mass,step[1].body[3].x,
                                  --step[1].body[11].mass,step[1].body[11].x)
--print(ftry[1],ftry[2],ftry[3])

--Cgravity.Call_gravity_Newton_byall(step[1],3,const.G)
--
M.each(gravity.byall(3,step[9]),print)
