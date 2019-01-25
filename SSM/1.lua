-------------------------------------------------------------------------------
-- Solar System Modeling
--                                                                    by LiHuan
-------------------------------------------------------------------------------

function prt(table)
  for i=1, #table do
    print(table[i])
  end
end



function plusCV(c,v)
  local output={}
  for i=1, #v do
    output[i]=c+v[i]
  end
  return output
end



function plusVV(v1,v2)
  if (#v1 ~= #v2) then
    print("plusVV!! Length do not match") 
    return
  end
  local output={}
  for i=1, #v1 do
    output[i]=v1[i]+v2[i]
  end
  return output
end



function minusVV(v1,v2)
  if (#v1 ~= #v2) then
    print("minusVV!! Length do not match") 
    return
  end
  local output={}
  for i=1, #v1 do
    output[i]=v1[i]-v2[i]
  end
  return output
end



function multiplyCV(c,v)
  local output={}
  for i=1, #v do
    output[i]=c*v[i]
  end
  return output
end



function vectorMod(v)
  local tmp=0
  for i=1, #v do
    tmp=tmp+v[i]^2
  end
  return math.sqrt(tmp)
end

-------------------------------------------------------------------------------

gravityG=6.67e-11



step={}
step[1]={
  time=0,
  body={
    {name="Sun",mass=1,radius=1,x={0,0,0},v={0,0,0}},
    {name="Earth",mass=1,radius=1,x={10,0,0},v={0,1,0}}
  }
} 



function multiplyCStep(c,step)
  local tmp=step
  tmp.time= c*tmp.time
  -- #step.body is the number of all bodies
  for i=1, #step.body do        
    tmp.body[i].x= multiplyCV(c, tmp.body[i].x)
    tmp.body[i].v= multiplyCV(c, tmp.body[i].v)
  end
  return tmp
end



function plus2Step(step1,step2)
  local tmp=step1
  tmp.time= step1.time+step2.time
  for i=1, #step1.body do
    tmp.body[i].x= plusVV(step1.body[i].x, step2.body[i].x)
    tmp.body[i].v= plusVV(step1.body[i].v, step2.body[i].v)
  end
  return tmp
end

-------------------------------------------------------------------------------

function gravityby1(testmass,source)
  local dx= minusVV(testmass.x, source.x)
  local term= gravityG*testmass.mass*source.mass/vectorMod(dx)^3
  return multiplyCV(term,dx)
end 



function gravitybyall(testmassNum,step)
  local force={0,0,0}
  -- #step.body is the number of all bodies
  for i=1, #step.body do
    while true do
      if i==testmassNum then break end
      local force1=gravityby1(step.body[testmassNum], step.body[i])
      force= plusVV(force,force1)
      break
    end
  end
  return force
end

-------------------------------------------------------------------------------

function fdt(step,dt)
  local dstep=step
  dstep.time=dt
  for i=1, #step1.body do
    local force=gravitybyall(i,step)
    dstep.body[i].x= multiplyCV( dt, step.body[i].v )
    dstep.body[i].v= multiplyCV( dt, multiplyCV(1/step.body[i].mass, force) )
  end
  return dstep
end



function rk4()
end


