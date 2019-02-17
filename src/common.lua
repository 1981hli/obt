-------------------------------------------------------------------------------
-- commonly used functions and classes
--                                                                    by LiHuan
-------------------------------------------------------------------------------

-- print table
pp=require("inspect")



-- print table for debug
function p(table)
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



-- copy table
function copy(table)
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
function vMNSv(v1,v2)
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
function cMTPv(c,v)
  local output={}
  for i=1, #v do
    output[i]=c*v[i]
  end
  return output
end



-- vector module
function vMOD(v)
  local sqrt=math.sqrt
  local tmp=0
  for i=1, #v do
    tmp=tmp+v[i]^2
  end
  return sqrt(tmp)
end

-------------------------------------------------------------------------------

ftcsv=require('luamod/ftcsv')
csv={}
csv.read=ftcsv.parse
csv.write=ftcsv.encode

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

