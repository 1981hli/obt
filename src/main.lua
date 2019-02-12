-------------------------------------------------------------------------------
-- Solar System Modeling
--                                                                    by LiHuan
-------------------------------------------------------------------------------

require("common")



-- constant multiply step
function cMTPs(c,step)
  local tmp=copy(step)
  tmp.time=c*step.time
  -- #step.body is the number of all bodies
  for i=1, #step.body do        
    tmp.body[i].x=cMTPv(c, step.body[i].x)
    tmp.body[i].v=cMTPv(c, step.body[i].v)
  end
  return tmp
end



-- step plus step
function sPLSs(step1,step2)
  local tmp=copy(step1)
  tmp.time=step1.time+step2.time
  for i=1,#tmp.body do
    tmp.body[i].x= vPLSv(step1.body[i].x, step2.body[i].x)
    tmp.body[i].v= vPLSv(step1.body[i].v, step2.body[i].v)
  end
  return tmp
end

-------------------------------------------------------------------------------

BodyTotal=13
StepBegintime=2451545 -- Julian date at 2000.01.01
TimeInterval=1        -- day
StepTotal=90560

Day=24*60*60          -- s
AU=149597870700       -- m
Earthmass=5.97237e24  -- kg
-- G=6.67408e-11 (s-2.m3.kg-1)
GravityG=6.67408e-11*(1/Day)^-2*(1/AU)^3*(1/Earthmass)^-1



step={}
step[1]={
  time=StepBegintime,
  body={}
}
for i=1,BodyTotal do 
  table.insert(step[1].body,{name=nil,mass=nil,radius=nil,x={},v={}})
end

bodydata=readCSV("../data/bodydata.csv")
for i=1,BodyTotal do
  step[1].body[i].name  =bodydata[i][1]
  step[1].body[i].mass  =bodydata[i][2]/Earthmass
  step[1].body[i].radius=bodydata[i][3]/AU
end

initdata=readCSV("../data/initdata.csv")
for i=1,BodyTotal do
  step[1].body[i].x[1] =initdata[i][1]
  step[1].body[i].x[2] =initdata[i][2]
  step[1].body[i].x[3] =initdata[i][3]
  step[1].body[i].v[1] =initdata[i][4]
  step[1].body[i].v[2] =initdata[i][5]
  step[1].body[i].v[3] =initdata[i][6]
end

-------------------------------------------------------------------------------

function gravityby1(testmass,source)
  local dx=vMNSv(testmass.x, source.x)
  local term=GravityG*testmass.mass*source.mass/vMOD(dx)^3
  return cMTPv(-term,dx)
end 



function gravitybyall(testmassNum,step)
  local force={0,0,0}
  -- #step.body is the number of all bodies
  for i=1, #step.body do
    while true do
      -- omit itself and Earth, Moon, Solar System Barycenter
      if (i==testmassNum or i==3 or i==10 or i==12) then break end
      local force1=gravityby1(step.body[testmassNum],step.body[i])
      force=vPLSv(force,force1)
      break
    end
  end
  return force
end

-------------------------------------------------------------------------------

-- calculate dstep from the differential equation
function dstep(step,dt)
  local tmp=copy(step)
  tmp.time=dt
  for i=1, #step.body do
    local force=gravitybyall(i,step)
    tmp.body[i].x= cMTPv( dt, step.body[i].v )
    tmp.body[i].v= cMTPv( dt, cMTPv(1/step.body[i].mass, force) )
  end
  return tmp
end



function rk4(step,dt)
  -- k1=dstep(step,dt)
  local k1=dstep(step,dt)
  -- k2=dstep(step+k1/2,dt)
  local k2=dstep( sPLSs( step, cMTPs(1/2,k1) ), dt )
  -- k3=dstep(step+k2/2,dt)
  local k3=dstep( sPLSs( step, cMTPs(1/2,k2) ), dt )
  -- k4=dstep(step+k3,dt)
  local k4=dstep( sPLSs( step, k3 ), dt )
  -- dstepfinal=(k1+2k2+2K3+k4)/6
  local dstepAll=sPLSs(k1, cMTPs(2,k2)) 
        dstepAll=sPLSs(dstepAll, cMTPs(2,k3))
        dstepAll=sPLSs(dstepAll, k4)
        dstepAll=cMTPs(1/6,dstepAll)
  local nextstep=sPLSs(step,dstepAll)
  return nextstep
end



-- use Runge-Kutta method to generate all steps
for i=2, StepTotal do
  step[i]=rk4(step[i-1],TimeInterval)
  --print(i.." done")
end



-- write the results into output/i.csv where i is the body number
io.output("../data/output.csv")
local csvhead="time"
for i=1,BodyTotal do
  csvhead=csvhead..",".."body"..i.."x1"..","
                      .."body"..i.."x2"..","
                      .."body"..i.."x3"..","
                      .."body"..i.."v1"..","
                      .."body"..i.."v2"..","
                      .."body"..i.."v3"
end
csvhead=csvhead.."\n"
io.write(csvhead)

for j=1,StepTotal do
  io.write(step[j].time)
  for i=1,BodyTotal do
    io.write(",")
    io.write(step[j].body[i].x[1])
    io.write(",")
    io.write(step[j].body[i].x[2])
    io.write(",")
    io.write(step[j].body[i].x[3])
    io.write(",")
    io.write(step[j].body[i].v[1])
    io.write(",")
    io.write(step[j].body[i].v[2])
    io.write(",")
    io.write(step[j].body[i].v[3])
  end
  io.write("\n")
end
io.close()


