-------------------------------------------------------------------------------
-- Solar System Modeling
--                                                                    by LiHuan
-------------------------------------------------------------------------------

function prt(table)
  for i=1, #table do
    print(table[i])
  end
end



function addT(t1,t2)
  if (#t1 ~= #t2) then
    print("addT :: Length do not match!") 
    return
  end
  local T={}
  for i=1, #t1 do
    T[i]= t1[i]+t2[2]
  end
  return T
end

-------------------------------------------------------------------------------

gravityG=6.67e-11

-------------------------------------------------------------------------------

step={}
step[1]={
  time=0,
  body={
    {name="Sun",mass=1,radius=1,x={0,0,0},v={0,0,0}},
    {name="Earth",mass=1,radius=1,x={10,0,0},v={0,1,0}}
  }
} 

