-------------------------------------------------------------------------------
-- Solar System Modeling

moon=require 'moon'
ftcsv=require 'ftcsv'

-------------------------------------------------------------------------------

const={}

const.BodyTotal=13
const.BeginTime=2451545
const.dt=1
const.StepTotal=365
const.Day=24*60*60
const.AU=149597870700
const.EarthMass=5.97237e24
const.G=6.67408e-11*(1/const.Day)^-2 *(1/const.AU)^3 *(1/const.EarthMass)^-1

-------------------------------------------------------------------------------

vector={}

vector.vADDv=(v1,v2)-> [v1[i]+v2[i] for i=1,#v1]



vector.vSUBv=(v1,v2)->
  tmp={}
  for i=1,#v1 do tmp[i]=v1[i]-v2[i]
  tmp



vector.cMULv=(c,v)-> [c*v[i] for i=1,#v]

-------------------------------------------------------------------------------

step={}

step.proto={}
step.proto.time=nil
step.proto.body={}
for i=1,const.BodyTotal
  table.insert  step.proto.body, {name:nil,mass:nil,radius:nil,x:{},v:{}}

step.sADDs=(s1,s1)->
  tmp=moon.copy  s1
  tmp.time=s1.time+s2.time
  for i=1,#tmp.body
    tmp.body[i].x=[s1.body[i].x[j]+s2.body[i].x[j] for j=1,3]
    tmp.body[i].v=[s1.body[i].v[j]+s2.body[i].v[j] for j=1,3]
  tmp



step.cMULs=(c,s)->
  tmp=moon.copy s
  tmp.time=c*s.time
  for i=1,#tmp.body
    tmp.body[i].x=[c*s.body[i].x[j] for j=1,3]
    tmp.body[i].v=[c*s.body[i].v[j] for j=1,3]
  tmp

-------------------------------------------------------------------------------

steps={}

steps[1]=moon.copy  step.proto

steps[1].time=const.BeginTime

data,head=ftcsv.parse  '../data/body.csv', ','
for i=1,#steps[1].body
  steps[1].body[i].name=data[i][1]
  steps[1].body[i].mass=data[i][2]
  steps[1].body[i].radius=data[i][3]

data,head=ftcsv.parse  '../data/init.csv', ','
for i=1,#steps[1].body
  steps[1].body[i].x=moon.copy  [t for t in *data[i][1,3]]
  steps[1].body[i].v=moon.copy  [t for t in *data[i][4,6]]

-------------------------------------------------------------------------------

gravity={}

gravity.by1=(testmass,source)->
  dx=vector.vSUBv  testmass.x, source.x
  term=const.G*testmass.mass*source.mass/vector.MOD(dx)^3
  vector.cMULv  -term, dx




