-------------------------------------------------------------------------------
-- commonly used functions and classes
--                                                                    by LiHuan
-------------------------------------------------------------------------------

-- LH is the package written by myself
local LH={}
LH.table={}
LH.vector={}
LH.csv={}

-------------------------------------------------------------------------------

-- print table for debug
function LH.table.print(table)
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



-- copy table
function LH.table.clone(table)
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
  return output
end

-------------------------------------------------------------------------------
-- metatable Vector

Vector.__add=function(arg1,arg2)
  local output={}
  if(type(arg1)=='number' and type(arg2)=='table') then
    for i=1,#arg2 do output[i]=arg1+arg2[i] end
  else if(type(arg1)=='table' and type(arg2)=='number') then
    for i=1,#arg1 do output[i]=arg1[i]+arg2 end
  else if(type(arg1)=='table' and type(arg2)=='table') then
    for i=1,#arg1 do output[i]=arg1[i]+arg2[i] end
  end
  return output
end



Vector.__sub=function(arg1,arg2)
  local output={}
  for i=1,#arg1 do output[i]=arg1[i]-arg2[i] end
  return output
end



Vector.__mul=function(arg1,arg2)
  local output={}
  if(type(arg1)=='number' and type(arg2)=='table') then
    for i=1,#arg2 do output[i]=arg1*arg2[i] end
  else if(type(arg1)=='table' and type(arg2)=='number') then
    for i=1,#arg1 do output[i]=arg1[i]*arg2 end
  end
  return output
end



Vector.__index=function()
  local sqrt=math.sqrt
  local tmp=0
  for i=1,#v do
    tmp=tmp+v[i]^2
  end
  return sqrt(tmp)
end

-------------------------------------------------------------------------------

-- constant plus vector
function LH.vector.cPLSv(c,v)
  local output={}
  for i=1, #v do
    output[i]=c+v[i]
  end
  return output
end



-- vector plus vector
function LH.vector.vPLSv(v1,v2)
  if (#v1 ~= #v2) then
    print("vPLSv: Length do not match!") 
    return
  end
  local output={}
  for i=1, #v1 do
    output[i]=v1[i]+v2[i]
  end
  return output
end



-- vector minus vector
function LH.vector.vMNSv(v1,v2)
  if (#v1 ~= #v2) then
    print("vMNSv: Length do not match!") 
    return
  end
  local output={}
  for i=1, #v1 do
    output[i]=v1[i]-v2[i]
  end
  return output
end



-- constant multiply vector
function LH.vector.cMTPv(c,v)
  local output={}
  for i=1, #v do
    output[i]=c*v[i]
  end
  return output
end



-- vector module
function LH.vector.MOD(v)
  local sqrt=math.sqrt
  local tmp=0
  for i=1,#v do
    tmp=tmp+v[i]^2
  end
  return sqrt(tmp)
end

-------------------------------------------------------------------------------

--csv={}
--ftcsv=require('luamod/ftcsv')
--csv.read=ftcsv.parse
--csv.encode=ftcsv.encode

---- read csv file to a table
--function readCSV(CSVfileName)
  ---- cut a line of string to segments according to symbol(comma for instance)
  --local function splitline(stringline,symbol)
    --local linesplit={}
    --local line1=stringline
    --local i=1
    --while true do
      --local locationofSymbol=string.find(line1,symbol)
      --if locationofSymbol==nil then 
        --linesplit[i]=line1
        --break 
      --end
      --linesplit[i]=string.sub(line1,1,locationofSymbol-1)
      --line1=string.sub(line1,locationofSymbol+1,#line1)
      --i=i+1
    --end
    --return linesplit
  --end

  --local i=1
  --local tmp={}
  --for line in io.lines(CSVfileName) do
    --while true do
      ---- omit the head line
      --if i==1 then 
        --i=i+1
        --break 
      --else
        ---- read from the 2nd line to the last line
        ---- indices of tmp go from 1
        --tmp[i-1]=splitline(line,",")
        --i=i+1
        --break
      --end
    --end
  --end
  --return tmp
--end



---- write a table to a csv file
--function writeCSV(table,CSVfileName)
--end

-------------------------------------------------------------------------------

pp=require("inspect")
p=LH.table.print

return LH
