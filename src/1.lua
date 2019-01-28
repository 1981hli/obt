-------------------------------------------------------------------------------
-- Solar System Modeling
--                                                                    by LiHuan
-------------------------------------------------------------------------------

-- print table for debug
function p(table)
  for k,v in pairs(table) do
    print(k ..' : '.. v)
  end
end



-- constant plus vector
function cPLSv(c,v)
  local output={}
  for i=1, #v do
    output[i]=c+v[i]
  end
  return output
end



-- vector plus vector
function vPLSv(v1,v2)
  if (#v1 ~= #v2) then
    print("vPLSv!! Length do not match") 
    return
  end
  local output={}
  for i=1, #v1 do
    output[i]=v1[i]+v2[i]
  end
  return output
end



-- vector minus vector
function vMNSv(v1,v2)
  if (#v1 ~= #v2) then
    print("vMNSv!! Length do not match") 
    return
  end
  local output={}
  for i=1, #v1 do
    output[i]=v1[i]-v2[i]
  end
  return output
end



-- constant multiply vector
function cMTPv(c,v)
  local output={}
  for i=1, #v do
    output[i]=c*v[i]
  end
  return output
end



-- vector module
function vMOD(v)
  local tmp=0
  for i=1, #v do
    tmp=tmp+v[i]^2
  end
  return math.sqrt(tmp)
end



-- constant multiply step
function cMTPs(c,step)
  local tmp=step
  tmp.time= c*tmp.time
  -- #step.body is the number of all bodies
  for i=1, #step.body do        
    tmp.body[i].x= cMTPv(c, tmp.body[i].x)
    tmp.body[i].v= cMTPv(c, tmp.body[i].v)
  end
  return tmp
end



-- step plus step
function sPLSs(step1,step2)
  local tmp=step1
  tmp.time= step1.time+step2.time
  for i=1, #step1.body do
    tmp.body[i].x= vPLSv(step1.body[i].x, step2.body[i].x)
    tmp.body[i].v= vPLSv(step1.body[i].v, step2.body[i].v)
  end
  return tmp
end

-------------------------------------------------------------------------------

local Day=24*60*60 --s
local AU=149597870700 --m
local EarthMass=5.97237e24 --kg
-- G=6.67408e-11(m3.kg-1.s-2)
local gravityG=6.67408e-11*(1/AU)^3*(1/EarthMass)*(1/Day)^2



step={}
step[1]={
  time=2451545, -- julian day of AD 2000.01.01
  body={
    {name="Sun",        mass=1.9885e30/EarthMass,
                        radius=696392000/AU,
                        x={0,0,0},
                        v={0,0,0}
    },
    {name="Earth",      mass=1,
                        radius=6371000/AU,
                        x={-0.17713509980340372,
                            0.88742852243545500,
                            0.38474289861125888},
                        v={-1.7207625066858249e-002,
                           -2.8981677276473366e-003,
                           -1.2563950525522731e-003}
    }
--    ,{name="Jupiter",    mass=1.8982e27/EarthMass,
--                        radius=69911000/AU,
--                        x={0,0,0},
--                        v={0,0,0}
--    }
  }
} 

-------------------------------------------------------------------------------

function gravityby1(testmass,source)
  local dx= vMNSv(testmass.x, source.x)
  local term= gravityG*testmass.mass*source.mass/vMOD(dx)^3
  return cMTPv(term,dx)
end 



function gravitybyall(testmassNum,step)
  local force={0,0,0}
  -- #step.body is the number of all bodies
  for i=1, #step.body do
    while true do
      if i==testmassNum then break end
      local force1=gravityby1(step.body[testmassNum], step.body[i])
      force= vPLSv(force,force1)
      break
    end
  end
  return force
end

-------------------------------------------------------------------------------

function dstep(step,dt)
  local tmp=step
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
  k1=dstep(step,dt)

  -- k2=dstep(step+k1/2,dt)
  k2=dstep( sPLSs( step, cMTPs(1/2,k1) ), dt )

  -- k3=dstep(step+k2/2,dt)
  k3=dstep( sPLSs( step, cMTPs(1/2,k2) ), dt )

  -- k4=dstep(step+k3,dt)
  k4=dstep( sPLSs( step, k3 ), dt )

  -- dstepfinal=(k1+2k2+2K3+k4)/6
  local tmp=sPLSs(k1, cMTPs(2,k2)) 
        tmp=sPLSs(tmp, cMTPs(2,k3))
        tmp=sPLSs(tmp, k4)
        tmp=cMTPs(1/6,tmp)
  
  local nextstep=sPLSs(step,tmp)
  return nextstep
end


