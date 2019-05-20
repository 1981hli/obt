typedef struct
{
  char  name[20];
  Real  mass;
  Real  radius;
  Real  x[3];
  Real  v[3];
} Body;



typedef struct
{
  double time;
  Body body[BodyTotal];
} Step;
