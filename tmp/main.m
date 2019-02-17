(*---------------------------------------------------------------------------*)
(* Solar System Modeling                                                     *)
(*                                                                 by LiHuan *)
(*---------------------------------------------------------------------------*)

TotalBody      =2;
TotalStep      =365;
dtBetweenSteps =1.;
gravityG       =6.67*^-11;

(*---------------------------------------------------------------------------*)

makeBody[name_String,mass_,radius_,x_,v_]:=Module[{tmpString},
  tmpString=StringJoin[
    "<|",    "name->",   name,             ",",
             "mass->",   ToString[mass],   ",",
             "radius->", ToString[radius], ",",
             "x->",      ToString[x],      ",",
             "v->",      ToString[v],              "|>"
  ];
  ToExpression[tmpString]
]



stepInit=<|
  time   -> Null,
  body[1]-> makeBody["Sun",  1,1,Null,Null],
  body[2]-> makeBody["Earth",1,1,Null,Null]
|>;



steps[1]=<|
  time   -> 0,
  body[1]-> makeBody["Sun",  1,1,{0,0,0},{0,0,0}],
  body[2]-> makeBody["Earth",1,1,{10,0,0},{0,1,0}]
|>;

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
  outputStep[time]*=c;
  Do[
    outputStep[body[i]][x]*=c;
    outputStep[body[i]][v]*=c,
    {i,1,TotalBody}
  ];
  outputStep
]



stepPlusStep[step1_,step2_]:=Module[{outputStep},
  outputStep=stepInit;
  outputStep[time]=step1[time]+step2[time];
  Do[
    outputStep[body[i]][x]=step1[body[i]][x]+step2[body[i]][x];
    outputStep[body[i]][v]=step1[body[i]][v]+step2[body[i]][v],
    {i,1,TotalBody}
  ];
  outputStep
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



rk4[currentStep_,dt_]:=Module[{dstep}(*{k1,k2,k3,k4,dstep}*),
  k1=fdt[ currentStep,                                               dt];
  k2=fdt[ stepPlusStep[ currentStep, stepMultiplyConstant[k1,1/2] ], dt];
  k3=fdt[ stepPlusStep[ currentStep, stepMultiplyConstant[k2,1/2] ], dt];
  k4=fdt[ stepPlusStep[ currentStep, k3 ],                           dt];
  (*dstep=1/6(k1+2k2+2k3+k4)*)
  dstep =stepMultiplyConstant[
    stepPlusStep[
      stepPlusStep[
        stepPlusStep[k1,stepMultiplyConstant[k2,2]],
        stepMultiplyConstant[k3,2]
      ],
      k4
    ],
    1/6
  ]
]

