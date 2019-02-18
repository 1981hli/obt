-------------------------------------------------------------------------------
-- Solar System Modeling
--                                                                    by LiHuan
-------------------------------------------------------------------------------

require("common")



-- constant multiply step
function cMTPs(c,step)
  local tmp=table.copy(step)
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
  local tmp=table.copy(step1)
  tmp.time=step1.time+step2.time
  for i=1,#tmp.body do
    tmp.body[i].x= vPLSv(step1.body[i].x, step2.body[i].x)
    tmp.body[i].v= vPLSv(step1.body[i].v, step2.body[i].v)
  end
  return tmp
end

-------------------------------------------------------------------------------

const={}
const.BodyTotal=13
const.Begintime=2451545 -- Julian date at 2000.01.01
const.dt=1              -- day
const.StepTotal=365     -- 90560
const.Day=24*60*60          -- s
const.AU=149597870700       -- m
const.Earthmass=5.97237e24  -- kg
-- G=6.67408e-11 (s-2.m3.kg-1)
const.G=6.67408e-11*(1/const.Day)^-2*(1/const.AU)^3*(1/const.Earthmass)^-1



step={}
step[1]={
  time=const.Begintime,
  body={}
}
for i=1,const.BodyTotal do 
  table.insert(step[1].body,{name=nil,mass=nil,radius=nil,x={},v={}})
end

bodydata,_=csv.read("../data/bodydata.csv")
for i=1,const.BodyTotal do
  step[1].body[i].name  =bodydata[i][1]
  step[1].body[i].mass  =bodydata[i][2]/const.Earthmass
  step[1].body[i].radius=bodydata[i][3]/const.AU
end

initdata,_=csv.read("../data/initdata.csv")
for i=1,const.BodyTotal do
  step[1].body[i].x[1] =initdata[i][1]
  step[1].body[i].x[2] =initdata[i][2]
  step[1].body[i].x[3] =initdata[i][3]
  step[1].body[i].v[1] =initdata[i][4]
  step[1].body[i].v[2] =initdata[i][5]
  step[1].body[i].v[3] =initdata[i][6]
end

-------------------------------------------------------------------------------

gravity={}

function gravity.by1(testmass,source)
  local dx=vMNSv(testmass.x, source.x)
  local term=const.G*testmass.mass*source.mass/vMOD(dx)^3
  return cMTPv(-term,dx)
end 



function gravity.byall(testmassNum,step)
  local force={0,0,0}
  -- #step.body is the number of all bodies
  for i=1, #step.body do
    while true do
      -- omit itself and Earth, Moon, Solar System Barycenter
      if (i==testmassNum or i==3 or i==10 or i==12) then break end
      local force1=gravity.by1(step.body[testmassNum],step.body[i])
      force=vPLSv(force,force1)
      break
    end
  end
  return force
end

-------------------------------------------------------------------------------

rk={}

-- calculate dstep from the differential equation
function rk.dstep(step,dt)
  local tmp=table.copy(step)
  tmp.time=dt
  for i=1, #step.body do
    local force=gravity.byall(i,step)
    tmp.body[i].x= cMTPv( dt, step.body[i].v )
    tmp.body[i].v= cMTPv( dt, cMTPv(1/step.body[i].mass, force) )
  end
  return tmp
end



function rk.rk4(step,dt)
  -- k1=dstep(step,dt)
  local k1=rk.dstep(step,dt)
  -- k2=dstep(step+k1/2,dt)
  local k2=rk.dstep( sPLSs( step, cMTPs(1/2,k1) ), dt )
  -- k3=dstep(step+k2/2,dt)
  local k3=rk.dstep( sPLSs( step, cMTPs(1/2,k2) ), dt )
  -- k4=dstep(step+k3,dt)
  local k4=rk.dstep( sPLSs( step, k3 ), dt )
  -- dstepfinal=(k1+2k2+2K3+k4)/6
  local dstepAll=sPLSs(k1, cMTPs(2,k2)) 
        dstepAll=sPLSs(dstepAll, cMTPs(2,k3))
        dstepAll=sPLSs(dstepAll, k4)
        dstepAll=cMTPs(1/6,dstepAll)
  local nextstep=sPLSs(step,dstepAll)
  return nextstep
end



-- use Runge-Kutta method to generate all steps
for i=2, const.StepTotal do
  step[i]=rk.rk4(step[i-1],const.dt)
  --print(i.." done")
end



-- write the results into output/i.csv where i is the body number
io.output("../data/output.csv")

-- h--[[ead of output.csv is ]]
---- time,body1x1,body1x2,body1x3,body1v1,body1v2,body1v3,body2x1,body2x2,...
--local csvhead="time"
--for i=1,const.BodyTotal do
  --csvhead=csvhead..",".."body"..i.."x1"..","
                      --.."body"..i.."x2"..","
                      --.."body"..i.."x3"..","
                      --.."body"..i.."v1"..","
                      --.."body"..i.."v2"..","
                      --.."body"..i.."v3"
--end
--csvhead=csvhead.."\n"
--io.write(csvhead)

--for j=1,StepTotal do
  --io.write(step[j].time)
  --for i=1,const.BodyTotal do
    --io.write(",")
    --io.write(step[j].body[i].x[1])
    --io.write(",")
    --io.write(step[j].body[i].x[2])
    --io.write(",")
    --io.write(step[j].body[i].x[3])
    --io.write(",")
    --io.write(step[j].body[i].v[1])
    --io.write(",")
    --io.write(step[j].body[i].v[2])
    --io.write(",")
    --io.write(step[j].body[i].v[3])
  --end
  --io.write("\n")
--[[end]]
io.close()

function csv.write(csvhead,csvvalues,filename)

end
