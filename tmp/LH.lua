-------------------------------------------------------------------------------
-- module by LiHuan

local LH={}
local pl=require 'pl.import_into'()

-------------------------------------------------------------------------------

LH.new=function(class)
  return setmetatable(pl.tablex.deepcopy(class.proto),class)
end

-------------------------------------------------------------------------------

LH.table={}

LH.table.print=function(table)
  if (type(table)~="table") then
    print(table)
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
    diveinto(table,1)
  end
end



LH.table.clone=function(table)
  local function diveinto(origin,replica)
    for k,v in pairs(origin) do
      if (type(v)=="table") then
        replica[k]={}
        diveinto(v,replica[k])
      else
        replica[k]=v
      end
    end
  end
  local output={}
  diveinto(table,output)
  return setmetatable(output,getmetatable(table))
end

-------------------------------------------------------------------------------

LH.Vector={}
LH.Vector.__index=LH.Vector

LH.Vector.MOD=function(self)
  local sqrt=math.sqrt
  local tmp=0
  for i=1,#self do
    tmp=tmp+self[i]^2
  end
  return sqrt(tmp)
end



LH.Vector.__add=function(arg1,arg2)
  local output=setmetatable({},LH.Vector)
  if(type(arg1)=='number' and type(arg2)=='table') then
    for i=1,#arg2 do output[i]=arg1+arg2[i] end
  elseif(type(arg1)=='table' and type(arg2)=='number') then
    for i=1,#arg1 do output[i]=arg1[i]+arg2 end
  elseif(type(arg1)=='table' and type(arg2)=='table') then
    for i=1,#arg1 do output[i]=arg1[i]+arg2[i] end
  end
  return output
end



LH.Vector.__sub=function(arg1,arg2)
  local output=setmetatable({},LH.Vector)
  for i=1,#arg1 do output[i]=arg1[i]-arg2[i] end
  return output
end



LH.Vector.__mul=function(arg1,arg2)
  local output=setmetatable({},LH.Vector)
  if(type(arg1)=='number' and type(arg2)=='table') then
    for i=1,#arg2 do output[i]=arg1*arg2[i] end
  elseif(type(arg1)=='table' and type(arg2)=='number') then
    for i=1,#arg1 do output[i]=arg1[i]*arg2 end
  end
  return output
end

-------------------------------------------------------------------------------

LH.csv={}

LH.csv.read=function(CSVfileName)
  -- cut a line of string to segments according to symbol(comma for instance)
  local function splitline(stringline,symbol)
    local linesplit={}
    local line1=stringline
    local i=1
    while true do
      local locationofSymbol=string.find(line1,symbol)
      if locationofSymbol==nil then 
        linesplit[i]=line1
        break 
      end
      linesplit[i]=string.sub(line1,1,locationofSymbol-1)
      line1=string.sub(line1,locationofSymbol+1,#line1)
      i=i+1
    end
    return linesplit
  end

  local i=1
  local tmp={}
  for line in io.lines(CSVfileName) do
    if i==1 then 
      local head=splitline(line,',')
      i=i+1
    else
      -- read from the 2nd line to the last line
      -- indices of tmp go from 1
      tmp[i-1]=splitline(line,',')
      i=i+1
    end
  end
  return head,tmp
end



-- write a table to a csv file
LH.csv.write=function(head,table,CSVfileName)
  io.output(CSVfileName)
  io.write(head[1])
  for i=2,#head do
    io.write(',')
    io.write(head[i])
  end
  io.write('\n')
  for i=1,#table do
    io.write(table[i][1])
    for j=2,#table[i] do
      io.write(',') 
      io.write(table[i][j])
    end
    io.write('\n')
  end
  io.close()
end

-------------------------------------------------------------------------------

return LH

