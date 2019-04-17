#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

//-----------------------------------------------------------------------------

#include "plcdemos.h"
#define NSIZE    101

int plot2D_C(int points,Real x[],Real y[],
             Real xMin,Real xMax,Real yMin,Real yMax)
{
  PLFLT x[NSIZE], y[NSIZE];
  PLFLT xmin = 0., xmax = 1., ymin = 0., ymax = 100.;
  int   i;

  // Prepare data to be plotted.
  for ( i = 0; i < NSIZE; i++ )
  {
      x[i] = (PLFLT) ( i ) / (PLFLT) ( NSIZE - 1 );
      y[i] = ymax * x[i] * x[i];
  }

  // Parse and process command line arguments
  plparseopts( &argc, argv, PL_PARSE_FULL );

  // Initialize plplot
  plinit();

  // Create a labelled box to hold the plot.
  plenv( xmin, xmax, ymin, ymax, 0, 0 );
  pllab( "x", "y=100 x#u2#d", "Simple PLplot demo of a 2D line plot" );

  // Plot the data that was prepared above.
  plline( NSIZE, x, y );

  // Close PLplot library
  plend();

  exit( 0 );
}

//-----------------------------------------------------------------------------

void passarray(Real array[],int arraylength,lua_State *L,int index)
{
  int i;

  for(i=1;i<=arraylength;i++){
    lua_rawgeti(L,index,i);
    array[i-1]=lua_tonumber(L,-1);
    lua_pop(L,1);
  }
}



static int plot2D(lua_State *L)
{
  Real *x,*y,xMin,xMax,yMin,yMax;
  int points;

  points=lua_tonumber(L,1);
  passarray(x,points,L,2);
  passarray(y,points,L,3);
  xMin=lua_tonumber(L,4);
  xMax=lua_tonumber(L,5);
  yMin=lua_tonumber(L,6);
  yMax=lua_tonumber(L,7);
  plot2D_C(points,x,y,xMin,xMax,yMin,yMax);
  return 0;
}

//-----------------------------------------------------------------------------

static const struct luaL_Reg Functions[]=
{
  {"plot2D",plot2D},
  {NULL,NULL}
};

int luaopen_LC_plot(lua_State *L)
{
  luaL_register(L,"LC_plot",Functions);
  return 1;
}
