--------------------------------------------------------------------------------
-- Solar System Modeling
--------------------------------------------------------------------------------

local ftcsv=           require 'Lua.mod.ftcsv'
local gp=              require 'Lua.mod.gnuplot'
local M=               require 'Lua.mod.moses'
local pltablex=        require 'Lua.mod.pl.tablex'
local plcomprehension= require 'Lua.mod.pl.comprehension'
local plList=          require 'Lua.mod.pl.List'
require 'mod.Cgravity'
require 'mod.CDE430'



printtable=function(thetable)
  if(type(thetable)~="table") then
    print(thetable)
  else 
    local function diveinto(printout,level)
      for k,v in pairs(printout) do
        if (type(v)=="table") then
          print(string.rep("   ",level-1).."["..k.."]"..":")
          diveinto(v,level+1)
        else
          print(string.rep("   ",level-1).."["..k.."]".."= "..v)
        end
      end
    end
    diveinto(thetable,1)
  end
end



-- shortcuts
local deepcopy=pltablex.deepcopy
local run=plcomprehension.new()
pll=plList
smt=setmetatable
pt=printtable

--------------------------------------------------------------------------------
-- constants

const={}

-- exchange of units
const.Day_s=24*60*60
const.AU_m=149597870700
const.Earthmass_kg=5.97237e24
const.s_Day=1/const.Day_s
const.m_AU=1/const.AU_m
const.kg_Earthmass=1/const.Earthmass_kg

-- system of units: Day,AU,Earthmass
const.TotalBody=11
const.TotalStep=365*5
const.dt=1
const.BeginTime=2440400.5 -- 1969.06.28
const.c=299792458*const.m_AU*(const.s_Day)^-1
-- G=6.67408e-11 (s-2 m3 kg-1)
const.G=6.67408e-11*(const.s_Day)^-2*(const.m_AU)^3*(const.kg_Earthmass)^-1

--------------------------------------------------------------------------------
-- type Vector

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

--------------------------------------------------------------------------------
-- type Step

Step={}

Step.__index=Step



Step.proto={}
Step.proto.time=0
Step.proto.body={}
for i=1,const.TotalBody do 
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

--------------------------------------------------------------------------------
-- gravity calculation

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



gravity.byall_PPN=function(testnum,step)
  local force=setmetatable({0,0,0},Vector)
  force[1],force[2],force[3]
  =
  Cgravity.Call_gravity_PPN(step,testnum,const.G,const.c)
  return force
end

gravity.byall=gravity.byall_PPN

--------------------------------------------------------------------------------
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

--------------------------------------------------------------------------------
-- CSV files

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

  for i=1,const.TotalStep do
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

--------------------------------------------------------------------------------
-- generate the steps

step={}

do 
  -- initialize the first step
  step[1]=setmetatable(deepcopy(Step.proto),Step)

  step[1].time=const.BeginTime

  local bodydata
  bodydata,_=ftcsv.parse('data/body.csv',',')
  for i=1,const.TotalBody do
    step[1].body[i].name  =bodydata[i]['name']
    step[1].body[i].mass  =bodydata[i]['mass(kg)']*const.kg_Earthmass
    step[1].body[i].radius=bodydata[i]['radius(m)']*const.m_AU
  end

  -- CDE430.readstate(juliandate,planet,center)
  for i=1,const.TotalBody do
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
  for i=2,const.TotalStep do
    step[i]=rk.rk4(step[i-1],const.dt)
  end
end

CSV.Savestep(step,M.range(const.TotalBody),'data/out_step.csv')

--------------------------------------------------------------------------------
-- read data from DE430

stepDE={}

do
  local bodydata
  bodydata,_=ftcsv.parse('data/body.csv',',')

  for j=1,const.TotalStep do
    stepDE[j]=setmetatable(deepcopy(Step.proto),Step)

    stepDE[j].time=const.BeginTime+(j-1)*const.dt

    for i=1,const.TotalBody do
      stepDE[j].body[i].name  =bodydata[i]['name']
      stepDE[j].body[i].mass  =bodydata[i]['mass(kg)']*const.kg_Earthmass
      stepDE[j].body[i].radius=bodydata[i]['radius(m)']*const.m_AU
    end

    for i=1,const.TotalBody do
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
end

CSV.Savestep(stepDE,M.range(const.TotalBody),'data/out_stepDE.csv')

--------------------------------------------------------------------------------
-- plot

do
  local fig_width=1500
  local fig_height=1500

  local orbit=function(bodynum)
    return
    run('step[i].body['..bodynum..'].x[1] for i=1,const.TotalStep')(),
    run('step[i].body['..bodynum..'].x[2] for i=1,const.TotalStep')(),
    run('step[i].body['..bodynum..'].x[3] for i=1,const.TotalStep')()
  end

  local orbitDE=function(bodynum)
    return
    run('stepDE[i].body['..bodynum..'].x[1] for i=1,const.TotalStep')(),
    run('stepDE[i].body['..bodynum..'].x[2] for i=1,const.TotalStep')(),
    run('stepDE[i].body['..bodynum..'].x[3] for i=1,const.TotalStep')()
  end



  local t=M.range(const.TotalStep)
  local txyz={}
  local txyzDE={}

  for i=1,const.TotalBody do
    txyz[i]={t,orbit(i)}
    txyzDE[i]={t,orbitDE(i)}
  end



  -- plot t-x, t-y, t-z
  gp{
    width=fig_width,height=fig_height,key='top left',
    xlabel='t / step',ylabel='x,y,z / AU',
    data={
      gp.array{txyz[3],title='Earth_x',using={1,2},with='lines'},
      gp.array{txyz[3],title='Earth_y',using={1,3},with='lines'},
      gp.array{txyz[3],title='Earth_z',using={1,4},with='lines'},
      gp.array{txyzDE[3],title='Earth_{x,DE}',using={1,2},with='lines'},
      gp.array{txyzDE[3],title='Earth_{y,DE}',using={1,3},with='lines'},
      gp.array{txyzDE[3],title='Earth_{z,DE}',using={1,4},with='lines'}
    }
  }:plot('data/out_txyz.svg')



  -- plot the 3D orbit
  gp{
    width=fig_width,height=fig_height,key='top left',
    xlabel='x / AU',ylabel='y / AU',zlabel='z / AU',
    data={
      gp.array{txyz[11],title='Sun',using={2,3,4},with='linespoints'},
      gp.array{txyz[3],title='Earth',using={2,3,4},with='dots'},
      gp.array{txyzDE[3],title='Earth_{DE}',using={2,3,4},with='dots'}
    }
  }:splot('data/out_xyz.svg')
 


  -- plot the orbit project to x-y, y-z, x-z planes
  gp{
    width=fig_width,height=fig_height,key='top left',
    xlabel='x / AU',ylabel='y / AU',
    data={
      gp.array{txyz[11],title='Sun',using={2,3},with='linespoints'},
      gp.array{txyz[3],title='Earth',using={2,3},with='lines'},
      gp.array{txyzDE[3],title='Earth_{DE}',using={2,3},with='lines'}
    }
  }:plot('data/out_xy.svg')



  -- plot gravity on Earth
  forcePPN={}
  force={}

  for i=1,const.TotalStep do
    forcePPN[i]=gravity.byall(3,step[i]) -- gravity on Earth in stepDE[]
    force[i]=gravity.byall_2(3,step[i])
  end

  force_x=run('force[i][1] for i=1,const.TotalStep')()
  force_y=run('force[i][2] for i=1,const.TotalStep')()
  force_z=run('force[i][3] for i=1,const.TotalStep')()

  forcePPN_x=run('forcePPN[i][1] for i=1,const.TotalStep')()
  forcePPN_y=run('forcePPN[i][2] for i=1,const.TotalStep')()
  forcePPN_z=run('forcePPN[i][3] for i=1,const.TotalStep')()

  -- plot force
  gp{
    width=fig_width,height=fig_height,key='top left',
    xlabel='t / step',ylabel='force',
    data={
      gp.array{{t,forcePPN_x},title='force_{x,PPN}',using={1,2},with='lines'},
      gp.array{{t,force_x},title='force_x',using={1,2},with='lines'},
      --gp.array{{t,force_y},title='force_y',using={1,2},with='lines'},
      --gp.array{{t,force_z},title='force_z',using={1,2},with='lines'},
      --gp.array{{t,forcePPN_x-smt(force_x,Vector)},title='df_x',using={1,2},with='lines'}
    }
  }:plot('data/out_force.svg')
end

--------------------------------------------------------------------------------

--do 
  --local tmp={}
  --for i=1,const.TotalStep do
    --M.push(tmp,(gravity.byall_PPN(3,stepDE[i])-gravity.byall_2(3,stepDE[i]))[1])
  --end

  --local t=M.range(const.TotalStep)

  --gp{
    --width=1600,height=1200,key='top left',
    --xlabel='t / day',ylabel='force',
    --data={
      --gp.array{{t,tmp},title='EarthDE.x',using={1,2},with='lines'}
    --}
  --}:plot('data/out_force.png')
--end



