#include <stdio.h>
#include <stdlib.h>

#include "inshm.h"



int main( int argc, char *argv[] )
{
   struct inSHM_segment_s s;
   size_t isize = 100;


   inSHM_CreateSegmentPrivate( &s, isize, 1 );

   inSHM_DetachSegment( &s, 1 );

   return(0);
}

