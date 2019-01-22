(*---------------------------------------------------------------------------*)
(* Solar System Modeling                                                     *)
(*                                                                 by LiHuan *)
(*---------------------------------------------------------------------------*)

TotalBody      =2;
TotalStep      =365;
dtBetweenSteps =1.;
gravityG       =6.67*^-11;

(*---------------------------------------------------------------------------*)

stepInit=<|
  time   -> Null,
  body[1]-> <|name->"Sun",  mass->Null,radius->Null,x->Null,v->Null|>,
  body[2]-> <|name->"Earth",mass->Null,radius->Null,x->Null,v->Null|>
|>;



steps[1]=<|
  time   -> 0,
  body[1]-> <|name->"Sun",  mass->1,radius->1,x->{0,0,0},  v->{0,0,0}|>,
  body[2]-> <|name->"Earth",mass->1,radius->1,x->{10,0,0}, v->{0,1,0}|>
|>;



makeBody[name_String,mass_,radius_,x_,v_]:=Module[{tmpString},
  tmpString=StringJoin[
    "<|name->", name,             ",",
    "mass->",   ToString[mass],   ",",
    "radius->", ToString[radius], ",",
    "x->",      ToString[x],      ",",
    "v->",      ToString[v],      "|>"
  ];
  ToExpression[tmpString]
]

(*---------------------------------------------------------------------------*)

gravityby1[testMass_,source_]:=Module[{distance,term,force},
  distance =Sqrt[ Plus@@( (testMass[x]-source[x])^2 ) ];
  term     =gravityG*testMass[mass]*source[mass]/distance^3;
  force    =term*(source[x]-testMass[x])
]



gravitybyAll[testMassNumber_,currentStep_]:=Module[{force1,force},
  force={0,0,0};
  
  Do[
    If[i==testMassNumber,Continue[]];
    force1 =gravityby1[currentStep[body[testMassNumber]],currentStep[body[i]]];
    force +=force1,

    {i,1,TotalBody}
  ];
  
  force
]

(*---------------------------------------------------------------------------*)

stepMultiplyConstant[step_,c_]:=Module[{outputStep},
  outputStep=step;
  outputStep[time]+=c;

  Do[
    outputStep[body[i]][x]+=c;
    outputStep[body[i]][v]+=c,
    
    {i,1,TotalBody}
  ];

  outputStep
]



stepPlusStep[step1_,step2_]:=Module[{outputStep},
  outputStep=step1;
  outputStep[time]=step1[time]+step2[time];
]

(*---------------------------------------------------------------------------*)

fdt[stepInput_,dt_]:=Module[{dstep,force},
  dstep=stepInput;
  dstep[time]=dt;

  Do[
    force=gravitybyAll[i,stepInput];
    dstep[body[i]][x] =stepInput[body[i]][v] *dt;
    dstep[body[i]][v] =force/stepInput[body[i]][mass] *dt,

    {i,1,TotalBody}
  ];
  
  dstep
]



rk4[currentStep_,dt_]:=Module[{k1,k2,k3,k4,dstep},
  k1=fdt(currentStep,dt);
  k2;
  k3;
  k4;

  dstep
]

